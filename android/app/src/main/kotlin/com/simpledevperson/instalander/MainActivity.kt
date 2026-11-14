package com.simpledevperson.instalander

import android.content.ComponentName
import android.content.pm.PackageManager
import android.Manifest
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

open class MainActivity : FlutterActivity() {
    private var reminderResult: MethodChannel.Result? = null
    private var notificationAction: (() -> Boolean)? = null

    private fun withNotificationPermission(result: MethodChannel.Result, action: () -> Boolean) {
        if (reminderResult != null) {
            result.error("busy", AppLanguage.context(this).getString(R.string.notification_request_busy), null)
        } else if (Build.VERSION.SDK_INT >= 33 &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            reminderResult = result
            notificationAction = action
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 4101)
        } else {
            result.success(action())
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 4101) {
            val allowed = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            reminderResult?.success(if (allowed) notificationAction?.invoke() ?: false else false)
            reminderResult = null
            notificationAction = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.simpledevperson.instalander/locale").setMethodCallHandler { call, result ->
            if (call.method == "setLanguage") {
                val language = call.arguments as? String
                if (language != null && language !in listOf("it", "en")) {
                    result.error("invalid_language", "Unsupported language", null)
                } else {
                    AppLanguage.set(this, language)
                    result.success(null)
                }
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.simpledevperson.instalander/profiles").setMethodCallHandler { call, result ->
            if (call.method == "open") {
                val username = call.argument<String>("username")
                val inBrowser = call.argument<Boolean>("inBrowser") ?: false
                result.success(username != null && ProfileLauncher.open(this, username, inBrowser))
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.simpledevperson.instalander/file_metadata").setMethodCallHandler { call, result ->
            if (call.method == "creationDate") {
                val uri = call.arguments as? String
                result.success(uri?.let { FileCreationDate.read(this, it) })
            } else {
                result.notImplemented()
            }
        }
        MonthlyReminder.schedule(this)
        DebugNotifications.restore(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.simpledevperson.instalander/reminders").setMethodCallHandler { call, result ->
            when (call.method) {
                "showDebugNotification" -> withNotificationPermission(result) {
                    DebugNotifications.show(this)
                }
                "scheduleDebugNotification" -> {
                    val delay = (call.arguments as? Number)?.toLong()
                    if (delay == null || delay <= 0 || delay > Long.MAX_VALUE - System.currentTimeMillis()) {
                        result.error("invalid_delay", AppLanguage.context(this).getString(R.string.invalid_notification_delay), null)
                    } else {
                        withNotificationPermission(result) { DebugNotifications.schedule(this, delay) }
                    }
                }
                "cancelDebugNotification" -> {
                    DebugNotifications.cancel(this)
                    result.success(null)
                }
                "isEnabled" -> result.success(MonthlyReminder.isEnabled(this))
                "getIntervalMonths" -> result.success(MonthlyReminder.getIntervalMonths(this))
                "setIntervalMonths" -> {
                    val months = call.arguments as? Int
                    if (months !in listOf(1, 3, 6)) {
                        result.error("invalid_interval", AppLanguage.context(this).getString(R.string.invalid_reminder_interval), null)
                    } else {
                        MonthlyReminder.setIntervalMonths(this, months!!)
                        result.success(null)
                    }
                }
                "setEnabled" -> {
                    val enabled = call.arguments == true
                    if (enabled) {
                        withNotificationPermission(result) { MonthlyReminder.setEnabled(this, true) }
                    } else {
                        result.success(MonthlyReminder.setEnabled(this, false))
                    }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.simpledevperson.instalander/app_icon",
        ).setMethodCallHandler { call, result ->
            if (call.method != "setAppIcon") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val selectedAlias = when (call.arguments) {
                "original" -> "OriginalIconAlias"
                "dark" -> "DarkIconAlias"
                else -> {
                    result.error("invalid_icon", "Unknown app icon option", null)
                    return@setMethodCallHandler
                }
            }
            val otherAlias = if (selectedAlias == "OriginalIconAlias") {
                "DarkIconAlias"
            } else {
                "OriginalIconAlias"
            }

            packageManager.setComponentEnabledSetting(
                ComponentName(this, "$packageName.$selectedAlias"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP,
            )
            packageManager.setComponentEnabledSetting(
                ComponentName(this, "$packageName.$otherAlias"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
            result.success(null)
        }
    }
}
