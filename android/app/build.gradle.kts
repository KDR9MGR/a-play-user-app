import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val googleServicesJsonExists =
    file("google-services.json").exists() ||
        file("src/debug/google-services.json").exists() ||
        file("src/release/google-services.json").exists()

if (googleServicesJsonExists) {
    apply(plugin = "com.google.gms.google-services")
}

android {
    namespace = "com.aplay.a_play"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.aplay.a_play"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        versionCode = 2000403
        versionName = "2.0.4"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    lint {
        disable.add("MissingPermission")
        abortOnError = false
    }

    dependencies {
        implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
        implementation("com.google.firebase:firebase-analytics")
        
        // OneSignal
        implementation("com.onesignal:OneSignal:[5.1.6, 5.1.99]")
    }
}

flutter {
    source = "../.."
}

fun decodeDartDefines(dartDefines: String): List<String> {
    if (dartDefines.isBlank()) return emptyList()
    return dartDefines.split(",")
        .map { it.trim() }
        .filter { it.isNotEmpty() }
        .map { token ->
            val padded = token + "=".repeat((4 - (token.length % 4)) % 4)
            try {
                String(Base64.getDecoder().decode(padded), Charsets.UTF_8)
            } catch (_: Exception) {
                ""
            }
        }
        .filter { it.isNotEmpty() }
}

fun readDotEnvValue(envFile: File, key: String): String? {
    if (!envFile.exists()) return null
    for (rawLine in envFile.readLines()) {
        val line = rawLine.trim()
        if (line.isEmpty() || line.startsWith("#")) continue
        val idx = line.indexOf("=")
        if (idx <= 0) continue
        val k = line.substring(0, idx).trim()
        if (k != key) continue
        return line.substring(idx + 1).trim().trim('"', '\'')
    }
    return null
}

val verifySupabaseConfig by tasks.registering {
    group = "verification"
    description = "Fail release builds if required Supabase config is missing."

    doLast {
        val dartDefines =
            (project.findProperty("dart-defines") as String?) ?: (System.getenv("DART_DEFINES") ?: "")
        val decoded = decodeDartDefines(dartDefines)
        val haveAnonKeyFromDefines =
            decoded.any { it.startsWith("SUPABASE_ANON_KEY=") && it.substringAfter("=", "").isNotBlank() }

        val envFile = rootProject.projectDir.parentFile.resolve(".env")
        val anonKeyFromEnv = readDotEnvValue(envFile, "SUPABASE_ANON_KEY")
        val haveAnonKeyFromEnv = !anonKeyFromEnv.isNullOrBlank()

        if (!haveAnonKeyFromDefines && !haveAnonKeyFromEnv) {
            throw GradleException(
                """
                Missing required Supabase configuration: SUPABASE_ANON_KEY

                Provide it via either:
                - Dart defines (recommended):
                  flutter build appbundle --release --dart-define=SUPABASE_ANON_KEY=...
                - Or a populated .env file at the project root (packaged as an asset)
                """.trimIndent(),
            )
        }
    }
}

tasks.matching { it.name == "assembleRelease" || it.name == "bundleRelease" }.configureEach {
    dependsOn(verifySupabaseConfig)
}
