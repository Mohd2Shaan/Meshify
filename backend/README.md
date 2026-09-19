# Emergency Mesh Backend

Spring Boot 4 (Kotlin) + Spring Data JPA + PostgreSQL + Spring Security.
Receives messages from gateway phones and serves the responder dashboard
(FR-9 to FR-13).

## Run

```bash
# No database needed: in-memory H2, wiped on restart
./gradlew bootRun --args='--spring.profiles.active=dev'

# Against PostgreSQL (create the database first: CREATE DATABASE emergency_mesh;)
DB_PASSWORD=yourpassword ./gradlew bootRun

./gradlew test        # integration tests (use H2)
```

Server runs on `http://localhost:8080`. In dev, the H2 console is at
`/h2-console` (JDBC URL `jdbc:h2:mem:emergency_mesh`, user `sa`).

## API

| Method | Endpoint | FR | Auth |
|---|---|---|---|
| POST | `/api/messages` | FR-9, FR-10 | `X-API-Key` header (gateway) |
| GET | `/api/incidents[?status=PENDING&status=...]` | FR-11 | responder login |
| PATCH | `/api/incidents/{id}/assign` `{"teamId": "..."}` | FR-12 | responder login |
| PATCH | `/api/incidents/{id}/status` `{"status": "ACKNOWLEDGED"}` | FR-13 | responder login |
| GET | `/api/teams` | FR-12 | responder login |

Sample requests: `requests.http`. The same upload as curl (importable into Postman):

```bash
curl -X POST http://localhost:8080/api/messages \
  -H 'Content-Type: application/json' -H 'X-API-Key: dev-gateway-key' \
  -d '{"messageId":"demo-001","senderDeviceId":"phone-a","gatewayDeviceId":"phone-c",
       "type":"MEDICAL","timestampMs":1790000000000,"ttlExpiryMs":4102444800000,
       "hopCount":2,"priorityScore":97.5,
       "sealedPayload":"CSfChqdXKipAEb7BFyZTEVRAGhRMZWcgaW5qdXJ5LCAyIHBlb3BsZQ=="}'

curl -u responder:responder123 http://localhost:8080/api/incidents
```

### Upload responses

| Status | `ackStatus` | Meaning |
|---|---|---|
| 201 | `ACKNOWLEDGED` | New message, incident created |
| 200 | `DUPLICATE` | Already received (another gateway, or a retry). Same `incidentId` returned |
| 422 | `REJECTED` (`reason: expired`) | TTL passed before upload (SRS 4.5) |
| 400 | – | Missing fields, unreadable payload, or coordinates out of range |
| 401 | – | Missing or wrong API key |

Gateways should treat 201, 200 and 422 as final (stop retrying) and 5xx or
network errors as retry later.

## Configuration (env vars)

| Variable | Default | Purpose |
|---|---|---|
| `DB_URL` / `DB_USER` / `DB_PASSWORD` | `localhost:5432/emergency_mesh`, `postgres`, `postgres` | PostgreSQL |
| `MESH_GATEWAY_API_KEYS` | `dev-gateway-key` | Comma-separated gateway keys |
| `MESH_RESPONDER_USER` / `MESH_RESPONDER_PASSWORD` | `responder` / `responder123` | Dashboard login |
| `MESH_CRYPTO_MODE` | `plaintext` | Becomes `sealed` in Phase 5 |

## Design notes

- **Wire format:** `../proto/emergency_message.proto` is shared with `mesh_app`.
  Relay phones can read only the routing header (messageId, type, TTL, hop
  count). GPS and the note travel inside `sealedPayload`.
- **Idempotent upload:** one incident per `messageId`. Every upload attempt is
  still recorded in `GatewayUpload`.
- **Data model** follows SRS §3.4. RelayLog exists only on the phones (it
  is per-device dedup state). `Message.note` is an addition that the ER diagram
  doesn't show yet.
