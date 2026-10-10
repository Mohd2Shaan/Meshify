# Meshify

**Offline-First Emergency Mesh Communication System.**

Phones relay short, encrypted emergency messages to each other over Bluetooth /
Wi-Fi Direct with no internet, until one of them (a gateway) reaches HQ. HQ
shows each message on a live map for responders.

| Folder | What | Tech |
|---|---|---|
| `mesh_app/` | Android app: send, relay, encrypt, gateway upload (FR-1 to FR-9), receipts, HQ alerts, battery-aware relaying | Flutter, nearby_connections, drift, sodium_libs, dio, protobuf |
| `backend/` | HQ API: receives uploads, creates incidents (FR-9, FR-10), issues signed receipts and alerts | Spring Boot 4 (Kotlin), JPA, PostgreSQL/H2, Spring Security, lazysodium |
| `dashboard/` | Responder map: view, assign team, update status (FR-11 to FR-13), broadcast alerts | HTML/JS + Leaflet, served by the backend |
| `proto/` | Wire format shared by app and backend | Protocol Buffers |

The design documents (SRS, UML diagrams, reports) are kept outside this repository.

## Two-way mesh: receipts, alerts, battery

The mesh also carries messages **from** HQ back to the phones:

- **Delivery receipts.** When a message reaches HQ, the sender's phone shows
  *Delivered to HQ*, then *Seen by responders · Medical Team Alpha*, then
  *Resolved*, as responders work the incident. Relay phones that receive the
  receipt stop carrying that message, which cuts mesh traffic.
- **Broadcast alerts.** Responders send an alert from the dashboard (Info,
  Warning or Critical). Gateway phones fetch it and every phone relays it, so it
  reaches phones with no internet. It shows in the app's Alerts tab, as a phone
  notification, and (Warning/Critical) as a banner on the Send screen.
- **HQ signs both** with Ed25519. Phones verify the signature before showing or
  relaying anything, so no phone can fake "help is coming" or an evacuation
  order. The signing key is derived from `MESH_PRIVATE_KEY`, so there's no new
  secret to deploy. `./gradlew genKeys` writes its public half to
  `mesh_app/lib/crypto/hq_signing_key.dart` (safe to re-run; it never replaces
  an existing key).
- **Battery-aware relaying.** At 30% or less a phone relays only Medical and
  Trapped for others and scans half the time; at 15% or less it sends only its
  own SOS and scans 20 s every 2 minutes. Receipts and alerts always get through.
  The Mesh tab shows the mode and can force one for a demo.

Update the app on **every** phone: older versions can't read receipts or alerts
(they ignore them safely).

## Tests

```bash
cd backend && ./gradlew test     # 17 API/security/crypto tests
cd mesh_app && flutter test      # 24 tests: relay on a simulated 3-phone mesh,
                                 # priority, gateway upload, crypto interop, and
                                 # an end-to-end upload (runs if the backend is up)
```

## Demo runbook (3 phones + laptop)

**One-time setup**

1. `cd backend && ./gradlew genKeys`. This creates the encryption keypair.
   **Back up `backend/secrets/`**: it isn't in Git, and losing it means old
   messages can't be decrypted.
2. Install the app on all 3 phones (`cd mesh_app && flutter run` with each
   phone plugged in). Grant every permission and allow "Keep relaying in the
   background".
3. Allow the backend through Windows Firewall (PowerShell **as administrator**):
   ```powershell
   New-NetFirewallRule -DisplayName "Emergency Mesh 8080" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow -Profile Private,Public
   ```

**On the day**

1. Laptop: *Settings → Network → Mobile hotspot → On*. College Wi-Fi usually
   blocks phone-to-laptop traffic; the laptop's own hotspot doesn't. The laptop
   is then `192.168.137.1`.
2. Laptop: `cd backend && ./gradlew bootRun --args='--spring.profiles.active=dev'`
   and open `http://localhost:8080/` (login `responder` / `responder123`).
3. **Phone C (gateway):** connect to the laptop's hotspot. In the Mesh tab →
   Gateway, it should show *GATEWAY: HQ reachable* (the URL defaults to
   `http://192.168.137.1:8080`; change it under *Settings* if needed).
4. **Phones A and B:** turn mobile data and Wi-Fi internet off, but leave
   Wi-Fi and Bluetooth themselves **on**. Keep A and C out of each other's
   range, or use the Mesh switch on A as in the Phase 3 test.
5. On A tap **MEDICAL**, then **SEND**. It relays A → B → C, C uploads, and a
   red pin pulses on the dashboard within seconds. Assign a team, then mark
   it acknowledged and resolved.

**What to point at**

| Claim | Evidence |
|---|---|
| Multi-hop, no internet | C's Messages tab: "from A · hop 2"; the relay log on B |
| Relay phones can't read content (FR-3) | B's relay log shows only random hex; the dashboard shows the note |
| Deduplication (FR-5) | Mesh tab counter "duplicates dropped" |
| TTL (FR-6) | Mesh tab → Short TTL (2 min): the message turns *expired* and stops relaying |
| Priority (FR-7) | `flutter test test/relay_manager_test.dart`: MEDICAL overtakes 6 queued STATUS; FIFO leaves it last |
| Delivery receipts | After C uploads, A's Messages tab shows *Delivered to HQ*. Assign a team on the dashboard, tap *Check / upload now* on C: A shows *Seen by responders · team*. B's Mesh tab: "stopped: HQ has it" |
| HQ broadcast | Dashboard → *Broadcast alert* → Critical. Within one gateway check (30 s, or *Check / upload now*) A and B get a notification and a red banner, with no internet |
| Can't be faked | Mesh tab counter "forged notices dropped"; `flutter test test/notice_relay_test.dart` |
| Battery saver | B's Mesh tab → Battery-aware relaying → *Battery saver*. Send STATUS from A: it stops at B ("skipped to save battery"). Send MEDICAL: it still gets through |

Without phones, `cd backend && ./gradlew seedDemo` posts sealed incidents
marked **[TEST]** through the same gateway API, which is useful for rehearsing
the dashboard.

## Hosting the backend on Railway

The root `Dockerfile` builds the backend and bundles the dashboard;
`railway.json` tells Railway to use it and to health-check `/api/health`.

1. In Railway: **New Project → Deploy from GitHub repo** → pick this repo.
2. **+ New → Database → Add PostgreSQL** in the same project.
3. On the backend service → **Variables**, add:

   | Variable | Value |
   |---|---|
   | `DB_URL` | `jdbc:postgresql://${{Postgres.PGHOST}}:${{Postgres.PGPORT}}/${{Postgres.PGDATABASE}}` |
   | `DB_USER` | `${{Postgres.PGUSER}}` |
   | `DB_PASSWORD` | `${{Postgres.PGPASSWORD}}` |
   | `MESH_PRIVATE_KEY` | the `mesh.crypto.private-key` value from `backend/secrets/mesh-keys.properties` |
   | `MESH_GATEWAY_API_KEYS` | a new random key (not `dev-gateway-key`) |
   | `MESH_RESPONDER_USER` / `MESH_RESPONDER_PASSWORD` | a new dashboard login |

   The private key must be the one whose public half is compiled into the app
   (`mesh_app/lib/crypto/backend_public_key.dart`), or uploads can't be decrypted.
4. **Settings → Networking → Generate Domain.** The dashboard is at that URL.
5. In the app on the gateway phone: Mesh tab → Gateway → *Settings*, set the
   backend URL to `https://<your-domain>` and the API key to the one from step 3.
   The gateway phone now only needs mobile data, not the laptop's hotspot.
6. Optional, to put sample incidents on the hosted dashboard (PowerShell, in `backend/`):
   ```powershell
   $env:MESH_GATEWAY_API_KEYS = "<key from step 3>"
   ./gradlew seedDemo --args="https://<your-domain>"
   ```
