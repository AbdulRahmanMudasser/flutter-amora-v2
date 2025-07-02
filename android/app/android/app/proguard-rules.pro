# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Fonts
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class com.google.gson.stream.** { *; }

# Hive
-keep class * extends com.hive.HiveObject { *; }
-keep class * extends com.hive.model.** { *; }

# Your romantic app classes
-keep class com.example.amora.** { *; }
-keep class * extends com.example.amora.model.** { *; }