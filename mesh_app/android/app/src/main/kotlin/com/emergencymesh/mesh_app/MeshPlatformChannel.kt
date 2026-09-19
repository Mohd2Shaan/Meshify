package com.emergencymesh.mesh_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Bridge between Dart (lib/services/background_service.dart) and the native
 * service. Channel name must match on both sides.
 */
object MeshPlatformChannel {
    private const val NAME = "emergency_mesh/service"
    private var channel: MethodChannel? = null
    private val main = Handler(Looper.getMainLooper())

    fun register(context: Context, engine: FlutterEngine) {
        val app = context.applicationContext
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, NAME).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        MeshHealth.setEnabled(app, true)
                        result.success(MeshForegroundService.start(app))
                    }
                    "stop" -> {
                        MeshHealth.setEnabled(app, false)
                        MeshForegroundService.stop(app)
                        result.success(null)
                    }
                    "isRunning" -> result.success(MeshForegroundService.running)
                    "updateStatus" -> {
                        MeshForegroundService.instance?.updateStatus(
                            call.argument<Int>("peers") ?: 0,
                            call.argument<Int>("carried") ?: 0,
                        )
                        result.success(null)
                    }
                    "health" -> {
                        val problems = MeshHealth.problems(app)
                        result.success(
                            mapOf(
                                "ok" to problems.none(MeshHealth::isBlocking),
                                "problems" to problems,
                            ),
                        )
                    }
                    "isIgnoringBatteryOptimizations" -> {
                        val pm = app.getSystemService(PowerManager::class.java)
                        result.success(pm.isIgnoringBatteryOptimizations(app.packageName))
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        // Samsung/Xiaomi/Oppo/Vivo kill background apps aggressively
                        // unless the app is exempted from battery optimisation.
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                            .setData(Uri.parse("package:${app.packageName}"))
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        runCatching { app.startActivity(intent) }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    /** Pushes a radio/permission change to Dart so it can pause/resume Nearby. */
    fun sendHealth(ok: Boolean, problems: List<String>) {
        main.post {
            channel?.invokeMethod("healthChanged", mapOf("ok" to ok, "problems" to problems))
        }
    }
}
