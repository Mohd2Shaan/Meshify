// Emergency Mesh responder dashboard (FR-11, FR-12, FR-13).
// Plain JS + Leaflet, served by the Spring Boot backend from ../dashboard.
'use strict';

const POLL_MS = 5000;
const STALE_MS = 20000;
const TYPE_LABEL = { MEDICAL: 'Medical', TRAPPED: 'Trapped', SUPPLIES: 'Supplies', STATUS: 'Status' };
const SEVERITY_RANK = { HIGH: 0, MEDIUM: 1, LOW: 2 };
const STATUS_RANK = { PENDING: 0, ACKNOWLEDGED: 1, RESOLVED: 2 };
const AUTH_KEY = 'mesh.auth';

const state = {
  incidents: new Map(), // incidentId -> incident
  teams: [],
  markers: new Map(),   // incidentId -> Leaflet marker
  selectedId: null,
  firstLoad: true,
  lastOk: 0,
  busy: false,
  detailKey: null, // what the detail panel currently shows
};

const $ = (id) => document.getElementById(id);

// ---- HTTP ------------------------------------------------------------------

// sessionStorage keeps the login for this tab only. memoryAuth covers
// browsers where storage is blocked.
let memoryAuth = null;

function authHeader() {
  try { return sessionStorage.getItem(AUTH_KEY) || memoryAuth; } catch { return memoryAuth; }
}

class AuthError extends Error {}

async function api(path, { method = 'GET', body } = {}) {
  const auth = authHeader();
  if (!auth) throw new AuthError('not logged in');
  const res = await fetch(path, {
    method,
    headers: {
      Authorization: auth,
      // Tells Spring Security not to send WWW-Authenticate, so the browser
      // doesn't pop up its own login box over ours.
      'X-Requested-With': 'XMLHttpRequest',
      ...(body ? { 'Content-Type': 'application/json' } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  if (res.status === 401) throw new AuthError('login refused');
  if (!res.ok) {
    let detail = `HTTP ${res.status}`;
    try { detail = (await res.json()).detail || detail; } catch { /* not JSON */ }
    throw new Error(detail);
  }
  return res.json();
}

// ---- Login -----------------------------------------------------------------

function showLogin(message) {
  $('login').hidden = false;
  $('logout').hidden = true;
  const err = $('login-error');
  err.hidden = !message;
  err.textContent = message || '';
  $('login-user').focus();
}

$('login-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const token = 'Basic ' + btoa(`${$('login-user').value}:${$('login-pass').value}`);
  try { sessionStorage.setItem(AUTH_KEY, token); } catch { /* private mode: keep in memory below */ }
  memoryAuth = token;
  try {
    await refresh(true);
    $('login').hidden = true;
    $('logout').hidden = false;
    $('login-pass').value = '';
  } catch (err) {
    logout(err instanceof AuthError ? 'Wrong username or password.' : `Cannot reach the backend: ${err.message}`);
  }
});

function logout(message) {
  try { sessionStorage.removeItem(AUTH_KEY); } catch { /* ignore */ }
  memoryAuth = null;
  showLogin(message);
}
$('logout').addEventListener('click', () => logout());

// ---- Map -------------------------------------------------------------------

const map = L.map('map', { zoomControl: true }).setView([20.5937, 78.9629], 5); // India
// OpenStreetMap tiles, shown greyscale (style.css) so the coloured incident
// pins stand out; standard OSM draws every hospital and pharmacy in red too.
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
}).addTo(map);

function colorFor(i) {
  return i.status === 'RESOLVED' ? 'var(--RESOLVED)' : `var(--${i.severity})`;
}

function pinIcon(i) {
  const classes = ['pin'];
  if (i.status === 'PENDING') classes.push('pending');
  if (i.incidentId === state.selectedId) classes.push('selected');
  return L.divIcon({
    className: '',
    html: `<div class="${classes.join(' ')}" style="--c:${colorFor(i)}"><span class="ring"></span><span class="core"></span></div>`,
    iconSize: [26, 26],
    iconAnchor: [13, 13],
  });
}

function syncMarkers(visible) {
  const keep = new Set(visible.map((i) => i.incidentId));
  for (const [id, m] of state.markers) {
    if (!keep.has(id)) { m.remove(); state.markers.delete(id); }
  }
  for (const i of visible) {
    let m = state.markers.get(i.incidentId);
    if (!m) {
      m = L.marker([i.latitude, i.longitude], { icon: pinIcon(i), keyboard: true, title: TYPE_LABEL[i.type] })
        .on('click', () => select(i.incidentId, false))
        .addTo(map);
      state.markers.set(i.incidentId, m);
    } else {
      m.setLatLng([i.latitude, i.longitude]);
      m.setIcon(pinIcon(i));
    }
    m.setZIndexOffset(i.status === 'PENDING' ? 1000 : i.status === 'RESOLVED' ? -1000 : 0);
  }
}

// ---- Rendering -------------------------------------------------------------

function visibleIncidents() {
  const showResolved = $('show-resolved').checked;
  const sev = $('filter-severity').value;
  return [...state.incidents.values()]
    .filter((i) => showResolved || i.status !== 'RESOLVED')
    .filter((i) => !sev || i.severity === sev)
    .sort((a, b) =>
      STATUS_RANK[a.status] - STATUS_RANK[b.status] ||
      SEVERITY_RANK[a.severity] - SEVERITY_RANK[b.severity] ||
      new Date(b.reportedAt) - new Date(a.reportedAt));
}

function ago(iso) {
  const s = Math.max(0, Math.round((Date.now() - new Date(iso)) / 1000));
  if (s < 60) return `${s}s ago`;
  if (s < 3600) return `${Math.floor(s / 60)} min ago`;
  if (s < 86400) return `${Math.floor(s / 3600)} h ${Math.floor((s % 3600) / 60)} min ago`;
  return new Date(iso).toLocaleString();
}

function el(tag, attrs = {}, ...children) {
  const e = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === 'class') e.className = v;
    else if (k === 'style' || k.includes('-')) e.setAttribute(k, v);
    else e[k] = v;
  }
  for (const c of children) if (c != null) e.append(c); // strings become text nodes: no HTML injection
  return e;
}

function isTest(i) { return (i.note || '').startsWith('[TEST]'); }

function renderList(visible, freshIds) {
  const list = $('list');
  list.replaceChildren(...visible.map((i) => {
    const li = el('li', {
      class: `incident ${i.status.toLowerCase()}${i.incidentId === state.selectedId ? ' selected' : ''}${freshIds.has(i.incidentId) ? ' fresh' : ''}`,
      style: `--sev:${colorFor(i)}`,
      tabIndex: 0,
    },
    el('div', { class: 'row' },
      el('span', { class: 'type' }, TYPE_LABEL[i.type]),
      el('span', {},
        isTest(i) ? el('span', { class: 'badge test' }, 'TEST') : null, ' ',
        el('span', { class: `badge ${i.status}` }, i.status))),
    el('p', { class: `note${i.note ? '' : ' none'}` }, i.note || 'No note'),
    el('div', { class: 'meta' },
      el('span', {}, ago(i.reportedAt)),
      el('span', {}, `${i.hopCount} hop${i.hopCount === 1 ? '' : 's'}`),
      el('span', {}, i.assignedTeam ? `Team: ${i.assignedTeam.teamName}` : 'Unassigned')));
    li.addEventListener('click', () => select(i.incidentId, true));
    li.addEventListener('keydown', (e) => { if (e.key === 'Enter') select(i.incidentId, true); });
    return li;
  }));
  $('empty').hidden = visible.length > 0;
}

function renderStats() {
  const all = [...state.incidents.values()];
  const open = all.filter((i) => i.status !== 'RESOLVED');
  const count = (f) => all.filter(f).length;
  const stat = (n, label, alert) => el('span', { class: `stat${alert && n ? ' alert' : ''}` }, el('b', {}, String(n)), label);
  $('stats').replaceChildren(
    stat(open.length, 'open'),
    stat(open.filter((i) => i.severity === 'HIGH').length, 'high severity open', true),
    stat(count((i) => i.status === 'PENDING'), 'pending', true),
    stat(count((i) => i.status === 'ACKNOWLEDGED'), 'acknowledged'),
    stat(count((i) => i.status === 'RESOLVED'), 'resolved'),
  );
}

function renderDetail() {
  const box = $('detail');
  const i = state.incidents.get(state.selectedId);
  if (!i) { box.hidden = true; state.detailKey = null; return; }
  box.hidden = false;
  // Polling re-renders every 5 s. Only rebuild the panel when the incident
  // changed, so a team picked in the dropdown isn't reset before "Assign".
  const key = JSON.stringify([i, state.teams.length]);
  if (key === state.detailKey) return;
  state.detailKey = key;

  const teamSelect = el('select', { 'aria-label': 'Responder team' },
    el('option', { value: '' }, 'No team'),
    ...state.teams.map((t) => el('option', {
      value: t.teamId,
      selected: i.assignedTeam?.teamId === t.teamId,
    }, `${t.teamName} (${t.region})`)));
  const error = el('p', { class: 'error', hidden: true });

  const act = (label, cls, fn) => el('button', {
    class: cls,
    onclick: async (e) => {
      e.target.disabled = true;
      error.hidden = true;
      try { await fn(); } catch (err) {
        if (err instanceof AuthError) return logout('Session expired. Log in again.');
        error.textContent = `Failed: ${err.message}`;
        error.hidden = false;
      } finally { e.target.disabled = false; }
    },
  }, label);

  const setStatus = (status) => async () => {
    upsert(await api(`/api/incidents/${i.incidentId}/status`, { method: 'PATCH', body: { status } }));
    toast(`${TYPE_LABEL[i.type]} incident marked ${status.toLowerCase()}`, colorFor(i));
  };

  const actions = [];
  if (i.status === 'PENDING') actions.push(act('Acknowledge', 'info', setStatus('ACKNOWLEDGED')));
  if (i.status !== 'RESOLVED') actions.push(act('Mark resolved', 'ok', setStatus('RESOLVED')));
  else actions.push(act('Reopen', 'ghost', setStatus('ACKNOWLEDGED')));

  const coords = `${i.latitude.toFixed(5)}, ${i.longitude.toFixed(5)}`;
  box.replaceChildren(
    el('header', {},
      el('div', {},
        el('h3', { style: `color:${colorFor(i)}` }, `${TYPE_LABEL[i.type]} · ${i.severity}`),
        el('span', { class: `badge ${i.status}` }, i.status)),
      el('button', { class: 'close', title: 'Close', onclick: () => select(null) }, '×')),
    el('dl', {},
      el('dt', {}, 'Note'), el('dd', {}, i.note || 'None'),
      el('dt', {}, 'Location'), el('dd', {},
        el('a', { href: `https://www.openstreetmap.org/?mlat=${i.latitude}&mlon=${i.longitude}#map=18/${i.latitude}/${i.longitude}`, target: '_blank', rel: 'noopener' }, coords)),
      el('dt', {}, 'Reported'), el('dd', {}, `${new Date(i.reportedAt).toLocaleString()} (${ago(i.reportedAt)})`),
      el('dt', {}, 'Reached HQ'), el('dd', {}, `${ago(i.createdAt)} via ${i.hopCount} mesh hop${i.hopCount === 1 ? '' : 's'}`),
      el('dt', {}, 'Message ID'), el('dd', {}, i.messageId)),
    el('div', { class: 'section-title' }, 'Assign team (FR-12)'),
    el('div', { class: 'assign' }, teamSelect, act('Assign', '', async () => {
      const teamId = teamSelect.value || null;
      upsert(await api(`/api/incidents/${i.incidentId}/assign`, { method: 'PATCH', body: { teamId } }));
      toast(teamId ? `Assigned to ${teamSelect.selectedOptions[0].text}` : 'Team removed', colorFor(i));
    })),
    el('div', { class: 'section-title' }, 'Status (FR-13)'),
    el('div', { class: 'actions' }, ...actions),
    error,
  );
}

function render(freshIds = new Set()) {
  const visible = visibleIncidents();
  renderStats();
  renderList(visible, freshIds);
  syncMarkers(visible);
  renderDetail();
}

function select(id, pan) {
  state.selectedId = id;
  const i = state.incidents.get(id);
  if (i && pan) map.flyTo([i.latitude, i.longitude], Math.max(map.getZoom(), 15), { duration: 0.6 });
  render();
}

function upsert(i) {
  state.incidents.set(i.incidentId, i);
  render();
}

function toast(text, color) {
  const t = el('div', { class: 'toast', style: color ? `--sev:${color}` : '' }, text);
  $('toasts').append(t);
  setTimeout(() => t.remove(), 6000);
}

// ---- Polling ---------------------------------------------------------------

async function refresh(initial = false) {
  if (state.busy) return;
  state.busy = true;
  try {
    const [incidents, teams] = await Promise.all([
      api('/api/incidents'),
      initial || !state.teams.length ? api('/api/teams') : Promise.resolve(state.teams),
    ]);
    state.teams = teams;
    const fresh = new Set();
    for (const i of incidents) {
      if (!state.firstLoad && !state.incidents.has(i.incidentId)) {
        fresh.add(i.incidentId);
        toast(`New ${TYPE_LABEL[i.type].toUpperCase()} incident${i.note ? `: ${i.note}` : ''}`, colorFor(i));
      }
    }
    state.incidents = new Map(incidents.map((i) => [i.incidentId, i]));
    if (state.firstLoad && incidents.length) {
      map.fitBounds(L.latLngBounds(incidents.map((i) => [i.latitude, i.longitude])).pad(0.3), { maxZoom: 15 });
    }
    state.firstLoad = false;
    state.lastOk = Date.now();
    render(fresh);
  } finally {
    state.busy = false;
    updateClock();
  }
}

function updateClock() {
  const u = $('updated');
  if (!state.lastOk) { u.textContent = 'Not loaded'; return; }
  const stale = Date.now() - state.lastOk > STALE_MS;
  u.classList.toggle('stale', stale);
  u.textContent = stale
    ? `Backend unreachable. Last update ${ago(new Date(state.lastOk).toISOString())}`
    : `Live · updated ${new Date(state.lastOk).toLocaleTimeString()}`;
}

async function poll() {
  if (!authHeader()) return;
  try { await refresh(); } catch (err) {
    if (err instanceof AuthError) logout('Session expired. Log in again.');
  }
}

$('show-resolved').addEventListener('change', () => render());
$('filter-severity').addEventListener('change', () => render());
document.addEventListener('keydown', (e) => { if (e.key === 'Escape') select(null); });
setInterval(poll, POLL_MS);
setInterval(updateClock, 1000);

// Start: reuse this tab's login if there is one.
if (authHeader()) {
  refresh(true).then(() => { $('logout').hidden = false; }).catch(() => showLogin());
} else {
  showLogin();
}
