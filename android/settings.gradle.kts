import groovy.json.JsonSlurper
import java.io.File

pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

rootProject.name = "instalander"

// Include Flutter plugin projects from .flutter-plugins-dependencies
val flutterPluginsDepsFile = File(rootDir.parentFile, ".flutter-plugins-dependencies")
if (flutterPluginsDepsFile.exists()) {
    val slurper = JsonSlurper()
    val meta = slurper.parseText(flutterPluginsDepsFile.readText()) as Map<*, *>
    val androidPlugins = (meta["plugins"] as? Map<*, *>)?.get("android") as? List<*>
    androidPlugins?.forEach { pluginUntyped ->
        val plugin = pluginUntyped as? Map<*, *> ?: return@forEach
        val name = plugin["name"] as? String ?: return@forEach
        val path = plugin["path"] as? String ?: return@forEach
        val nativeBuild = plugin["native_build"] as? Boolean ?: true
        if (nativeBuild) {
            val pluginDir = File(path, "android")
            if (pluginDir.exists()) {
                include(":$name")
                project(":$name").projectDir = pluginDir
            }
        }
    }
}

include(":app")