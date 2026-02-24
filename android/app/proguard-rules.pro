## Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

## Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

## Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

## Google Maps
-keep class com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.maps.**

## Google ML Kit (barcode scanning)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

## Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-dontwarn com.google.android.gms.auth.**

## Zego Express Engine
-keep class im.zego.** { *; }
-dontwarn im.zego.**

## DeepAR
-keep class ai.deepar.** { *; }
-dontwarn ai.deepar.**

## Unity Ads
-keep class com.unity3d.ads.** { *; }
-dontwarn com.unity3d.ads.**

## AppLovin MAX
-keep class com.applovin.** { *; }
-dontwarn com.applovin.**

## Meta Audience Network
-keep class com.facebook.ads.** { *; }
-dontwarn com.facebook.ads.**

## Interactive Media Ads (IMA)
-keep class com.google.ads.interactivemedia.** { *; }
-dontwarn com.google.ads.interactivemedia.**

## Video Player
-keep class io.flutter.plugins.videoplayer.** { *; }
-dontwarn io.flutter.plugins.videoplayer.**

## Video Compress
-keep class com.example.video_compress.** { *; }
-dontwarn com.example.video_compress.**

## FFmpegKit
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.arthenica.mobileffmpeg.** { *; }
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-dontwarn com.arthenica.**
-dontwarn com.antonkarpenko.ffmpegkit.**

## Socket.IO
-keep class io.socket.** { *; }
-dontwarn io.socket.**

## OkHttp (used by various plugins)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**

## Gson (used by various plugins)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

## RevenueCat (purchases_flutter)
-keep class com.revenuecat.** { *; }
-dontwarn com.revenuecat.**

## Geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

## Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

## Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

## Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

## Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

## Suppress warnings for missing classes from optional dependencies
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
