import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

val releaseSigningHelp =
    "Create android/key.properties from android/key.properties.example before building a Play Console release."
val isReleaseTaskRequested = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true)
}

fun signingProperty(name: String): String =
    keyProperties.getProperty(name)?.takeIf { it.isNotBlank() }
        ?: throw GradleException("Missing `$name` in android/key.properties. $releaseSigningHelp")

if (isReleaseTaskRequested && !keyPropertiesFile.exists()) {
    throw GradleException("Release signing is not configured. $releaseSigningHelp")
}

android {
    namespace = "me.khokan.agecalculator"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications for Java 8+ API desugaring.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "me.khokan.agecalculator"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keyPropertiesFile.exists()) {
                val releaseStoreFile = rootProject.file(signingProperty("storeFile"))
                if (!releaseStoreFile.exists()) {
                    throw GradleException(
                        "Release keystore not found at ${releaseStoreFile.path}. Check the storeFile value in android/key.properties.",
                    )
                }

                storeFile = releaseStoreFile
                storePassword = signingProperty("storePassword")
                keyAlias = signingProperty("keyAlias")
                keyPassword = signingProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            ndk {
                abiFilters += listOf("armeabi-v7a", "arm64-v8a")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
