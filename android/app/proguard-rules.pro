# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }

# Video Player
-keep class com.google.android.exoplayer.** { *; }

# Hive
-keep class io.hive.** { *; }
-keep class hive.** { *; }

# Play Core
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.common.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep your application classes that use native methods
-keep class com.example.a_play.** { *; }

# Play Core Library
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.internal.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.install.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.review.** { *; }
-keepnames class com.google.android.play.core.** { *; }

# Hive
-keep class hive.** { *; }
-keep class io.hive.** { *; }
-keep class hive.core.** { *; }

# Video Player
-keep class io.flutter.plugins.videoplayer.** { *; } 