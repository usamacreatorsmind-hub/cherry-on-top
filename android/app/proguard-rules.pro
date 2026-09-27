# ================================================================
# AGORA SDK HARDENING RULES (Updated — fixes video black-screen
# in release builds while audio works fine)
# ================================================================

# Prevent R8 from failing on missing Play Core classes (common in Flutter)
-dontwarn com.google.android.play.core.**

# Agora RTC SDK
-keep class io.agora.** { *; }
-keep class io.agora.rtc2.** { *; }
-keep class io.agora.base.** { *; }
-keep class io.agora.rtc2.internal.** { *; }
-dontwarn io.agora.**
-keepattributes Signature,Exceptions,*Annotation*

# --- ADDED: Agora video-specific classes ---
# These handle VideoCanvas, texture/surface rendering, and video frame
# callbacks. Audio doesn't route through these, which is exactly why
# audio works but video renders black when these get stripped.
-keep class io.agora.rtc2.video.** { *; }
-keep class io.agora.rtc2.gles.** { *; }
-keep class io.agora.capture.** { *; }
-keep class io.agora.mediaplayer.** { *; }
-keepclassmembers class io.agora.rtc2.RtcEngine { *; }
-keepclassmembers class io.agora.rtc2.video.VideoCanvas { *; }

# --- ADDED: Flutter plugin bridge (agora_rtc_engine) ---
# The Flutter plugin has its own bridge layer between Dart and the
# native Agora SDK — if THIS layer gets stripped, method channel
# calls for video rendering silently fail while simpler audio calls
# (which have a simpler bridge path) keep working.
-keep class io.agora.rtc.** { *; }
-keep class io.agora.agora_rtc_engine.** { *; }
-dontwarn io.agora.rtc.**

# --- ADDED: JNI / native library loading (critical for video codecs) ---
# Video decoding relies on native .so libraries (H.264/VP8 codecs).
# Without keeping these attributes, R8 can strip the JNI registration
# even though the native methods themselves are kept below.
-keepattributes SourceFile,LineNumberTable
-keepclasseswithmembernames class * {
    native <methods>;
}
-keep class * extends java.lang.annotation.Annotation { *; }

# Native Methods & Library Loading (your original rule — kept)
-keepclassmembers class * {
    native <methods>;
}

# --- ADDED: SurfaceView / TextureView renderer classes ---
# Agora's local/remote video views wrap Android's own SurfaceView or
# TextureView. If ProGuard renames/strips supporting fields via
# aggressive optimization, the view binds to the engine but never
# actually paints frames — exactly a "black screen with working audio"
# symptom.
-keep class android.view.TextureView { *; }
-keep class android.view.SurfaceView { *; }
-keep class android.opengl.** { *; }
-dontwarn android.opengl.**

# Flutter Standard Keep Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Razorpay
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Android Hardware & Media Support
-keep class android.media.** { *; }
-keep class android.graphics.** { *; }
-dontwarn android.media.**

# --- ADDED: Prevent R8 from removing "unused" resources tied to
# native rendering surfaces, which can happen with aggressive
# shrinking even when keep rules exist for the classes themselves.
-keepclassmembers class **.R$* {
    public static <fields>;
}