package com.emergencymesh.mesh_app

import android.app.Notification
import android.app.Service
import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.location.LocationManager
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

/**
 * Keeps the app process (and so the Dart relay code in the cached Flutter
 * engine) alive while the screen is off or the app is closed, so the phone
 * keeps relaying passively (SRS 2.3).
 *
 * Also watches the Bluetooth / Location / Wi-Fi switches and reports changes
 * to Dart (which pauses and resumes Nearby) and to the user (notification).
 */
class MeshForegroundService : Service() {

    private var peers = 0
    private var carried = 0
    private var lastProblems: List<String>? = null

    private val radioReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) = checkRadios()
    }

    override fun onCreate() {
        super.onCreate()
        running = true
        instance = this
        MeshHealth.ensureChannels(this)
        val filter = IntentFilter().apply {
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
            addAction(LocationManager.PROVIDERS_CHANGED_ACTION)
            addAction(WifiManager.WIFI_STATE_CHANGED_ACTION)
        }
        ContextCompat.registerReceiver(this, radioReceiver, filter, ContextCompat.RECEIVER_NOT_EXPORTED)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE
        } else {
            0
        }
        try {
            ServiceCompat.startForeground(this, MeshHealth.NOTIFICATION_SERVICE_ID, buildNotification(), type)
        } catch (e: Exception) {
            // e.g. a required permission was revoked. The worker will notify the user.
            Log.e(TAG, "startForeground failed", e)
            stopSelf()
            return START_NOT_STICKY
        }
        checkRadios()
        // Restart after the system kills the process under memory pressure.
        return START_STICKY
    }

    override fun onDestroy() {
        unregisterReceiver(radioReceiver)
        running = false
        instance = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun checkRadios() {
        val problems = MeshHealth.problems(this)
        if (problems == lastProblems) return
        lastProblems = problems
        val blocking = problems.filter(MeshHealth::isBlocking)
        MeshPlatformChannel.sendHealth(problems.isEmpty() || blocking.isEmpty(), problems)
        if (blocking.isEmpty()) {
            MeshHealth.clearProblemNotification(this)
        } else {
            MeshHealth.notifyProblems(this, problems)
        }
        refreshNotification()
    }

    fun updateStatus(peers: Int, carried: Int) {
        this.peers = peers
        this.carried = carried
        refreshNotification()
    }

    private fun refreshNotification() {
        ContextCompat.getSystemService(this, android.app.NotificationManager::class.java)
            ?.notify(MeshHealth.NOTIFICATION_SERVICE_ID, buildNotification())
    }

    private fun buildNotification(): Notification {
        val problems = lastProblems ?: MeshHealth.problems(this)
        val blocking = problems.filter(MeshHealth::isBlocking)
        val (title, text) = when {
            blocking.isNotEmpty() -> "Relaying paused" to "${blocking.first()}. Tap to fix."
            peers == 0 -> "Emergency Mesh active" to "Looking for nearby phones · carrying $carried message(s)"
            else -> "Emergency Mesh active" to "$peers phone(s) connected · carrying $carried message(s)"
        }
        return NotificationCompat.Builder(this, MeshHealth.CHANNEL_STATUS)
            .setSmallIcon(android.R.drawable.stat_sys_data_bluetooth)
            .setContentTitle(title)
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setContentIntent(MeshHealth.openAppIntent(this))
            .build()
    }

    companion object {
        private const val TAG = "MeshService"

        @Volatile var running = false
            private set

        @Volatile var instance: MeshForegroundService? = null
            private set

        /** Returns false if Android refused (app in background without an exemption). */
        fun start(context: Context): Boolean {
            if (running) return true
            return try {
                ContextCompat.startForegroundService(context, Intent(context, MeshForegroundService::class.java))
                true
            } catch (e: Exception) {
                Log.w(TAG, "Could not start foreground service", e)
                false
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, MeshForegroundService::class.java))
        }
    }
}
