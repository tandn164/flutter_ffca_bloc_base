plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val firebaseConfigFiles = fileTree("src") {
    include("*/google-services.json")
}.files
val usesFirebase = file("../../pubspec.yaml").readText().contains(Regex("(?m)^\\s+firebase_core:"))
if (usesFirebase && firebaseConfigFiles.isEmpty()) {
    throw GradleException(
        "firebase_core is enabled but android/app/src/<flavor>/google-services.json is missing.",
    )
}
if (firebaseConfigFiles.isNotEmpty()) {
    apply(plugin = "com.google.gms.google-services")
}

android {
    namespace = "com.company.flutter_ffca_base"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.company.flutter_ffca_base"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
        }
        create("stg") {
            dimension = "env"
            applicationIdSuffix = ".stg"
        }
        create("prod") {
            dimension = "env"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
