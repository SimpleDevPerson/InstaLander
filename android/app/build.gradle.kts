plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Properties

val signingPropertiesFile = rootProject.file("key.properties")
val signingProperties = Properties()
if (signingPropertiesFile.isFile) {
    signingPropertiesFile.inputStream().use(signingProperties::load)
}

android {
    namespace = "com.simpledevperson.instalander"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        applicationId = "com.simpledevperson.instalander"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            signingProperties.getProperty("storeFile")?.let {
                storeFile = rootProject.file(it)
            }
            signingProperties.getProperty("storePassword")?.let {
                storePassword = it
            }
            signingProperties.getProperty("keyAlias")?.let {
                keyAlias = it
            }
            signingProperties.getProperty("keyPassword")?.let {
                keyPassword = it
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    packaging {
        resources.excludes.add("META-INF/**")
    }
}

gradle.taskGraph.whenReady {
    val isReleaseBuild = allTasks.any {
        it.name == "assembleRelease" || it.name == "bundleRelease"
    }
    if (isReleaseBuild) {
        val requiredProperties =
            listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
        val missingProperties = requiredProperties.filter {
            signingProperties.getProperty(it).isNullOrBlank()
        }
        check(missingProperties.isEmpty()) {
            "Release signing is not configured. Copy android/key.properties.example " +
                "to android/key.properties and fill in the local keystore details."
        }

        val keystore = rootProject.file(signingProperties.getProperty("storeFile"))
        check(keystore.isFile) {
            "Release keystore not found at ${keystore.absolutePath}. " +
                "Check the storeFile value in android/key.properties."
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.3.20")
}