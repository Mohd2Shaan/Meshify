package com.emergencymesh.mesh_app

import android.app.Application
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import java.util.concurrent.TimeUnit

/**
 * Starts the Flutter engine with the process, not with the Activity, and
 * caches it. The Dart relay code therefore keeps running when the Activity is
 * closed (app swiped away) and starts after a reboot with no UI at all. The
 * foreground service keeps the process alive.
 */
class MeshApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        MeshHealth.ensureChannels(this)

        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(this)
        loader.ensureInitializationComplete(this, null)

        val engine = FlutterEngine(this) // registers all plugins
        MeshPlatformChannel.register(this, engine)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)

        // Checks permissions every 15 min, even when the app has been killed.
        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            PermissionWatchWorker.NAME,
            ExistingPeriodicWorkPolicy.KEEP,
            PeriodicWorkRequestBuilder<PermissionWatchWorker>(15, TimeUnit.MINUTES).build(),
        )
    }

    companion object {
        const val ENGINE_ID = "mesh_engine"
    }
}
