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

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 4101) {
            reminderResult?.success(MonthlyReminder.setEnabled(this,
                grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED))
            reminderResult = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MonthlyReminder.schedule(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.simpledevperson.instalander/reminders").setMethodCallHandler { call, result ->
            when (call.method) {
                "isEnabled" -> result.success(MonthlyReminder.isEnabled(this))
                "getIntervalMonths" -> result.success(MonthlyReminder.getIntervalMonths(this))
                "setIntervalMonths" -> {
                    val months = call.arguments as? Int
                    if (months !in listOf(1, 3, 6)) {
                        result.error("invalid_interval", "Scegli 1, 3 o 6 mesi", null)
                    } else {
                        MonthlyReminder.setIntervalMonths(this, months!!)
                        result.success(null)
                    }
                }
                "setEnabled" -> {
                    val enabled = call.arguments == true
                    if (reminderResult != null) {
                        result.error("busy", "Richiesta notifiche già in corso", null)
                    } else if (enabled && Build.VERSION.SDK_INT >= 33 &&
                        checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                        reminderResult = result
                        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 4101)
                    } else {
                        result.success(MonthlyReminder.setEnabled(this, enabled))
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
