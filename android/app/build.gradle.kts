plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase Services
}

android {
    namespace = "com.example.time_capsule"
    compileSdk = 34 // Set manually, as `flutter.compileSdkVersion` is not valid

    ndkVersion = "23.1.7779620" // Replace with your correct NDK version

    defaultConfig {
        applicationId = "com.example.time_capsule"
        minSdk = 21  // Set manually
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}

// ✅ Firebase and other dependencies
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth") // Add if using Firebase Authentication
}

// ✅ Flutter setup
flutter {
    source = "../.."
}
