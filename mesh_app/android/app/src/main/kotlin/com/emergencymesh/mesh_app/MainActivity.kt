package com.emergencymesh.mesh_app

import io.flutter.embedding.android.FlutterActivity

/**
 * Attaches to the engine created in MeshApplication instead of making its
 * own, and leaves it running when the Activity is destroyed.
 */
class MainActivity : FlutterActivity() {
    override fun getCachedEngineId(): String = MeshApplication.ENGINE_ID

    override fun shouldDestroyEngineWithHost(): Boolean = false
}
