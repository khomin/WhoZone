import com.google.protobuf.gradle.proto
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.protobuf") version "0.9.3"
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties().apply {
    val file = rootProject.file("keystore.properties")
    if (file.exists()) {
        load(FileInputStream(file))
    }
}

android {
    namespace = "com.who.zone"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    signingConfigs {
        create("config") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    sourceSets {
        getByName("main") {
            java {
                srcDir("src/main/kotlin")
                srcDir("build/generated/source/proto/main/java")
            }
            proto {
                srcDir("$projectDir/../../protobuf")
            }
        }
    }
    defaultConfig {
        applicationId = "com.who.zone"
        targetSdk = flutter.targetSdkVersion
        minSdk = 30
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        externalNativeBuild {
            cmake {
                abiFilters.addAll(listOf("arm64-v8a"))
                arguments.addAll(listOf("-DANDROID_ARM_NEON=TRUE", "-DANDROID_TOOLCHAIN=clang", "-DCMAKE_CXX_FLAGS=\"-llog\"", "-DANDROID_STL=c++_shared"))
                cFlags.addAll(listOf("-D__STDC_FORMAT_MACROS -D__ANDROID__ -fPIC -Wl -Bsymbolic"))
                cppFlags.addAll(listOf("-std=c++17", "-fPIC", "-frtti", "-fexceptions", "--build-id", "-Wl", "-Bsymbolic"))
                version = "3.18.0+"
            }
        }
        ndk {
            ldLibs?.add("log")
            abiFilters.addAll(listOf("arm64-v8a"))
        }
    }
    externalNativeBuild {
        cmake {
            path = file("../../cpp/CMakeLists.txt")
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

protobuf {
    protoc {
        artifact = "com.google.protobuf:protoc:4.30.0"
    }
    plugins {
        register("javalite") {
            "com.google.protobuf:protoc-gen-javalite:4.30.0"
        }
    }
    generateProtoTasks {
        all().configureEach {
            builtins {
                create("java") {
                    option("lite")
                }
            }
        }
    }
}

dependencies {
    implementation("com.elvishew:xlog:1.11.1")
    implementation("androidx.fragment:fragment-ktx:1.8.9")
    implementation("com.google.protobuf:protobuf-javalite:4.30.0")
}