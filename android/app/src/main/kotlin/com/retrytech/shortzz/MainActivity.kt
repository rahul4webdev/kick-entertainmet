package com.kick.entertainment

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // DO NOT call super.configureFlutterEngine() — it delegates to
        // GeneratedPluginRegistrant which catches only Exception, not Error.
        // FFmpegKit throws java.lang.Error (UnsatisfiedLinkError) which escapes
        // the catch block and prevents ALL subsequent plugins from registering.
        // Instead, we register each plugin individually with Throwable catching.
        registerAllPlugins(flutterEngine)
    }

    private fun registerAllPlugins(flutterEngine: FlutterEngine) {
        safeAdd(flutterEngine, "app_links") { com.llfbandit.app_links.AppLinksPlugin() }
        safeAdd(flutterEngine, "applovin_max") { com.applovin.applovin_max.AppLovinMAX() }
        safeAdd(flutterEngine, "audio_session") { com.ryanheise.audio_session.AudioSessionPlugin() }
        safeAdd(flutterEngine, "audio_waveforms") { com.simform.audio_waveforms.AudioWaveformsPlugin() }
        safeAdd(flutterEngine, "connectivity_plus") { dev.fluttercommunity.plus.connectivity.ConnectivityPlugin() }
        safeAdd(flutterEngine, "device_info_plus") { dev.fluttercommunity.plus.device_info.DeviceInfoPlusPlugin() }
        safeAdd(flutterEngine, "easy_audience_network") { com.dsi.easy_audience_network.FacebookAudienceNetworkPlugin() }
        safeAdd(flutterEngine, "ffmpeg_kit") { com.antonkarpenko.ffmpegkit.FFmpegKitFlutterPlugin() }
        safeAdd(flutterEngine, "firebase_auth") { io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin() }
        safeAdd(flutterEngine, "firebase_core") { io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin() }
        safeAdd(flutterEngine, "firebase_messaging") { io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin() }
        safeAdd(flutterEngine, "flutter_image_compress") { com.fluttercandies.flutter_image_compress.ImageCompressPlugin() }
        safeAdd(flutterEngine, "flutter_keyboard_visibility") { com.jrai.flutter_keyboard_visibility.FlutterKeyboardVisibilityPlugin() }
        safeAdd(flutterEngine, "flutter_local_notifications") { com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin() }
        safeAdd(flutterEngine, "flutter_native_video_trimmer") { com.example.video_trimmer.VideoTrimmerPlugin() }
        safeAdd(flutterEngine, "flutter_plugin_android_lifecycle") { io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin() }
        safeAdd(flutterEngine, "flutter_secure_storage") { com.it_nomads.fluttersecurestorage.FlutterSecureStoragePlugin() }
        safeAdd(flutterEngine, "flutter_tts") { com.eyedeadevelopment.fluttertts.FlutterTtsPlugin() }
        safeAdd(flutterEngine, "flutter_webrtc") { com.cloudwebrtc.webrtc.FlutterWebRTCPlugin() }
        safeAdd(flutterEngine, "gal") { studio.midoridesign.gal.GalPlugin() }
        safeAdd(flutterEngine, "geocoding_android") { com.baseflow.geocoding.GeocodingPlugin() }
        safeAdd(flutterEngine, "geolocator_android") { com.baseflow.geolocator.GeolocatorPlugin() }
        safeAdd(flutterEngine, "google_maps_flutter_android") { io.flutter.plugins.googlemaps.GoogleMapsPlugin() }
        safeAdd(flutterEngine, "google_mlkit_barcode_scanning") { com.google_mlkit_barcode_scanning.GoogleMlKitBarcodeScanningPlugin() }
        safeAdd(flutterEngine, "google_mlkit_commons") { com.google_mlkit_commons.GoogleMlKitCommonsPlugin() }
        safeAdd(flutterEngine, "google_mobile_ads") { io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin() }
        safeAdd(flutterEngine, "google_sign_in_android") { io.flutter.plugins.googlesignin.GoogleSignInPlugin() }
        safeAdd(flutterEngine, "image_picker_android") { io.flutter.plugins.imagepicker.ImagePickerPlugin() }
        safeAdd(flutterEngine, "interactive_media_ads") { dev.flutter.packages.interactive_media_ads.InteractiveMediaAdsPlugin() }
        safeAdd(flutterEngine, "just_audio") { com.ryanheise.just_audio.JustAudioPlugin() }
        safeAdd(flutterEngine, "livekit_client") { io.livekit.plugin.LiveKitPlugin() }
        safeAdd(flutterEngine, "media_kit_libs_android_video") { com.alexmercerind.media_kit_libs_android_video.MediaKitLibsAndroidVideoPlugin() }
        safeAdd(flutterEngine, "media_kit_video") { com.alexmercerind.media_kit_video.MediaKitVideoPlugin() }
        safeAdd(flutterEngine, "mobile_scanner") { dev.steenbakker.mobile_scanner.MobileScannerPlugin() }
        safeAdd(flutterEngine, "package_info_plus") { dev.fluttercommunity.plus.packageinfo.PackageInfoPlugin() }
        safeAdd(flutterEngine, "path_provider_android") { io.flutter.plugins.pathprovider.PathProviderPlugin() }
        safeAdd(flutterEngine, "permission_handler_android") { com.baseflow.permissionhandler.PermissionHandlerPlugin() }
        safeAdd(flutterEngine, "purchases_flutter") { com.revenuecat.purchases_flutter.PurchasesFlutterPlugin() }
        safeAdd(flutterEngine, "retrytech_plugin") { com.retrytech.retrytech_plugin.RetrytechPlugin() }
        safeAdd(flutterEngine, "share_plus") { dev.fluttercommunity.plus.share.SharePlusPlugin() }
        safeAdd(flutterEngine, "sign_in_with_apple") { com.aboutyou.dart_packages.sign_in_with_apple.SignInWithApplePlugin() }
        safeAdd(flutterEngine, "sqflite_android") { com.tekartik.sqflite.SqflitePlugin() }
        safeAdd(flutterEngine, "unity_ads_plugin") { com.rebeloid.unity_ads.UnityAdsPlugin() }
        safeAdd(flutterEngine, "url_launcher_android") { io.flutter.plugins.urllauncher.UrlLauncherPlugin() }
        safeAdd(flutterEngine, "video_compress") { com.example.video_compress.VideoCompressPlugin() }
        safeAdd(flutterEngine, "video_player_android") { io.flutter.plugins.videoplayer.VideoPlayerPlugin() }
        safeAdd(flutterEngine, "wakelock_plus") { dev.fluttercommunity.plus.wakelock.WakelockPlusPlugin() }
        safeAdd(flutterEngine, "webview_flutter_android") { io.flutter.plugins.webviewflutter.WebViewFlutterPlugin() }
    }

    private inline fun safeAdd(flutterEngine: FlutterEngine, name: String, factory: () -> FlutterPlugin) {
        try {
            flutterEngine.plugins.add(factory())
        } catch (t: Throwable) {
            Log.e(TAG, "Failed to register plugin $name: ${t.message}")
        }
    }
}
