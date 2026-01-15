import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ceygo.app.ceygo_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ceygo.app.ceygo_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        release {
            if (System.getenv("CI") != "true") {
                storeFile = file("your_keystore.jks")
                storePassword = "your_password"
                keyAlias = "your_alias"
                keyPassword = "your_key_password"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    configurations.all {
        resolutionStrategy {
            force("androidx.activity:activity:1.9.3")
        }
    }
}

flutter {
    source = "../.."
}

// - name: Sign Release
//         uses: r0adkll/sign-android-release@v1
//         with:
//           releaseDirectory: build/app/outputs/bundle/release
//           signingKeyBase64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
//           keyStorePassword: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
//           alias: ${{ secrets.ANDROID_KEY_ALIAS }}
//           keyPassword: ${{ secrets.ANDROID_KEY_PASSWORD }}
