package com.simpledevperson.instalander

import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources
import android.os.LocaleList
import java.util.Locale

object AppLanguage {
    fun set(context: Context, code: String?) {
        context.getSharedPreferences("app_language", Context.MODE_PRIVATE)
            .edit().apply {
                if (code == null) remove("code") else putString("code", code)
            }.apply()
    }

    fun context(context: Context): Context {
        val code = context.getSharedPreferences("app_language", Context.MODE_PRIVATE)
            .getString("code", null)
        val locale = code?.let(Locale::forLanguageTag)
            ?: Resources.getSystem().configuration.locales[0]
        val config = Configuration(context.resources.configuration)
        config.setLocales(LocaleList(locale))
        return context.createConfigurationContext(config)
    }
}
