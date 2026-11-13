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
import java.util.Calendar

/** A brief native receiver at the selected interval. No service or Flutter engine. */
class MonthlyReminder : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        if (!prefs.getBoolean("enabled", false)) return
        if (intent.action == ACTION) {
            if (canNotify(context)) {
                val manager = context.getSystemService(NotificationManager::class.java)
                manager.createNotificationChannel(NotificationChannel(
                    CHANNEL, "Promemoria Instagram", NotificationManager.IMPORTANCE_DEFAULT,
                ))
                // Open whichever launcher alias is currently enabled.
                val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
                val tap = launch?.let { PendingIntent.getActivity(context, 4102, it,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE) }
                manager.notify(4101, NotificationCompat.Builder(context, CHANNEL)
                    .setSmallIcon(R.drawable.ic_reminder)
                    .setContentTitle("Aggiorna i tuoi dati Instagram")
                    .setContentText("Richiedi il download delle tue informazioni su Instagram.")
                    .setStyle(NotificationCompat.BigTextStyle().bigText(
                        "Richiedi il download delle tue informazioni su Instagram e importa i nuovi JSON per aggiornare la timeline."))
                    .setContentIntent(tap)
                    .setAutoCancel(true)
                    .build())
            }
            // Use the original day of month, including after short months.
            prefs.edit().putLong("next", nextMonth(context)).apply()
        }
        schedule(context)
    }

    companion object {
        private const val PREFS = "monthly_instagram_reminder"
        private const val CHANNEL = "instagram_monthly"
        private const val ACTION = "com.simpledevperson.instalander.MONTHLY_REMINDER"

        fun canNotify(context: Context): Boolean =
            (Build.VERSION.SDK_INT < 33 || ContextCompat.checkSelfPermission(
                context, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) &&
                NotificationManagerCompat.from(context).areNotificationsEnabled() &&
                (context.getSystemService(NotificationManager::class.java)
                    .getNotificationChannel(CHANNEL)?.importance != NotificationManager.IMPORTANCE_NONE)

        fun isEnabled(context: Context): Boolean = canNotify(context) &&
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean("enabled", false)

        fun getIntervalMonths(context: Context): Int =
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getInt("months", 1)

        fun setIntervalMonths(context: Context, months: Int) {
            require(months in listOf(1, 3, 6))
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            if (getIntervalMonths(context) == months) return
            prefs.edit().putInt("months", months)
                .putInt("day", Calendar.getInstance().get(Calendar.DAY_OF_MONTH)).apply()
            if (prefs.getBoolean("enabled", false)) {
                prefs.edit().putLong("next", nextMonth(context)).apply()
                schedule(context)
            }
        }

        fun setEnabled(context: Context, enabled: Boolean): Boolean {
            if (enabled && !canNotify(context)) return false
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            if (!enabled) {
                prefs.edit().remove("enabled").remove("next").remove("day").apply()
                context.getSystemService(AlarmManager::class.java).cancel(pending(context))
                context.getSystemService(NotificationManager::class.java).cancel(4101)
                return false
            }
            if (!prefs.getBoolean("enabled", false)) {
                prefs.edit().putBoolean("enabled", true)
                    .putInt("day", Calendar.getInstance().get(Calendar.DAY_OF_MONTH)).apply()
                prefs.edit().putLong("next", nextMonth(context)).apply()
            }
            schedule(context)
            return true
        }

        private fun nextMonth(context: Context): Long {
            val day = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getInt("day", 1)
            return Calendar.getInstance().apply {
                set(Calendar.DAY_OF_MONTH, 1)
                add(Calendar.MONTH, getIntervalMonths(context))
                set(Calendar.DAY_OF_MONTH, day.coerceAtMost(getActualMaximum(Calendar.DAY_OF_MONTH)))
                set(Calendar.HOUR_OF_DAY, 10)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }.timeInMillis
        }

        private fun pending(context: Context): PendingIntent = PendingIntent.getBroadcast(
            context, 4101, Intent(context, MonthlyReminder::class.java).setAction(ACTION),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        fun schedule(context: Context) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            if (!prefs.getBoolean("enabled", false)) return
            // Inexact and non-wakeup: Android can batch delivery to save battery.
            val next = prefs.getLong("next", 0).coerceAtLeast(System.currentTimeMillis() + 60_000)
            context.getSystemService(AlarmManager::class.java).set(
                AlarmManager.RTC, next, pending(context),
            )
        }
    }
}
