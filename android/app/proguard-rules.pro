# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }

# Keep system and sensors plus classes
-keep class com.google.android.gms.internal.** { *; }
-keep class dev.fluttercommunity.plus.sensors.** { *; }

# Keep Google Mobile Ads classes
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.common.annotation.KeepName { *; }
-keepclassmembers class * {
    @com.google.android.gms.common.annotation.KeepName *;
}
-keepattribs *Annotation*,Signature,InnerClasses,EnclosingMethod
