package com.emergencymesh.mesh_app

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

/**
 * Revoking a permission in system settings kills the app process, so the app
 * can't react to it. This worker runs every ~15 minutes (Android's minimum),
 * even after such a kill, and tells the user relaying has stopped.
 */
class PermissionWatchWorker(context: Context, params: WorkerParameters) : Worker(context, params) {

    override fun doWork(): Result {
        val ctx = applicationContext
        if (!MeshHealth.isEnabled(ctx)) return Result.success()

        val problems = MeshHealth.problems(ctx).toMutableList()
        if (problems.none(MeshHealth::isBlocking) && !MeshForegroundService.running) {
            // Everything is allowed again, but the process was killed by the revoke.
            // Android doesn't let a worker restart a foreground service, so ask the user.
            problems += "Relaying stopped. Open the app to restart it"
        }
        if (problems.any(MeshHealth::isBlocking)) {
            MeshHealth.notifyProblems(ctx, problems)
        }
        return Result.success()
    }

    companion object {
        const val NAME = "mesh_permission_watch"
    }
}
