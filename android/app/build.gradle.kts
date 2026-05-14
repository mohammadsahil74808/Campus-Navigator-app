plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// ── Load API key from local.properties (NEVER hardcode in source) ──────────
import java.util.Properties
val localProps = Properties()
val localPropsFile = rootProject.file("local.properties")
if (localPropsFile.exists()) {
    localPropsFile.inputStream().use { localProps.load(it) }
}
val mapsApiKey: String = localProps.getProperty("MAPS_API_KEY") ?: ""

android {
    namespace = "com.sahil.campusnavigator"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.sahil.campusnavigator"

        // ── FIX: minSdk must be 24 for ARCore + MLKit + camera plugin ──────
        // Original used flutter.minSdkVersion which defaults to 16.
        // google_mlkit_text_recognition requires minSdk 21
        // camera plugin requires minSdk 21
        // ARCore integration requires minSdk 24
        minSdk = 24
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Inject Maps API key into manifest placeholder (security fix)
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey

        // Enable multidex for large dependency tree (Firebase + MLKit + Maps)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug") // Replace with release key for production
        }
        debug {
            isDebuggable = true
        }
    }

    // ── GPU / rendering options for AR performance ──────────────────────────
    packagingOptions {
        resources {
            excludes += setOf("META-INF/DEPENDENCIES", "META-INF/LICENSE")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Multidex support
    implementation("androidx.multidex:multidex:2.0.1")
}
