package com.simpledevperson.instalander

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat

class DebugNotifications : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().clear().apply()
            show(context)
        } else {
            restore(context)
        }
    }

    companion object {
        private const val PREFS = "debug_notifications"
        private const val CHANNEL = "instagram_debug"
        private const val ACTION = "com.simpledevperson.instalander.DEBUG_NOTIFICATION"
        private const val ID = 4201

        private fun manager(context: Context): NotificationManager =
            context.getSystemService(NotificationManager::class.java)

        private fun canNotify(context: Context): Boolean {
            manager(context).createNotificationChannel(NotificationChannel(
                CHANNEL, AppLanguage.context(context).getString(R.string.debug_notification_channel), NotificationManager.IMPORTANCE_DEFAULT))
            return (Build.VERSION.SDK_INT < 33 || ContextCompat.checkSelfPermission(
                context, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) &&
                NotificationManagerCompat.from(context).areNotificationsEnabled() &&
                manager(context).getNotificationChannel(CHANNEL).importance != NotificationManager.IMPORTANCE_NONE
        }

        fun show(context: Context): Boolean {
            if (!canNotify(context)) return false
            val strings = AppLanguage.context(context)
            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val tap = launch?.let { PendingIntent.getActivity(context, ID, it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE) }
            manager(context).notify(ID, NotificationCompat.Builder(context, CHANNEL)
                .setSmallIcon(R.drawable.ic_reminder)
                .setContentTitle(strings.getString(R.string.debug_notification_title))
                .setContentText(strings.getString(R.string.debug_notification_text))
                .setContentIntent(tap).setAutoCancel(true).build())
            return true
        }

        private fun pending(context: Context) = PendingIntent.getBroadcast(context, ID,
            Intent(context, DebugNotifications::class.java).setAction(ACTION),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        fun schedule(context: Context, delay: Long): Boolean {
            require(delay > 0 && delay <= Long.MAX_VALUE - System.currentTimeMillis())
            if (!canNotify(context)) return false
            val next = System.currentTimeMillis() + delay
            arm(context, next)
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putLong("next", next).apply()
            return true
        }

        private fun arm(context: Context, next: Long) {
            val alarms = context.getSystemService(AlarmManager::class.java)
            if (Build.VERSION.SDK_INT < 31 || alarms.canScheduleExactAlarms()) {
                alarms.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next, pending(context))
            } else {
                alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next, pending(context))
            }
        }

        fun restore(context: Context) {
            val next = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getLong("next", 0)
            if (next > 0) arm(context, next.coerceAtLeast(System.currentTimeMillis()))
        }

        fun cancel(context: Context) {
            context.getSystemService(AlarmManager::class.java).cancel(pending(context))
            manager(context).cancel(ID)
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().clear().apply()
        }
    }
}
