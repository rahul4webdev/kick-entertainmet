import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/manager/share_manager.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/api/common_service.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/location/location_service.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/model/content/content_genre_model.dart';
import 'package:shortzz/model/content/content_language_model.dart';
import 'package:shortzz/model/general/place_detail.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/post/posts_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/post_story/feed_item.dart';
import 'package:shortzz/common/manager/ads/feed_item_merger.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/post_screen/single_post_screen.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/screen/reels_screen/reels_screen_controller.dart';
import 'package:shortzz/utilities/app_res.dart';

class HomeScreenController extends BaseController with GetSingleTickerProviderStateMixin {
  // Home tab state
  Rx<HomeTab> selectedHomeTab = HomeTab.reels.obs;

  // Reel tab state (dropdown: discover/following/nearby)
  Rx<TabType> selectedReelCategory = TabType.values.first.obs;
  RxList<Post> reels = <Post>[].obs;
  RxList<FeedItem> reelFeedItems = <FeedItem>[].obs;
  late AnimationController controller;
  late Animation<double> animation;
  RxBool isAnimateTab = false.obs;
  StreamSubscription<Map>? streamSubscription;
  CancelToken token = CancelToken();

  // Content tab state (music/trailers/news)
  RxList<Post> contentPosts = <Post>[].obs;
  RxList<FeedItem> contentFeedItems = <FeedItem>[].obs;
  Rx<ContentSubTab> selectedContentSubTab = ContentSubTab.forYou.obs;
  RxList<ContentGenre> contentGenres = <ContentGenre>[].obs;
  RxList<ContentLanguageItem> contentLanguages = <ContentLanguageItem>[].obs;
  Rx<String?> selectedGenre = Rx(null);
  Rx<String?> selectedLanguage = Rx(null);
  RxBool isContentLoading = false.obs;

  Rx<User?> get myUser => Rx(SessionManager.instance.getUser());

  @override
  void onInit() {
    controller = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);

    Future.wait([
      onRefreshPage(),
      _onNotificationTap(),
      _fetchLocation(),
      _readDeepLink(),
    ]);

    super.onInit();
  }

  @override
  void onReady() {
    isLoading.value = true;
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    controller.dispose();
    streamSubscription?.cancel();
  }

  // ================================================================
  // HOME TAB SWITCHING
  // ================================================================

  void onHomeTabChanged(HomeTab tab) {
    if (selectedHomeTab.value == tab) return;
    // Cancel any in-flight requests before switching
    token.cancel();
    token = CancelToken();
    selectedHomeTab.value = tab;
    if (tab == HomeTab.reels) {
      onRefreshPage(reset: true);
    } else if (tab == HomeTab.local) {
      _fetchLocalFeed(true);
    } else {
      resetContentFilters();
      fetchContentForTab(reset: true);
    }
  }

  // ================================================================
  // REEL TAB METHODS (existing logic)
  // ================================================================

  Future<void> _onNotificationTap() async {
    if (Platform.isIOS) {
      final payload = FirebaseNotificationManager.instance.notificationPayload.value;
      if (payload.isNotEmpty) {
        FirebaseNotificationManager.instance.handleNotification(payload);
      }
    } else {
      RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        await FirebaseNotificationManager.instance.handleNotification(jsonEncode(message.toMap()));
      }
    }

    FirebaseNotificationManager.instance.notificationPayload.listen((p0) {
      if (p0.isNotEmpty) {
        FirebaseNotificationManager.instance.handleNotification(p0);
      }
    });
  }

  Future<void> _readDeepLink() async {
    ShareManager.shared.listen((key, value) async {
      debugPrint('[DeepLink] Received: key=$key, value=$value');
      await Future.delayed(const Duration(milliseconds: 500));
      if (key == ShareKeys.post.value) {
        debugPrint('[DeepLink] Fetching post $value...');
        PostByIdModel model = await PostService.instance.fetchPostById(postId: value);
        if (model.status == true) {
          Post? post = model.data?.post;
          if (post != null) {
            debugPrint('[DeepLink] Navigating to post $value');
            await Get.to(() => SinglePostScreen(post: post, isFromNotification: true), preventDuplicates: false);
          } else {
            debugPrint('[DeepLink] Post $value not found in response');
          }
        } else {
          debugPrint('[DeepLink] fetchPostById failed for post $value');
        }
      } else if (key == ShareKeys.reel.value) {
        debugPrint('[DeepLink] Fetching reel $value...');
        PostByIdModel model = await PostService.instance.fetchPostById(postId: value);
        if (model.status == true) {
          Post? post = model.data?.post;
          if (post != null) {
            debugPrint('[DeepLink] Navigating to reel $value');
            await Get.to(() => ReelsScreen(reels: [post].obs, position: 0), preventDuplicates: false);
          } else {
            debugPrint('[DeepLink] Reel $value not found in response');
          }
        } else {
          debugPrint('[DeepLink] fetchPostById failed for reel $value');
        }
      } else if (key == ShareKeys.user.value) {
        debugPrint('[DeepLink] Fetching user $value...');
        User? user = await UserService.instance.fetchUserDetails(userId: value);
        if (user != null) {
          debugPrint('[DeepLink] Navigating to user $value');
          await NavigationService.shared.openProfileScreen(user);
        } else {
          debugPrint('[DeepLink] User $value not found');
        }
      }
    });
  }

  Future<void> onRefreshPage({bool reset = true}) async {
    if (reset) {
      isLoading.value = true;
    }
    switch (selectedReelCategory.value) {
      case TabType.discover:
        await fetchDiscoverPost(reset);
        break;
      case TabType.following:
        await _fetchFollowingPost(reset);
        break;
      case TabType.favorites:
        await _fetchFavoritesPost(reset);
        break;
      case TabType.nearby:
        try {
          await _fetchPostsNearBy(reset);
        } catch (e) {
          selectedReelCategory.value = TabType.discover;
        }
        break;
    }
  }

  onTabTypeChanged(TabType tabType) async {
    onAnimationBack();
    if (selectedReelCategory.value == tabType) {
      return;
    }
    // Cancel previous feed request
    token.cancel();
    token = CancelToken();
    selectedReelCategory.value = tabType;
    await onRefreshPage.call(reset: true);
  }

  onToggleDropDown() {
    if (animation.status != AnimationStatus.completed) {
      controller.forward();
      isAnimateTab.value = true;
    } else {
      onAnimationBack();
    }
  }

  onAnimationBack() {
    isAnimateTab.value = false;
    controller.animateBack(0, duration: const Duration(milliseconds: 250), curve: Curves.linear);
  }

  Future<void> fetchDiscoverPost(bool resetData) async {
    isLoading.value = true;
    PostsModel model = await PostService.instance.fetchPostsDiscover(type: PostType.reels, cancelToken: token);
    addResponseData(model.data ?? [], model.adPositions ?? [], resetData);
  }

  Future<void> _fetchFollowingPost(bool resetData) async {
    isLoading.value = true;
    PostsModel model = await PostService.instance.fetchPostsFollowing(type: PostType.reels, cancelToken: token);
    addResponseData(model.data ?? [], model.adPositions ?? [], resetData);
  }

  Future<void> _fetchFavoritesPost(bool resetData) async {
    isLoading.value = true;
    PostsModel model = await PostService.instance.fetchPostsFavorites(type: PostType.reels, cancelToken: token);
    addResponseData(model.data ?? [], model.adPositions ?? [], resetData);
  }

  Future<void> _fetchPostsNearBy(bool resetData) async {
    isLoading.value = true;
    Position position = await LocationService.instance.getCurrentLocation(isPermissionDialogShow: true);
    PostsModel model = await PostService.instance.fetchPostsNearBy(
        type: PostType.reels, placeLat: position.latitude, placeLon: position.longitude, cancelToken: token);
    addResponseData(model.data ?? [], model.adPositions ?? [], resetData);
  }

  Future<void> _fetchLocalFeed(bool resetData) async {
    isContentLoading.value = true;
    try {
      Position position = await LocationService.instance.getCurrentLocation(isPermissionDialogShow: true);
      PostsModel model = await PostService.instance.fetchPostsNearBy(
          type: PostType.reels, placeLat: position.latitude, placeLon: position.longitude, cancelToken: token);
      if (resetData) {
        contentPosts.clear();
        contentFeedItems.clear();
      }
      final posts = model.data ?? [];
      if (posts.isNotEmpty) {
        contentPosts.addAll(posts);
        contentFeedItems.addAll(FeedItemMerger.merge(posts, model.adPositions ?? []));
      }
    } catch (e) {
      Loggers.error('Local feed error: $e');
    } finally {
      isContentLoading.value = false;
    }
  }

  void addResponseData(List<Post> newPosts, List<int> adPositions, bool resetData) {
    if (resetData) {
      reels.clear();
      reelFeedItems.clear();
      if (Get.isRegistered<ReelsScreenController>(tag: ReelsScreenController.tag)) {
        var controller = Get.find<ReelsScreenController>(tag: ReelsScreenController.tag);
        controller.handleRefresh(() async {});
      }
    }
    if (newPosts.isNotEmpty) {
      reels.addAll(newPosts);
      reelFeedItems.addAll(FeedItemMerger.merge(newPosts, adPositions));
    }

    isLoading.value = false;
  }

  Future<void> _fetchLocation() async {
    PlaceDetail? detail;
    try {
      detail = await CommonService.instance.getIPPlaceDetail();
    } catch (e) {
      Loggers.error('Location error : $e');
    }

    if (detail != null) {
      UserService.instance
          .updateUserDetails(region: detail.region, regionName: detail.regionName, timezone: detail.timezone);
    }
  }

  // ================================================================
  // CONTENT TAB METHODS (Music, Trailers, News)
  // ================================================================

  Future<void> fetchContentForTab({bool reset = false}) async {
    if (reset) {
      isContentLoading.value = true;
      contentPosts.clear();
      contentFeedItems.clear();
    }

    int contentTypeValue = selectedHomeTab.value.contentType;
    if (contentTypeValue == 0) return; // Reels tab, skip

    // Load genres if not loaded for this content type
    if (contentGenres.isEmpty) {
      _loadGenres(contentTypeValue);
    }
    if (contentLanguages.isEmpty) {
      _loadLanguages();
    }

    PostsModel model = await PostService.instance.fetchContentByType(
      contentType: contentTypeValue,
      subTab: selectedContentSubTab.value.apiValue,
      genre: selectedGenre.value,
      language: selectedLanguage.value,
      cancelToken: token,
    );

    List<Post> newPosts = model.data ?? [];
    List<int> adPositions = model.adPositions ?? [];

    if (reset) {
      contentPosts.clear();
      contentFeedItems.clear();
    }

    if (newPosts.isNotEmpty) {
      contentPosts.addAll(newPosts);
      contentFeedItems.addAll(FeedItemMerger.merge(newPosts, adPositions));
    }

    isContentLoading.value = false;
  }

  void onContentSubTabChanged(ContentSubTab subTab) {
    if (selectedContentSubTab.value == subTab) return;
    token.cancel();
    token = CancelToken();
    selectedContentSubTab.value = subTab;
    fetchContentForTab(reset: true);
  }

  void onGenreChanged(String? genre) {
    token.cancel();
    token = CancelToken();
    selectedGenre.value = genre;
    fetchContentForTab(reset: true);
  }

  void onLanguageChanged(String? language) {
    selectedLanguage.value = language;
    fetchContentForTab(reset: true);
  }

  Future<void> _loadGenres(int contentType) async {
    contentGenres.value = await PostService.instance.fetchContentGenres(contentType: contentType);
  }

  Future<void> _loadLanguages() async {
    contentLanguages.value = await PostService.instance.fetchContentLanguages();
  }

  /// Called when switching home tabs — resets content filters
  void resetContentFilters() {
    selectedContentSubTab.value = ContentSubTab.forYou;
    selectedGenre.value = null;
    selectedLanguage.value = null;
    contentGenres.clear();
  }
}
