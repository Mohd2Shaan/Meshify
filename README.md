# Offline-First Emergency Mesh Communication System

Phones relay short, encrypted emergency messages to each other over Bluetooth /
Wi-Fi Direct with no internet, until one of them (a gateway) reaches HQ. HQ
shows each message on a live map for responders.

| Folder | What | Tech |
|---|---|---|
| `mesh_app/` | Android app: send, relay, encrypt, gateway upload (FR-1 to FR-9) | Flutter, nearby_connections, drift, sodium_libs, dio, protobuf |
| `backend/` | HQ API: receives uploads, creates incidents (FR-9, FR-10) | Spring Boot 4 (Kotlin), JPA, PostgreSQL/H2, Spring Security, lazysodium |
| `dashboard/` | Responder map: view, assign team, update status (FR-11 to FR-13) | HTML/JS + Leaflet, served by the backend |
| `proto/` | Wire format shared by app and backend | Protocol Buffers |

Design documents (SRS, diagrams, reports) are in the repository root.

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

Without phones, `cd backend && ./gradlew seedDemo` posts sealed incidents
marked **[TEST]** through the same gateway API, which is useful for rehearsing
the dashboard.
