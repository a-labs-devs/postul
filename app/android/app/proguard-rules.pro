# ProGuard Rules para POSTUL
# Mantém classes necessárias para o funcionamento do app

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-keep class com.google.maps.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# TTS (Text-to-Speech)
-keep class com.tundralabs.fluttertts.** { *; }

# Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Gson (se usado)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Retrofit/OkHttp (se usado)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# Manter atributos para debugging
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*

# Play Core para Flutter deferred components (compatível com SDK 34)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Manter classes de reflection e serialização
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Manter enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Remover logs em produção
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

