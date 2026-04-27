import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties - KOTLIN SYNTAX
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.gutargooproo.application"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gutargooproo.application"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 10
        versionName = flutter.versionName
        multiDexEnabled =  true
    }

   signingConfigs {
    getByName("debug")
}
 buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        signingConfig = signingConfigs.getByName("debug")
    }
}
}
dependencies {

    implementation("androidx.multidex:multidex:2.0.1")
    implementation("com.android.billingclient:billing:6.0.1")
    implementation("com.google.android.gms:play-services-ads:22.6.0")
    implementation("androidx.media3:media3-exoplayer:1.1.1")
    implementation("androidx.media3:media3-ui:1.1.1")
    implementation("androidx.media3:media3-common:1.1.1")
    implementation("androidx.media3:media3-exoplayer-hls:1.1.1")

}

flutter {
    source = "../.."
}
configurations.all {
    resolutionStrategy {
        force("androidx.media3:media3-exoplayer:1.3.1")
        force("androidx.media3:media3-ui:1.3.1")
        force("androidx.media3:media3-common:1.3.1")
        force("androidx.media3:media3-exoplayer-hls:1.3.1")
    }
}