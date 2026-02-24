// To parse this JSON data, do
//
//     final settingModel = settingModelFromJson(jsonString);

import 'dart:convert';

import 'package:shortzz/model/user_model/user_model.dart';

int? _toBoolInt(dynamic v) =>
    v is bool ? (v ? 1 : 0) : (v is int ? v : null);

SettingModel settingModelFromJson(String str) =>
    SettingModel.fromJson(json.decode(str));

String settingModelToJson(SettingModel data) => json.encode(data.toJson());

class SettingModel {
  bool? status;
  String? message;
  Setting? data;

  SettingModel({
    this.status,
    this.message,
    this.data,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) => SettingModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Setting.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Setting {
  int? id;
  String? appName;
  String? currency;
  double? coinValue;
  int? minRedeemCoins;
  int? registrationBonusStatus;
  int? registrationBonusAmount;
  int? minFollowersForLive;
  String? admobBanner;
  String? admobInt;
  String? admobBannerIos;
  String? admobIntIos;
  int? admobAndroidStatus;
  int? admobIosStatus;
  int? maxUploadDaily;
  int? maxStoryDaily;
  int? maxCommentDaily;
  int? maxCommentReplyDaily;
  int? maxPostPins;
  int? maxCommentPins;
  int? maxImagesPerPost;
  int? maxUserLinks;
  int? liveMinViewers;
  int? liveTimeout;
  int? liveBattle;
  int? liveMaxGuests;
  int? liveDummyShow;
  String? livekitHost;
  String? livekitApiKey;
  String? livekitApiSecret;
  int? isCompress;
  int? isCameraEffects;
  String? snapCameraKitAppId;
  String? snapCameraKitApiToken;
  String? snapCameraKitGroupId;
  int? isWithdrawalOn;
  double? commissionPercentage;
  int? minFollowersForMonetization;
  int? rewardCoinsPerAd;
  int? maxRewardedAdsDaily;
  String? admobRewardedAndroid;
  String? admobRewardedIos;
  // Meta Audience Network
  bool? metaAdsEnabled;
  String? metaBannerAndroid;
  String? metaBannerIos;
  String? metaInterstitialAndroid;
  String? metaInterstitialIos;
  String? metaRewardedAndroid;
  String? metaRewardedIos;
  // Unity Ads
  bool? unityAdsEnabled;
  String? unityGameIdAndroid;
  String? unityGameIdIos;
  String? unityBannerAndroid;
  String? unityBannerIos;
  String? unityInterstitialAndroid;
  String? unityInterstitialIos;
  String? unityRewardedAndroid;
  String? unityRewardedIos;
  // AppLovin
  bool? applovinEnabled;
  String? applovinSdkKey;
  String? applovinBannerAndroid;
  String? applovinBannerIos;
  String? applovinInterstitialAndroid;
  String? applovinInterstitialIos;
  String? applovinRewardedAndroid;
  String? applovinRewardedIos;
  // Waterfall Priority
  List<String>? waterfallBannerPriority;
  List<String>? waterfallInterstitialPriority;
  List<String>? waterfallRewardedPriority;
  // IMA Pre-Roll
  int? imaPreRollFrequency;
  String? imaAdTagAndroid;
  String? imaAdTagIos;
  // IMA Mid-Roll
  int? imaMidRollFrequency;
  String? imaMidRollAdTagAndroid;
  String? imaMidRollAdTagIos;
  // IMA Post-Roll
  int? imaPostRollFrequency;
  String? imaPostRollAdTagAndroid;
  String? imaPostRollAdTagIos;
  // VAST Ad Controls
  bool? imaPrerollEnabled;
  bool? imaMidrollEnabled;
  bool? imaPostrollEnabled;
  int? imaPrerollMinVideoLength;
  int? imaMidrollMinVideoLength;
  int? imaPostrollMinVideoLength;
  int? imaPreloadSecondsBefore;
  // VAST Feed Video Ads
  bool? vastFeedAdEnabled;
  String? vastFeedAdTagAndroid;
  String? vastFeedAdTagIos;
  // Native Ad Feed
  bool? nativeAdFeedEnabled;
  String? admobNativeAndroid;
  String? admobNativeIos;
  int? nativeAdMinInterval;
  int? nativeAdMaxInterval;
  // Part Transition Ads
  bool? partTransitionAdEnabled;
  int? partTransitionAdStartAt;
  int? partTransitionAdInterval;
  // Creator Monetization
  double? ecpmRate;
  int? creatorRevenueShare;
  // App Open Ad
  bool? appOpenAdEnabled;
  String? admobAppOpenAndroid;
  String? admobAppOpenIos;
  // Custom App Open Ad
  bool? customAppOpenAdEnabled;
  int? customAppOpenAdPostId;
  int? customAppOpenAdSkipSeconds;
  String? customAppOpenAdUrl;
  // Instagram Import
  bool? instagramImportEnabled;
  String? instagramAppId;
  String? instagramRedirectUri;
  String? helpMail;
  int? isContentModeration;
  String? moderationCloudflareUrl;
  String? moderationCloudflareToken;
  String? moderationSelfHostedUrl;
  int? gifSupport;
  String? giphyKey;
  int? watermarkStatus;
  String? watermarkImage;
  String? privacyPolicy;
  String? termsOfUses;
  String? placeApiAccessToken;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? itemBaseUrl;
  List<Language>? languages;
  List<OnBoarding>? onBoarding;
  List<CoinPackage>? coinPackages;
  List<RedeemGateway>? redeemGateways;
  List<Gift>? gifts;
  List<MusicCategory>? musicCategories;
  List<UserLevel>? userLevels;
  List<DummyLive>? dummyLives;
  List<ReportReason>? reportReason;
  List<ColorFilterPreset>? colorFilters;
  List<FaceStickerPreset>? faceStickers;
  // Custom Auth
  int? emailVerificationEnabled;

  Setting({
    this.id,
    this.appName,
    this.currency,
    this.coinValue,
    this.minRedeemCoins,
    this.minFollowersForLive,
    this.registrationBonusStatus,
    this.registrationBonusAmount,
    this.admobBanner,
    this.admobInt,
    this.admobBannerIos,
    this.admobIntIos,
    this.admobAndroidStatus,
    this.admobIosStatus,
    this.maxUploadDaily,
    this.maxStoryDaily,
    this.maxCommentDaily,
    this.maxCommentReplyDaily,
    this.maxPostPins,
    this.maxCommentPins,
    this.maxImagesPerPost,
    this.maxUserLinks,
    this.liveMinViewers,
    this.liveTimeout,
    this.liveBattle,
    this.liveMaxGuests,
    this.liveDummyShow,
    this.livekitHost,
    this.livekitApiKey,
    this.livekitApiSecret,
    this.isCompress,
    this.isCameraEffects,
    this.snapCameraKitAppId,
    this.snapCameraKitApiToken,
    this.snapCameraKitGroupId,
    this.isWithdrawalOn,
    this.commissionPercentage,
    this.minFollowersForMonetization,
    this.rewardCoinsPerAd,
    this.maxRewardedAdsDaily,
    this.admobRewardedAndroid,
    this.admobRewardedIos,
    this.metaAdsEnabled,
    this.metaBannerAndroid,
    this.metaBannerIos,
    this.metaInterstitialAndroid,
    this.metaInterstitialIos,
    this.metaRewardedAndroid,
    this.metaRewardedIos,
    this.unityAdsEnabled,
    this.unityGameIdAndroid,
    this.unityGameIdIos,
    this.unityBannerAndroid,
    this.unityBannerIos,
    this.unityInterstitialAndroid,
    this.unityInterstitialIos,
    this.unityRewardedAndroid,
    this.unityRewardedIos,
    this.applovinEnabled,
    this.applovinSdkKey,
    this.applovinBannerAndroid,
    this.applovinBannerIos,
    this.applovinInterstitialAndroid,
    this.applovinInterstitialIos,
    this.applovinRewardedAndroid,
    this.applovinRewardedIos,
    this.waterfallBannerPriority,
    this.waterfallInterstitialPriority,
    this.waterfallRewardedPriority,
    this.imaPreRollFrequency,
    this.imaAdTagAndroid,
    this.imaAdTagIos,
    this.imaMidRollFrequency,
    this.imaMidRollAdTagAndroid,
    this.imaMidRollAdTagIos,
    this.imaPostRollFrequency,
    this.imaPostRollAdTagAndroid,
    this.imaPostRollAdTagIos,
    this.imaPrerollEnabled,
    this.imaMidrollEnabled,
    this.imaPostrollEnabled,
    this.imaPrerollMinVideoLength,
    this.imaMidrollMinVideoLength,
    this.imaPostrollMinVideoLength,
    this.imaPreloadSecondsBefore,
    this.vastFeedAdEnabled,
    this.vastFeedAdTagAndroid,
    this.vastFeedAdTagIos,
    this.nativeAdFeedEnabled,
    this.admobNativeAndroid,
    this.admobNativeIos,
    this.nativeAdMinInterval,
    this.nativeAdMaxInterval,
    this.partTransitionAdEnabled,
    this.partTransitionAdStartAt,
    this.partTransitionAdInterval,
    this.ecpmRate,
    this.creatorRevenueShare,
    this.appOpenAdEnabled,
    this.admobAppOpenAndroid,
    this.admobAppOpenIos,
    this.customAppOpenAdEnabled,
    this.customAppOpenAdPostId,
    this.customAppOpenAdSkipSeconds,
    this.customAppOpenAdUrl,
    this.instagramImportEnabled,
    this.instagramAppId,
    this.instagramRedirectUri,
    this.helpMail,
    this.isContentModeration,
    this.moderationCloudflareUrl,
    this.moderationCloudflareToken,
    this.moderationSelfHostedUrl,
    this.gifSupport,
    this.giphyKey,
    this.watermarkStatus,
    this.watermarkImage,
    this.privacyPolicy,
    this.termsOfUses,
    this.placeApiAccessToken,
    this.createdAt,
    this.updatedAt,
    this.itemBaseUrl,
    this.languages,
    this.onBoarding,
    this.coinPackages,
    this.redeemGateways,
    this.gifts,
    this.musicCategories,
    this.userLevels,
    this.dummyLives,
    this.reportReason,
    this.colorFilters,
    this.faceStickers,
    this.emailVerificationEnabled,
  });

  factory Setting.fromJson(Map<String, dynamic> json) => Setting(
        id: json["id"],
        appName: json["app_name"],
        currency: json["currency"],
        registrationBonusStatus: _toBoolInt(json["registration_bonus_status"]),
        registrationBonusAmount: _toBoolInt(json["registration_bonus_amount"]),
        coinValue: json["coin_value"] != null ? double.tryParse(json["coin_value"].toString()) : null,
        minRedeemCoins: _toBoolInt(json["min_redeem_coins"]),
        minFollowersForLive: _toBoolInt(json["min_followers_for_live"]),
        admobBanner: json["admob_banner"],
        admobInt: json["admob_int"],
        admobBannerIos: json["admob_banner_ios"],
        admobIntIos: json["admob_int_ios"],
        admobAndroidStatus: _toBoolInt(json["admob_android_status"]),
        admobIosStatus: _toBoolInt(json["admob_ios_status"]),
        maxUploadDaily: _toBoolInt(json["max_upload_daily"]),
        maxStoryDaily: _toBoolInt(json["max_story_daily"]),
        maxCommentDaily: _toBoolInt(json["max_comment_daily"]),
        maxCommentReplyDaily: _toBoolInt(json["max_comment_reply_daily"]),
        maxPostPins: _toBoolInt(json["max_post_pins"]),
        maxCommentPins: _toBoolInt(json["max_comment_pins"]),
        maxImagesPerPost: _toBoolInt(json["max_images_per_post"]),
        maxUserLinks: _toBoolInt(json["max_user_links"]),
        liveMinViewers: _toBoolInt(json["live_min_viewers"]),
        liveTimeout: _toBoolInt(json["live_timeout"]),
        liveMaxGuests: _toBoolInt(json["live_max_guests"]),
        liveBattle: _toBoolInt(json["live_battle"]),
        liveDummyShow: _toBoolInt(json["live_dummy_show"]),
        livekitHost: json["livekit_host"],
        livekitApiKey: json["livekit_api_key"],
        livekitApiSecret: json["livekit_api_secret"],
        isCompress: _toBoolInt(json["is_compress"]),
        isCameraEffects: _toBoolInt(json["is_camera_effects"]),
        snapCameraKitAppId: json["snap_camera_kit_app_id"],
        snapCameraKitApiToken: json["snap_camera_kit_api_token"],
        snapCameraKitGroupId: json["snap_camera_kit_group_id"],
        isWithdrawalOn: _toBoolInt(json["is_withdrawal_on"]),
        commissionPercentage: json["commission_percentage"] != null ? double.tryParse(json["commission_percentage"].toString()) : null,
        minFollowersForMonetization: _toBoolInt(json["min_followers_for_monetization"]),
        rewardCoinsPerAd: _toBoolInt(json["reward_coins_per_ad"]),
        maxRewardedAdsDaily: _toBoolInt(json["max_rewarded_ads_daily"]),
        admobRewardedAndroid: json["admob_rewarded_android"],
        admobRewardedIos: json["admob_rewarded_ios"],
        metaAdsEnabled: json["meta_ads_enabled"] == true || json["meta_ads_enabled"] == 1,
        metaBannerAndroid: json["meta_banner_android"],
        metaBannerIos: json["meta_banner_ios"],
        metaInterstitialAndroid: json["meta_interstitial_android"],
        metaInterstitialIos: json["meta_interstitial_ios"],
        metaRewardedAndroid: json["meta_rewarded_android"],
        metaRewardedIos: json["meta_rewarded_ios"],
        unityAdsEnabled: json["unity_ads_enabled"] == true || json["unity_ads_enabled"] == 1,
        unityGameIdAndroid: json["unity_game_id_android"],
        unityGameIdIos: json["unity_game_id_ios"],
        unityBannerAndroid: json["unity_banner_android"],
        unityBannerIos: json["unity_banner_ios"],
        unityInterstitialAndroid: json["unity_interstitial_android"],
        unityInterstitialIos: json["unity_interstitial_ios"],
        unityRewardedAndroid: json["unity_rewarded_android"],
        unityRewardedIos: json["unity_rewarded_ios"],
        applovinEnabled: json["applovin_enabled"] == true || json["applovin_enabled"] == 1,
        applovinSdkKey: json["applovin_sdk_key"],
        applovinBannerAndroid: json["applovin_banner_android"],
        applovinBannerIos: json["applovin_banner_ios"],
        applovinInterstitialAndroid: json["applovin_interstitial_android"],
        applovinInterstitialIos: json["applovin_interstitial_ios"],
        applovinRewardedAndroid: json["applovin_rewarded_android"],
        applovinRewardedIos: json["applovin_rewarded_ios"],
        waterfallBannerPriority: json["waterfall_banner_priority"] != null
            ? (json["waterfall_banner_priority"] is String
                ? List<String>.from(jsonDecode(json["waterfall_banner_priority"]))
                : List<String>.from(json["waterfall_banner_priority"]))
            : null,
        waterfallInterstitialPriority: json["waterfall_interstitial_priority"] != null
            ? (json["waterfall_interstitial_priority"] is String
                ? List<String>.from(jsonDecode(json["waterfall_interstitial_priority"]))
                : List<String>.from(json["waterfall_interstitial_priority"]))
            : null,
        waterfallRewardedPriority: json["waterfall_rewarded_priority"] != null
            ? (json["waterfall_rewarded_priority"] is String
                ? List<String>.from(jsonDecode(json["waterfall_rewarded_priority"]))
                : List<String>.from(json["waterfall_rewarded_priority"]))
            : null,
        imaPreRollFrequency: _toBoolInt(json["ima_preroll_frequency"]),
        imaAdTagAndroid: json["ima_ad_tag_android"],
        imaAdTagIos: json["ima_ad_tag_ios"],
        imaMidRollFrequency: _toBoolInt(json["ima_midroll_frequency"]),
        imaMidRollAdTagAndroid: json["ima_midroll_ad_tag_android"],
        imaMidRollAdTagIos: json["ima_midroll_ad_tag_ios"],
        imaPostRollFrequency: _toBoolInt(json["ima_postroll_frequency"]),
        imaPostRollAdTagAndroid: json["ima_postroll_ad_tag_android"],
        imaPostRollAdTagIos: json["ima_postroll_ad_tag_ios"],
        imaPrerollEnabled: json["ima_preroll_enabled"] == 1 || json["ima_preroll_enabled"] == true,
        imaMidrollEnabled: json["ima_midroll_enabled"] == 1 || json["ima_midroll_enabled"] == true,
        imaPostrollEnabled: json["ima_postroll_enabled"] == 1 || json["ima_postroll_enabled"] == true,
        imaPrerollMinVideoLength: _toBoolInt(json["ima_preroll_min_video_length"]),
        imaMidrollMinVideoLength: _toBoolInt(json["ima_midroll_min_video_length"]),
        imaPostrollMinVideoLength: _toBoolInt(json["ima_postroll_min_video_length"]),
        imaPreloadSecondsBefore: _toBoolInt(json["ima_preload_seconds_before"]),
        vastFeedAdEnabled: json["vast_feed_ad_enabled"] == 1 || json["vast_feed_ad_enabled"] == true,
        vastFeedAdTagAndroid: json["vast_feed_ad_tag_android"],
        vastFeedAdTagIos: json["vast_feed_ad_tag_ios"],
        nativeAdFeedEnabled: json["native_ad_feed_enabled"] == 1 || json["native_ad_feed_enabled"] == true,
        admobNativeAndroid: json["admob_native_android"],
        admobNativeIos: json["admob_native_ios"],
        nativeAdMinInterval: _toBoolInt(json["native_ad_min_interval"]),
        nativeAdMaxInterval: _toBoolInt(json["native_ad_max_interval"]),
        partTransitionAdEnabled: json["part_transition_ad_enabled"] == 1 || json["part_transition_ad_enabled"] == true,
        partTransitionAdStartAt: _toBoolInt(json["part_transition_ad_start_at"]),
        partTransitionAdInterval: _toBoolInt(json["part_transition_ad_interval"]),
        ecpmRate: (json["ecpm_rate"] is num) ? (json["ecpm_rate"] as num).toDouble() : double.tryParse('${json["ecpm_rate"]}'),
        creatorRevenueShare: _toBoolInt(json["creator_revenue_share"]),
        appOpenAdEnabled: json["app_open_ad_enabled"] == 1 || json["app_open_ad_enabled"] == true,
        admobAppOpenAndroid: json["admob_app_open_android"],
        admobAppOpenIos: json["admob_app_open_ios"],
        customAppOpenAdEnabled: json["custom_app_open_ad_enabled"] == 1 || json["custom_app_open_ad_enabled"] == true,
        customAppOpenAdPostId: _toBoolInt(json["custom_app_open_ad_post_id"]),
        customAppOpenAdSkipSeconds: _toBoolInt(json["custom_app_open_ad_skip_seconds"]) ?? 5,
        customAppOpenAdUrl: json["custom_app_open_ad_url"],
        instagramImportEnabled: json["instagram_import_enabled"] == 1 || json["instagram_import_enabled"] == true,
        instagramAppId: json["instagram_app_id"],
        instagramRedirectUri: json["instagram_redirect_uri"],
        helpMail: json["help_mail"],
        isContentModeration: _toBoolInt(json["is_content_moderation"]),
        moderationCloudflareUrl: json["moderation_cloudflare_url"],
        moderationCloudflareToken: json["moderation_cloudflare_token"],
        moderationSelfHostedUrl: json["moderation_self_hosted_url"],
        gifSupport: _toBoolInt(json["gif_support"]),
        giphyKey: json["giphy_key"],
        watermarkStatus: _toBoolInt(json["watermark_status"]),
        watermarkImage: json["watermark_image"],
        privacyPolicy: json["privacy_policy"],
        termsOfUses: json["terms_of_uses"],
        placeApiAccessToken: json["place_api_access_token"],
        itemBaseUrl: json["itemBaseUrl"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        languages: json["languages"] == null
            ? []
            : List<Language>.from(
                json["languages"]?.map((x) => Language.fromJson(x))),
        onBoarding: json["onBoarding"] == null
            ? []
            : List<OnBoarding>.from(
                json["onBoarding"]?.map((x) => OnBoarding.fromJson(x))),
        coinPackages: json["coinPackages"] == null
            ? []
            : List<CoinPackage>.from(
                json["coinPackages"]?.map((x) => CoinPackage.fromJson(x))),
        redeemGateways: json["redeemGateways"] == null
            ? []
            : List<RedeemGateway>.from(
                json["redeemGateways"]?.map((x) => RedeemGateway.fromJson(x))),
        gifts: json["gifts"] == null
            ? []
            : List<Gift>.from(json["gifts"]?.map((x) => Gift.fromJson(x))),
        musicCategories: json["musicCategories"] == null
            ? []
            : List<MusicCategory>.from(
                json["musicCategories"]?.map((x) => MusicCategory.fromJson(x))),
        userLevels: json["userLevels"] == null
            ? []
            : List<UserLevel>.from(
                json["userLevels"]?.map((x) => UserLevel.fromJson(x))),
        dummyLives: json["dummyLives"] == null
            ? []
            : List<DummyLive>.from(
                json["dummyLives"]?.map((x) => DummyLive.fromJson(x))),
        reportReason: json["reportReasons"] == null
            ? []
            : List<ReportReason>.from(
                json["reportReasons"]?.map((x) => ReportReason.fromJson(x))),
        colorFilters: json["colorFilters"] == null
            ? []
            : List<ColorFilterPreset>.from(
                json["colorFilters"]?.map((x) => ColorFilterPreset.fromJson(x))),
        faceStickers: json["faceStickers"] == null
            ? []
            : List<FaceStickerPreset>.from(
                json["faceStickers"]?.map((x) => FaceStickerPreset.fromJson(x))),
        emailVerificationEnabled: _toBoolInt(json["email_verification_enabled"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "app_name": appName,
        "currency": currency,
        "registration_bonus_status": registrationBonusStatus,
        "registration_bonus_amount": registrationBonusAmount,
        "coin_value": coinValue,
        "min_redeem_coins": minRedeemCoins,
        "min_followers_for_live": minFollowersForLive,
        "admob_banner": admobBanner,
        "admob_int": admobInt,
        "admob_banner_ios": admobBannerIos,
        "admob_int_ios": admobIntIos,
        "admob_android_status": admobAndroidStatus,
        "admob_ios_status": admobIosStatus,
        "max_upload_daily": maxUploadDaily,
        "max_story_daily": maxStoryDaily,
        "max_comment_daily": maxCommentDaily,
        "max_comment_reply_daily": maxCommentReplyDaily,
        "max_post_pins": maxPostPins,
        "max_comment_pins": maxCommentPins,
        "max_images_per_post": maxImagesPerPost,
        "max_user_links": maxUserLinks,
        "live_min_viewers": liveMinViewers,
        "live_timeout": liveTimeout,
        "live_max_guests": liveMaxGuests,
        "live_battle": liveBattle,
        "live_dummy_show": liveDummyShow,
        "livekit_host": livekitHost,
        "livekit_api_key": livekitApiKey,
        "livekit_api_secret": livekitApiSecret,
        "is_compress": isCompress,
        "is_camera_effects": isCameraEffects,
        "snap_camera_kit_app_id": snapCameraKitAppId,
        "snap_camera_kit_api_token": snapCameraKitApiToken,
        "snap_camera_kit_group_id": snapCameraKitGroupId,
        "is_withdrawal_on": isWithdrawalOn,
        "commission_percentage": commissionPercentage,
        "min_followers_for_monetization": minFollowersForMonetization,
        "reward_coins_per_ad": rewardCoinsPerAd,
        "max_rewarded_ads_daily": maxRewardedAdsDaily,
        "admob_rewarded_android": admobRewardedAndroid,
        "admob_rewarded_ios": admobRewardedIos,
        "meta_ads_enabled": metaAdsEnabled,
        "meta_banner_android": metaBannerAndroid,
        "meta_banner_ios": metaBannerIos,
        "meta_interstitial_android": metaInterstitialAndroid,
        "meta_interstitial_ios": metaInterstitialIos,
        "meta_rewarded_android": metaRewardedAndroid,
        "meta_rewarded_ios": metaRewardedIos,
        "unity_ads_enabled": unityAdsEnabled,
        "unity_game_id_android": unityGameIdAndroid,
        "unity_game_id_ios": unityGameIdIos,
        "unity_banner_android": unityBannerAndroid,
        "unity_banner_ios": unityBannerIos,
        "unity_interstitial_android": unityInterstitialAndroid,
        "unity_interstitial_ios": unityInterstitialIos,
        "unity_rewarded_android": unityRewardedAndroid,
        "unity_rewarded_ios": unityRewardedIos,
        "applovin_enabled": applovinEnabled,
        "applovin_sdk_key": applovinSdkKey,
        "applovin_banner_android": applovinBannerAndroid,
        "applovin_banner_ios": applovinBannerIos,
        "applovin_interstitial_android": applovinInterstitialAndroid,
        "applovin_interstitial_ios": applovinInterstitialIos,
        "applovin_rewarded_android": applovinRewardedAndroid,
        "applovin_rewarded_ios": applovinRewardedIos,
        "waterfall_banner_priority": waterfallBannerPriority,
        "waterfall_interstitial_priority": waterfallInterstitialPriority,
        "waterfall_rewarded_priority": waterfallRewardedPriority,
        "ima_preroll_frequency": imaPreRollFrequency,
        "ima_ad_tag_android": imaAdTagAndroid,
        "ima_ad_tag_ios": imaAdTagIos,
        "ima_midroll_frequency": imaMidRollFrequency,
        "ima_midroll_ad_tag_android": imaMidRollAdTagAndroid,
        "ima_midroll_ad_tag_ios": imaMidRollAdTagIos,
        "ima_postroll_frequency": imaPostRollFrequency,
        "ima_postroll_ad_tag_android": imaPostRollAdTagAndroid,
        "ima_postroll_ad_tag_ios": imaPostRollAdTagIos,
        "ima_preroll_enabled": imaPrerollEnabled,
        "ima_midroll_enabled": imaMidrollEnabled,
        "ima_postroll_enabled": imaPostrollEnabled,
        "ima_preroll_min_video_length": imaPrerollMinVideoLength,
        "ima_midroll_min_video_length": imaMidrollMinVideoLength,
        "ima_postroll_min_video_length": imaPostrollMinVideoLength,
        "ima_preload_seconds_before": imaPreloadSecondsBefore,
        "vast_feed_ad_enabled": vastFeedAdEnabled,
        "vast_feed_ad_tag_android": vastFeedAdTagAndroid,
        "vast_feed_ad_tag_ios": vastFeedAdTagIos,
        "native_ad_feed_enabled": nativeAdFeedEnabled,
        "admob_native_android": admobNativeAndroid,
        "admob_native_ios": admobNativeIos,
        "native_ad_min_interval": nativeAdMinInterval,
        "native_ad_max_interval": nativeAdMaxInterval,
        "part_transition_ad_enabled": partTransitionAdEnabled,
        "part_transition_ad_start_at": partTransitionAdStartAt,
        "part_transition_ad_interval": partTransitionAdInterval,
        "ecpm_rate": ecpmRate,
        "creator_revenue_share": creatorRevenueShare,
        "app_open_ad_enabled": appOpenAdEnabled,
        "admob_app_open_android": admobAppOpenAndroid,
        "admob_app_open_ios": admobAppOpenIos,
        "custom_app_open_ad_enabled": customAppOpenAdEnabled,
        "custom_app_open_ad_post_id": customAppOpenAdPostId,
        "custom_app_open_ad_skip_seconds": customAppOpenAdSkipSeconds,
        "custom_app_open_ad_url": customAppOpenAdUrl,
        "instagram_import_enabled": instagramImportEnabled,
        "instagram_app_id": instagramAppId,
        "instagram_redirect_uri": instagramRedirectUri,
        "help_mail": helpMail,
        "is_content_moderation": isContentModeration,
        "moderation_cloudflare_url": moderationCloudflareUrl,
        "moderation_cloudflare_token": moderationCloudflareToken,
        "moderation_self_hosted_url": moderationSelfHostedUrl,
        "gif_support": gifSupport,
        "giphy_key": giphyKey,
        "watermark_status": watermarkStatus,
        "watermark_image": watermarkImage,
        "privacy_policy": privacyPolicy,
        "terms_of_uses": termsOfUses,
        "place_api_access_token": placeApiAccessToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "itemBaseUrl": itemBaseUrl,
        "languages": languages == null
            ? []
            : List<dynamic>.from(languages!.map((x) => x.toJson())),
        "onBoarding": onBoarding == null
            ? []
            : List<dynamic>.from(onBoarding!.map((x) => x.toJson())),
        "coinPackages": coinPackages == null
            ? []
            : List<dynamic>.from(coinPackages!.map((x) => x.toJson())),
        "redeemGateways": redeemGateways == null
            ? []
            : List<dynamic>.from(redeemGateways!.map((x) => x.toJson())),
        "gifts": gifts == null
            ? []
            : List<dynamic>.from(gifts!.map((x) => x.toJson())),
        "musicCategories": musicCategories == null
            ? []
            : List<dynamic>.from(musicCategories!.map((x) => x.toJson())),
        "userLevels": userLevels == null
            ? []
            : List<dynamic>.from(userLevels!.map((x) => x.toJson())),
        "dummyLives": dummyLives == null
            ? []
            : List<dynamic>.from(dummyLives!.map((x) => x.toJson())),
        "reportReasons": reportReason == null
            ? []
            : List<dynamic>.from(reportReason!.map((x) => x.toJson())),
        "colorFilters": colorFilters == null
            ? []
            : List<dynamic>.from(colorFilters!.map((x) => x.toJson())),
        "faceStickers": faceStickers == null
            ? []
            : List<dynamic>.from(faceStickers!.map((x) => x.toJson())),
        "email_verification_enabled": emailVerificationEnabled,
      };
}

class CoinPackage {
  int? id;
  String? image;
  int? status;
  int? coinAmount;
  int? coinPlanPrice;
  String? playStoreProductId;
  String? appstoreProductId;
  DateTime? createdAt;
  DateTime? updatedAt;

  CoinPackage({
    this.id,
    this.image,
    this.status,
    this.coinAmount,
    this.coinPlanPrice,
    this.playStoreProductId,
    this.appstoreProductId,
    this.createdAt,
    this.updatedAt,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) => CoinPackage(
        id: json["id"],
        image: json["image"],
        status: _toBoolInt(json["status"]),
        coinAmount: _toBoolInt(json["coin_amount"]),
        coinPlanPrice: _toBoolInt(json["coin_plan_price"]),
        playStoreProductId: json["playstore_product_id"],
        appstoreProductId: json["appstore_product_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "status": status,
        "coin_amount": coinAmount,
        "coin_plan_price": coinPlanPrice,
        "playstore_product_id": playStoreProductId,
        "appstore_product_id": appstoreProductId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class DummyLive {
  int? id;
  int? status;
  String? title;
  int? userId;
  String? link;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? user;

  DummyLive({
    this.id,
    this.status,
    this.title,
    this.userId,
    this.link,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory DummyLive.fromJson(Map<String, dynamic> json) => DummyLive(
        id: json["id"],
        status: _toBoolInt(json["status"]),
        title: json["title"],
        userId: _toBoolInt(json["user_id"]),
        link: json["link"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "title": title,
        "user_id": userId,
        "link": link,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "user": user?.toJson(),
      };
}

class Gift {
  int? id;
  int? coinPrice;
  String? image;
  DateTime? createdAt;
  DateTime? updatedAt;

  Gift({
    this.id,
    this.coinPrice,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Gift.fromJson(Map<String, dynamic> json) => Gift(
        id: json["id"],
        coinPrice: _toBoolInt(json["coin_price"]),
        image: json["image"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "coin_price": coinPrice,
        "image": image,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Language {
  int? id;
  String? code;
  String? title;
  String? localizedTitle;
  String? csvFile;
  int? status;
  int? isDefault;
  DateTime? createdAt;
  DateTime? updatedAt;

  Language({
    this.id,
    this.code,
    this.title,
    this.localizedTitle,
    this.csvFile,
    this.status,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json["id"],
        code: json["code"],
        title: json["title"],
        localizedTitle: json["localized_title"],
        csvFile: json["csv_file"],
        status: _toBoolInt(json["status"]),
        isDefault: _toBoolInt(json["is_default"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "title": title,
        "localized_title": localizedTitle,
        "csv_file": csvFile,
        "status": status,
        "is_default": isDefault,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class MusicCategory {
  int? id;
  String? name;
  String? image;
  int? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? musicsCount;

  MusicCategory({
    this.id,
    this.name,
    this.image,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.musicsCount,
  });

  factory MusicCategory.fromJson(Map<String, dynamic> json) => MusicCategory(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        isDeleted: _toBoolInt(json["is_deleted"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        musicsCount: _toBoolInt(json["musics_count"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "is_deleted": isDeleted,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "musics_count": musicsCount,
      };
}

class OnBoarding {
  int? id;
  int? position;
  String? image;
  String? title;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;

  OnBoarding({
    this.id,
    this.position,
    this.image,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory OnBoarding.fromJson(Map<String, dynamic> json) => OnBoarding(
        id: json["id"],
        position: _toBoolInt(json["position"]),
        image: json["image"],
        title: json["title"],
        description: json["description"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "position": position,
        "image": image,
        "title": title,
        "description": description,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class RedeemGateway {
  int? id;
  String? title;
  DateTime? createdAt;
  DateTime? updatedAt;

  RedeemGateway({
    this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  factory RedeemGateway.fromJson(Map<String, dynamic> json) => RedeemGateway(
        id: json["id"],
        title: json["title"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class UserLevel {
  int? id;
  int? level;
  int coinsCollection;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserLevel({
    this.id,
    this.level,
    this.coinsCollection = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory UserLevel.fromJson(Map<String, dynamic> json) => UserLevel(
        id: json["id"],
        level: _toBoolInt(json["level"]),
        coinsCollection: _toBoolInt(json["coins_collection"]) ?? 0,
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "level": level,
        "coins_collection": coinsCollection,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class ReportReason {
  int? id;
  String? title;
  String? createdAt;
  String? updatedAt;

  ReportReason({this.id, this.title, this.createdAt, this.updatedAt});

  ReportReason.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ColorFilterPreset {
  int? id;
  String? title;
  String? image;
  List<double>? colorMatrix;
  double? brightness;
  double? contrast;
  double? saturation;
  double? warmth;
  int? blurIntensity;

  ColorFilterPreset({
    this.id,
    this.title,
    this.image,
    this.colorMatrix,
    this.brightness,
    this.contrast,
    this.saturation,
    this.warmth,
    this.blurIntensity,
  });

  factory ColorFilterPreset.fromJson(Map<String, dynamic> json) =>
      ColorFilterPreset(
        id: json['id'],
        title: json['title'],
        image: json['image'],
        colorMatrix: json['color_matrix'] != null
            ? List<double>.from(
                (json['color_matrix'] as List).map((e) => (e as num).toDouble()))
            : null,
        brightness: (json['brightness'] as num?)?.toDouble(),
        contrast: (json['contrast'] as num?)?.toDouble(),
        saturation: (json['saturation'] as num?)?.toDouble(),
        warmth: (json['warmth'] as num?)?.toDouble(),
        blurIntensity: _toBoolInt(json['blur_intensity']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'color_matrix': colorMatrix,
        'brightness': brightness,
        'contrast': contrast,
        'saturation': saturation,
        'warmth': warmth,
        'blur_intensity': blurIntensity,
      };
}

class FaceStickerPreset {
  int? id;
  String? title;
  String? thumbnail;
  String? stickerImage;
  String? anchorLandmark;
  double? scale;
  double? offsetX;
  double? offsetY;

  FaceStickerPreset({
    this.id,
    this.title,
    this.thumbnail,
    this.stickerImage,
    this.anchorLandmark,
    this.scale,
    this.offsetX,
    this.offsetY,
  });

  factory FaceStickerPreset.fromJson(Map<String, dynamic> json) =>
      FaceStickerPreset(
        id: json['id'],
        title: json['title'],
        thumbnail: json['thumbnail'],
        stickerImage: json['sticker_image'],
        anchorLandmark: json['anchor_landmark'],
        scale: (json['scale'] as num?)?.toDouble(),
        offsetX: (json['offset_x'] as num?)?.toDouble(),
        offsetY: (json['offset_y'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnail': thumbnail,
        'sticker_image': stickerImage,
        'anchor_landmark': anchorLandmark,
        'scale': scale,
        'offset_x': offsetX,
        'offset_y': offsetY,
      };
}
