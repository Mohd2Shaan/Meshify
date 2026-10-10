package com.emergencymesh.mesh_app

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.wifi.WifiManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.core.location.LocationManagerCompat

/**
 * Checks whether this phone can currently relay (permissions and radios), and
 * owns the notification channels. Shared by the foreground service, the boot
 * receiver and the periodic PermissionWatchWorker.
 */
object MeshHealth {
    const val CHANNEL_STATUS = "mesh_status"
    const val CHANNEL_ALERTS = "mesh_alerts"
    const val CHANNEL_HQ = "hq_alerts"
    const val NOTIFICATION_SERVICE_ID = 1001
    const val NOTIFICATION_PROBLEM_ID = 1002

    private const val PREFS = "emergency_mesh"
    private const val KEY_ENABLED = "meshEnabled"
    private const val KEY_LAST_PROBLEM = "lastNotifiedProblem"

    /** Runtime permissions Nearby + GPS + notifications need on this Android version. */
    fun requiredPermissions(): Map<String, String> = buildMap {
        put(Manifest.permission.ACCESS_FINE_LOCATION, "Location")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            put(Manifest.permission.BLUETOOTH_SCAN, "Nearby devices (Bluetooth)")
            put(Manifest.permission.BLUETOOTH_ADVERTISE, "Nearby devices (Bluetooth)")
            put(Manifest.permission.BLUETOOTH_CONNECT, "Nearby devices (Bluetooth)")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            put(Manifest.permission.NEARBY_WIFI_DEVICES, "Nearby devices (Wi-Fi)")
            put(Manifest.permission.POST_NOTIFICATIONS, "Notifications")
        }
    }

    /** Human-readable reasons the mesh can't work right now; empty when healthy. */
    fun problems(context: Context): List<String> {
        val out = mutableListOf<String>()
        requiredPermissions()
            .filterKeys { ContextCompat.checkSelfPermission(context, it) != PackageManager.PERMISSION_GRANTED }
            .values.distinct()
            .forEach { out += "$it permission is turned off" }

        val bt = context.getSystemService(BluetoothManager::class.java)?.adapter
        if (bt == null || !bt.isEnabled) out += "Bluetooth is off"

        val lm = context.getSystemService(LocationManager::class.java)
        if (lm == null || !LocationManagerCompat.isLocationEnabled(lm)) out += "Location is off"

        val wifi = context.applicationContext.getSystemService(WifiManager::class.java)
        if (wifi == null || !wifi.isWifiEnabled) out += "Wi-Fi is off (range and speed reduced)"
        return out
    }

    /**
     * Wi-Fi off degrades the mesh (Bluetooth still works) and missing
     * notification permission only loses the warnings. Neither stops relaying.
     */
    fun isBlocking(problem: String) =
        !problem.startsWith("Wi-Fi") && !problem.startsWith("Notifications")

    // ---- "user has switched the mesh on" flag (set from Dart) -------------------

    fun isEnabled(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(KEY_ENABLED, false)

    fun setEnabled(context: Context, enabled: Boolean) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putBoolean(KEY_ENABLED, enabled).apply()
        if (!enabled) clearProblemNotification(context)
    }

    // ---- Notifications -------------------------------------------------------------

    fun ensureChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_STATUS, "Mesh status", NotificationManager.IMPORTANCE_LOW)
                .apply { description = "Shows that emergency relaying is running" },
        )
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_ALERTS, "Mesh problems", NotificationManager.IMPORTANCE_HIGH)
                .apply { description = "Warns when a permission or radio is off and relaying has stopped" },
        )
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_HQ, "Alerts from HQ", NotificationManager.IMPORTANCE_HIGH)
                .apply { description = "Broadcasts from emergency responders, received through the mesh" },
        )
    }

    fun openAppIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        return PendingIntent.getActivity(
            context, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    /**
     * Heads-up alert that relaying has stopped. Only re-alerts when the set of
     * problems changes, so the user isn't spammed every 15 minutes.
     */
    fun notifyProblems(context: Context, problems: List<String>) {
        val key = problems.sorted().joinToString("|")
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (prefs.getString(KEY_LAST_PROBLEM, null) == key) return
        prefs.edit().putString(KEY_LAST_PROBLEM, key).apply()

        if (ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
        ) {
            return // can't notify at all; the app shows the problem on next open
        }
        ensureChannels(context)
        val text = problems.joinToString("\n")
        val n = NotificationCompat.Builder(context, CHANNEL_ALERTS)
            .setSmallIcon(android.R.drawable.stat_notify_error)
            .setContentTitle("Emergency Mesh is NOT working")
            .setContentText((problems.firstOrNull(::isBlocking) ?: problems.first()) + ". Tap to fix.")
            .setStyle(NotificationCompat.BigTextStyle().bigText("$text\n\nTap to fix."))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ERROR)
            .setContentIntent(openAppIntent(context))
            .setAutoCancel(true)
            .build()
        context.getSystemService(NotificationManager::class.java).notify(NOTIFICATION_PROBLEM_ID, n)
    }

    fun clearProblemNotification(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().remove(KEY_LAST_PROBLEM).apply()
        context.getSystemService(NotificationManager::class.java).cancel(NOTIFICATION_PROBLEM_ID)
    }

    /** A signed broadcast from HQ arrived through the mesh. One notification per alert. */
    fun notifyHqAlert(context: Context, noticeId: String, level: String, title: String, body: String) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
        ) {
            return // the Alerts tab still shows it
        }
        ensureChannels(context)
        val n = NotificationCompat.Builder(context, CHANNEL_HQ)
            .setSmallIcon(android.R.drawable.stat_sys_warning)
            .setContentTitle("HQ ${level.lowercase()}: $title")
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setContentIntent(openAppIntent(context))
            .setAutoCancel(true)
            .build()
        context.getSystemService(NotificationManager::class.java).notify(noticeId.hashCode(), n)
    }
}
