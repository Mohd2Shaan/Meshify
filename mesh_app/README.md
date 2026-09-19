# Emergency Mesh App (Flutter, Android)

Creates emergency messages and relays them phone-to-phone over Bluetooth /
Wi-Fi Direct (Google Nearby Connections), with no internet needed.

## Run

```bash
flutter run            # on a physical phone (emulators can't do Bluetooth mesh)
flutter test           # relay logic on a simulated multi-phone network
```

## Code map (FR = SRS functional requirement, numbers = DFD processes)

| File | Does | FR / DFD |
|---|---|---|
| `lib/ui/send_emergency_screen.dart` | 4 need-type buttons, optional note, 2 taps | FR-1 |
| `lib/services/location_service.dart` | GPS fix (falls back to a last-known fix < 30 min old) | FR-1 |
| `lib/services/emergency_sender.dart` | Validate, assign id/timestamp/TTL, seal, store | FR-2, FR-3 · 1.0, 2.0 |
| `lib/crypto/message_crypto.dart` | Seals the private payload (plaintext placeholder until Phase 5) | FR-3 · 2.0 |
| `lib/db/app_database.dart` | drift: Messages (D1), RelayLog (D2), GatewayUploads (D3) | FR-2, FR-5 |
| `lib/mesh/nearby_service.dart` | Advertise + discover + auto-connect + raw bytes | FR-4 |
| `lib/mesh/relay_manager.dart` | Dedup, TTL/hop checks, priority queue, forward, log | FR-4 to FR-7 · 3.1 to 3.5 |
| `lib/mesh/priority.dart` | Priority score = f(type, age, hops) | FR-7 · 3.3 |
| `lib/ui/messages_screen.dart` | Local message store + per-message relay log | |
| `lib/ui/nearby_devices_screen.dart` | Peers, relay stats, test switches, logs | SRS 3.3 |

## Relay rules

- **Wire format:** `MeshPacket` in `../proto/emergency_message.proto`. Relays
  read only the header (id, type, TTL, hops). GPS and the note are inside
  `sealed_payload`.
- **Store-carry-forward:** each phone keeps the messages it carries and offers
  them to every newly connected phone, so messages cross gaps in the mesh.
- **FR-5:** a message already in the store is dropped. RelayLog stops a
  message being sent back to its source or twice to the same phone.
- **FR-6:** packets past their TTL or over `maxHops` (default 10) are dropped.
  A message *at* the limit is kept, so it can still be uploaded, but not
  forwarded. A sweeper marks carried messages `expired` every 15 s.
- **FR-7:** outgoing packets leave highest priority first.

## Regenerating code

```bash
bash tool/gen_proto.sh                          # after editing the .proto
dart run build_runner build --force-jit         # after editing drift tables
```
