import java.util.Properties
import java.io.File
import java.io.FileInputStream

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// Load Flutter SDK path from local.properties
val localProperties = Properties().apply {
    load(File(rootDir, "local.properties").inputStream())
}

val flutterSdkPath = localProperties.getProperty("flutter.sdk")
    ?: error("flutter.sdk not set in local.properties")

includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")
