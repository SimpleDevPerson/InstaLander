buildscript {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        mavenLocal()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:9.0.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.3.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        mavenLocal()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // AGP's unit-test configuration requires sources and outputs on the same
    // drive. On Windows the Pub cache can be on a different drive from the app.
    val newSubprojectBuildDir: Directory =
        if (project.projectDir.toPath().root != newBuildDir.asFile.toPath().root) {
            project.layout.projectDirectory.dir("build")
        } else {
            newBuildDir.dir(project.name)
        }
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
