plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.amora"
    compileSdk = 34
    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    defaultConfig {
        applicationId = "com.example.amora"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true

        // Add your romantic theme colors as build config fields
        buildConfigField("int", "SOFT_PINK", "0xFFF8E1E9")
        buildConfigField("int", "ROSE_GOLD", "0xFFB76E79")
        buildConfigField("int", "DEEP_ROSE", "0xFF8B5A5A")
        buildConfigField("int", "CREAM_WHITE", "0xFFF5F5F5")
        buildConfigField("int", "VINTAGE_SEPIA", "0xFF704214")
    }

    signingConfigs {
        create("release") {
            storeFile = file("keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-DEBUG"
            resValue("color", "primary_color", "#F8E1E9")
            resValue("color", "secondary_color", "#B76E79")
        }

        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            resValue("color", "primary_color", "#F8E1E9")
            resValue("color", "secondary_color", "#B76E79")
        }
    }

    buildFeatures {
        viewBinding = true
        buildConfig = true
    }

    packaging {
        resources {
            excludes += setOf(
                "/META-INF/{AL2.0,LGPL2.1}",
                "**/kotlin/**",
                "**/*.txt",
                "**/*.xml",
                "**/*.properties"
            )
        }
    }

    // Only package ARM binaries to reduce APK size
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a")
            isUniversalApk = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
    implementation("com.google.android.material:material:1.11.0") // For material components

    // For your Google Fonts integration
    implementation("com.google.guava:guava:31.1-android")

    // For secure storage of romantic memories
    implementation("androidx.security:security-crypto:1.1.0-alpha06")

    // For image processing
    implementation("com.github.bumptech.glide:glide:4.16.0")
}