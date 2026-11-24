package com.simpledevperson.instalander

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import java.text.NumberFormat
import java.util.concurrent.TimeUnit

class FollowerTrackingJob : JobService() {
    private var running: Check? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun onStartJob(params: JobParameters): Boolean {
        val state = FollowerTracking.state(this)
        val name = state.username ?: return false
        if (!state.enabled || running != null || !FollowerTracking.canNotify(this)) return false
        if (params.jobId == FollowerTracking.DAILY_JOB && state.checkedRecently()) return false
        val check = Check(params, InstagramFollowerCount.Request())
        running = check
        FollowerTracking.stopActive = { stop(check) }
        val network = if (Build.VERSION.SDK_INT >= 28) params.network else null
        Thread({
            val count = check.request.fetch(name, network).count
            handler.post {
                if (running === check) {
                    release()
                    FollowerTracking.record(this, name, count)
                    jobFinished(params, false)
                }
            }
        }, "Instagram follower tracking").start()
        return true
    }

    override fun onStopJob(params: JobParameters): Boolean {
        val check = running
        if (check != null && check.params.jobId == params.jobId) {
            check.request.cancel()
            release()
        }
        return params.jobId == FollowerTracking.INITIAL_JOB && FollowerTracking.state(this).enabled
    }

    override fun onDestroy() {
        running?.request?.cancel()
        if (running != null) release()
        super.onDestroy()
    }

    private fun stop(check: Check) {
        check.request.cancel()
        release()
        jobFinished(check.params, false)
    }

    private fun release() {
        running = null
        FollowerTracking.stopActive = null
    }

    private class Check(val params: JobParameters, val request: InstagramFollowerCount.Request)
}

// State, scheduling and completion run on Android's main thread.
internal object FollowerTracking {
    const val INITIAL_JOB = 4201
    const val DAILY_JOB = 4202
    private const val CHANNEL = "instagram_follower_tracking"
    private const val NOTIFICATION = 4203
    private val day = TimeUnit.DAYS.toMillis(1)
    private val minimumGap = TimeUnit.HOURS.toMillis(20)
    var stopActive: (() -> Unit)? = null

    data class State(val username: String?, val enabled: Boolean, val count: Long?, val lastCheck: Long) {
        fun checkedRecently() = System.currentTimeMillis() - lastCheck in 0 until minimumGap

        fun toMap() = mapOf("username" to username, "enabled" to enabled)
    }

    private fun prefs(context: Context) =
        context.getSharedPreferences("follower_tracking", Context.MODE_PRIVATE)

    fun state(context: Context): State = prefs(context).let {
        State(it.getString("username", null), it.getBoolean("enabled", false),
            it.getLong("count", -1).takeIf { count -> count >= 0 }, it.getLong("lastCheck", 0))
    }

    fun setProfile(context: Context, username: String?): Boolean {
        val old = state(context)
        if (username == old.username) return true
        setEnabled(context, false)
        prefs(context).edit().clear().putString("username", username).commit()
        return username == null || !old.enabled || setEnabled(context, true)
    }

    fun setEnabled(context: Context, enabled: Boolean): Boolean {
        val scheduler = context.getSystemService(JobScheduler::class.java)
        if (!enabled) {
            prefs(context).edit().remove("enabled").remove("lastCheck").commit()
            stopActive?.invoke()
            scheduler.cancel(INITIAL_JOB)
            scheduler.cancel(DAILY_JOB)
            context.getSystemService(NotificationManager::class.java).cancel(NOTIFICATION)
            return true
        }
        if (state(context).username == null || !canNotify(context)) return false
        if (state(context).enabled) return true
        if (!prefs(context).edit().putBoolean("enabled", true).commit()) return false
        val scheduled = schedule(context, initial = true)
        if (!scheduled) setEnabled(context, false)
        return scheduled
    }

    fun restore(context: Context) {
        val scheduler = context.getSystemService(JobScheduler::class.java)
        val state = state(context)
        if (state.enabled && state.username != null && scheduler.getPendingJob(DAILY_JOB) == null) {
            schedule(context, initial = !state.checkedRecently())
        }
    }

    private fun schedule(context: Context, initial: Boolean): Boolean {
        val scheduler = context.getSystemService(JobScheduler::class.java)
        val service = ComponentName(context, FollowerTrackingJob::class.java)
        fun connectedJob(id: Int) = JobInfo.Builder(id, service)
            .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
            .setPersisted(true)

        return scheduler.schedule(connectedJob(DAILY_JOB)
            .setPeriodic(day, TimeUnit.HOURS.toMillis(1)).build()) == JobScheduler.RESULT_SUCCESS &&
            (!initial || scheduler.schedule(connectedJob(INITIAL_JOB).build()) == JobScheduler.RESULT_SUCCESS)
    }

    fun canNotify(context: Context): Boolean =
        NotificationManagerCompat.from(context).areNotificationsEnabled() &&
            context.getSystemService(NotificationManager::class.java)
                .getNotificationChannel(CHANNEL)?.importance != NotificationManager.IMPORTANCE_NONE

    fun record(context: Context, username: String, count: Long?) {
        val old = state(context)
        if (!old.enabled || old.username != username) return
        val edit = prefs(context).edit().putLong("lastCheck", System.currentTimeMillis())
        if (count != null) edit.putLong("count", count)
        edit.apply()
        val previous = old.count ?: return
        if (count == null || count == previous || !canNotify(context)) return

        val strings = AppLanguage.context(context)
        val manager = context.getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(NotificationChannel(CHANNEL,
            strings.getString(R.string.follower_tracking_channel), NotificationManager.IMPORTANCE_DEFAULT))
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val tap = launch?.let { PendingIntent.getActivity(
            context, NOTIFICATION, it, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        ) }
        val format = NumberFormat.getIntegerInstance(strings.resources.configuration.locales[0])
        val message = strings.getString(R.string.follower_tracking_change,
            username, format.format(previous), format.format(count))
        manager.notify(NOTIFICATION, NotificationCompat.Builder(context, CHANNEL)
            .setSmallIcon(R.drawable.ic_reminder)
            .setContentTitle(strings.getString(R.string.follower_tracking_channel))
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setContentIntent(tap)
            .setAutoCancel(true)
            .build())
    }
}
