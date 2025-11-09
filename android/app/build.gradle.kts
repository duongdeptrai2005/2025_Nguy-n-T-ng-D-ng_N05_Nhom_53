plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // ✅ dùng chuẩn Kotlin plugin
    id("com.google.gms.google-services") // ✅ phải có dòng này
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.library_manager"
    compileSdk = 36 // 🔥 nâng lên ít nhất 35 hoặc 36 để tương thích plugin

    defaultConfig {
        applicationId = "com.example.library_manager"
        minSdk = flutter.minSdkVersion // 👈 Firebase và image_picker cần tối thiểu 23
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
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
