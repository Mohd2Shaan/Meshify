# Vendored nearby_connections 4.3.0

Copied from pub.dev (MIT licence, see LICENSE) with one change in
`android/src/main/java/.../NearbyConnectionsPlugin.java`:

- The upstream plugin passes the **Activity** to `Nearby.getConnectionsClient()`
  and keeps a stale reference after the Activity is destroyed. It now uses the
  **application context**, set in `onAttachedToEngine`.

Why: the mesh runs in a foreground service (SRS 2.3, passive relay). It must
keep working after the app is swiped away and after a reboot, when no
Activity exists.
