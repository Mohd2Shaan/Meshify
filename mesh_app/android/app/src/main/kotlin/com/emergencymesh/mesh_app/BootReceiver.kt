package com.emergencymesh.mesh_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Restarts relaying after a reboot or app update, if the user had it on.
 * Receiving this broadcast starts the process, so MeshApplication boots the
 * Dart relay code. The service is started here because Android only allows
 * a background foreground-service start for a short window after boot.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> {
                if (!MeshHealth.isEnabled(context)) return
                val problems = MeshHealth.problems(context)
                if (problems.any(MeshHealth::isBlocking)) {
                    MeshHealth.notifyProblems(context, problems)
                } else {
                    MeshForegroundService.start(context)
                }
            }
        }
    }
}
