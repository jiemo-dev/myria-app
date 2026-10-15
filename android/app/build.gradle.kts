plugins {
    id("com.android.application")
    id("kotlin-android")
    // Pluginul Flutter trebuie să fie ultimul
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myria_app"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    // SINTAXA MODERNĂ KOTLIN (înlocuiește vechiul kotlinOptions)
    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8)
        }
    }

    defaultConfig {
        applicationId = "com.example.myria_app"
        minSdk = 21
        targetSdk = 34
        
        // FIX CRUCIAL: .toInt() în loc de .toInteger()
        versionCode = flutter.versionCode.toInt() 
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}