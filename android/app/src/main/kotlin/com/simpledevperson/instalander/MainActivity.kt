package com.simpledevperson.instalander

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

open class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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