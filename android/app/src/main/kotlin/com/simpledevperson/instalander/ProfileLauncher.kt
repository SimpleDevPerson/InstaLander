package com.simpledevperson.instalander

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri

object ProfileLauncher {
    fun open(activity: Activity, username: String, inBrowser: Boolean): Boolean {
        if (!username.matches(Regex("[A-Za-z0-9._]+"))) return false
        val url = Uri.Builder().scheme("https").authority("www.instagram.com")
            .appendPath(username).appendPath("").build()
        if (!inBrowser) {
            val deepLink = Intent(Intent.ACTION_VIEW, Uri.Builder()
                .scheme("instagram").authority("user")
                .appendQueryParameter("username", username).build())
            val webLink = Intent(Intent.ACTION_VIEW, url)
            val pm = activity.packageManager
            val browsers = pm.queryIntentActivities(
                Intent(Intent.ACTION_VIEW, Uri.parse("https://example.org")),
                PackageManager.MATCH_DEFAULT_ONLY,
            ).map { it.activityInfo.packageName }.toSet()
            val clients = linkedMapOf<String, Intent>()
            // Custom-scheme handlers include renamed and cloned Instagram apps.
            for (handler in pm.queryIntentActivities(deepLink, PackageManager.MATCH_DEFAULT_ONLY)) {
                val name = handler.activityInfo.packageName
                if (name !in browsers) clients[name] = Intent(deepLink).setPackage(name)
            }
            // Some clients expose only HTTPS profile links. Exclude browsers.
            for (handler in pm.queryIntentActivities(webLink, PackageManager.MATCH_DEFAULT_ONLY)) {
                if (handler.activityInfo.packageName !in browsers) {
                    val name = handler.activityInfo.packageName
                    clients.putIfAbsent(name, Intent(webLink).setPackage(name))
                }
            }
            // Explicit queries also work when Android has disabled a client's
            // verified web links. Package names cover clone/unclone variants.
            for (name in listOf("com.instagram.android", "com.instagram.android.piko",
                "com.instander.android", "com.instander", "com.instamod.android",
                "com.myinsta.android", "com.myinsta")) {
                val intent = Intent(webLink).setPackage(name)
                if (intent.resolveActivity(pm) != null) clients.putIfAbsent(name, intent)
            }
            for (intent in listOf(deepLink, webLink)) {
                val preferred = intent.resolveActivity(pm)?.packageName
                val target = clients[preferred]
                if (target != null && launch(activity, target)) return true
            }
            if (clients.size == 1 && launch(activity, clients.values.first())) return true
            if (clients.size > 1) {
                val targets = clients.values.toList()
                val chooser = Intent.createChooser(targets.first(),
                    AppLanguage.context(activity).getString(R.string.choose_instagram_client))
                    .putExtra(Intent.EXTRA_INITIAL_INTENTS, targets.drop(1).toTypedArray())
                if (launch(activity, chooser)) return true
            }
        }
        return try {
            // Resolve a browser explicitly so verified Instagram links cannot
            // send the user back to the Instagram app.
            val intent = Intent(Intent.ACTION_VIEW, url)
            intent.selector = Intent(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_APP_BROWSER)
            activity.startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        } catch (_: SecurityException) {
            false
        }
    }

    private fun launch(activity: Activity, intent: Intent): Boolean = try {
        activity.startActivity(intent)
        true
    } catch (_: ActivityNotFoundException) {
        false
    } catch (_: SecurityException) {
        false
    }
}
