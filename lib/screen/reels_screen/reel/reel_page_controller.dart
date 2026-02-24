import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/functions/debounce_action.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/haptic_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/manager/share_manager.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/common/widget/save_collection_picker.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/post_story/music/music_model.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/feed_item.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/audio_details_screen/audio_sheet.dart';
import 'package:shortzz/screen/camera_screen/camera_screen.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/selected_music_sheet/selected_music_sheet_controller.dart';
import 'package:shortzz/screen/duet_screen/duet_recording_screen.dart';
import 'package:shortzz/screen/stitch_screen/stitch_clip_selector_screen.dart';
import 'package:shortzz/screen/comment_sheet/comment_sheet.dart';
import 'package:shortzz/screen/gift_sheet/send_gift_sheet_controller.dart';
import 'package:shortzz/screen/tip_sheet/send_tip_sheet.dart';
import 'package:shortzz/common/service/api/social_service.dart';
import 'package:shortzz/screen/home_screen/home_screen_controller.dart';
import 'package:shortzz/screen/post_screen/post_screen_controller.dart';
import 'package:shortzz/screen/reels_screen/reels_screen_controller.dart';
import 'package:shortzz/screen/saved_post_screen/saved_post_screen_controller.dart';

class ReelController extends BaseController {
  Rx<Post> reelData;
  bool isLikeLoading = false;
  bool isSavedLoading = false;

  User? get myUser => SessionManager.instance.getUser();
  Timer? _debounce;
  final Function(Post reelData) onUpdateReelData;

  ReelController(this.reelData, this.onUpdateReelData) {
    reelData.listen((p0) {
      if (p0.postType == PostType.video && Get.isRegistered<PostScreenController>(tag: '${p0.id}')) {
        final controller = Get.find<PostScreenController>(tag: '${p0.id}');
        controller.updatePost(p0);
      }
      onUpdateReelData(p0);
    });
  }

  @override
  void onClose() {
    super.onClose();
    reelData.close();
    _debounce?.cancel();
  }

  updateReelData({Post? reel, bool isIncreaseCoin = false}) {
    if (reel != null) {
      if (isIncreaseCoin) {
        reelData.update((val) => val?.increaseViews());
      } else {
        reelData.value = reel;
      }
    }
  }

  void onLikeTap() {
    if (reelData.value.isLiked == false) {
      HapticManager.shared.light();
    }
    FocusManager.instance.primaryFocus?.unfocus();
    int reelId = reelData.value.id?.toInt() ?? -1;

    if (reelId == -1) {
      return Loggers.error('Invalid Post id : $reelId');
    }

    reelData.update((val) {
      val?.likeToggle(val.isLiked == true ? false : true);
    });

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      try {
        await (reelData.value.isLiked == true ? _likePostApi(reelId) : _disLikePostApi(reelId));
        // if (reelData.value.postType == PostType.video &&
        //     Get.isRegistered<PostScreenController>(tag: '$reelId')) {
        //   final controller = Get.find<PostScreenController>(tag: '$reelId');
        //   controller.₹₹1(reelData.value);
        // }
      } catch (e) {
        Loggers.error('ERROR IN LIKE  REEL $e');
      }
    });
  }

  Future<void> _likePostApi(int id) async {
    StatusModel result = await PostService.instance.likePost(postId: id);
    if (result.status == true) {
      Post? reel = reelData.value;
      if (reel.user?.notifyPostLike == 1 && myUser?.id != reel.userId) {
        FirebaseNotificationManager.instance.sendLocalisationNotification(LKey.activityLikedPost,
            type: NotificationType.post,
            body: NotificationInfo(id: reel.id),
            deviceType: reel.user?.device ?? 0,
            deviceToken: reel.user?.deviceToken ?? '',
            languageCode: reel.user?.appLanguage);
      }
    }
  }

  Future<void> _disLikePostApi(int id) async {
    await PostService.instance.disLikePost(postId: id);
  }

  Future<void> onCommentTap({PostByIdData? postByIdData, bool isFromNotification = false}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _setPageVisibility(false);
    await Get.bottomSheet(
        CommentSheet(
          replyComment: postByIdData?.reply,
          comment: postByIdData?.comment,
          post: reelData.value,
          isFromNotification: isFromNotification,
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent);
    _setPageVisibility(true);
  }

  void onSaved() {
    FocusManager.instance.primaryFocus?.unfocus();
    int reelId = reelData.value.id?.toInt() ?? -1;
    if (reelId == -1) {
      return Loggers.error('Invalid Post id : $reelId');
    }

    if (isSavedLoading) {
      return Loggers.error('Is saved loading : $isSavedLoading');
    }

    HapticManager.shared.light();

    // If already saved, unsave directly
    if (reelData.value.isSaved == true) {
      isSavedLoading = true;
      reelData.update((val) {
        val?.saveToggle(false);
      });
      DebounceAction.shared.call(() async {
        await _unSavePostApi(reelId);
        isSavedLoading = false;
      });
      return;
    }

    // If not saved, show collection picker
    SaveCollectionPicker.show(
      postId: reelId,
      onSaved: () {
        reelData.update((val) {
          val?.saveToggle(true);
        });
        if (Get.isRegistered<SavedPostScreenController>()) {
          final controller = Get.find<SavedPostScreenController>();
          controller.unsavedIds.removeWhere((element) => element == reelId);
        }
      },
    );
  }

  Future<void> _unSavePostApi(int id) async {
    StatusModel result = await PostService.instance.unSavePost(postId: id);
    if (result.status == true) {
      if (Get.isRegistered<SavedPostScreenController>()) {
        final controller = Get.find<SavedPostScreenController>();
        controller.unsavedIds.add(id);
      }
    }
  }

  void onShareTap() {
    FocusManager.instance.primaryFocus?.unfocus();
    ShareManager.shared.showCustomShareSheet(
      post: reelData.value,
      keys: ShareKeys.reel,
      onShareSuccess: () {
        reelData.update((val) => val?.increaseShares(1));
      },
    );
  }

  Future<void> onGiftTap() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _setPageVisibility(false);
    await GiftManager.openGiftSheet(
      userId: reelData.value.userId ?? -1,
      onCompletion: (giftManager) {
        GiftManager.showAnimationDialog(giftManager.gift);
        GiftManager.sendNotification(reelData.value);
      },
    );
    _setPageVisibility(true);
  }

  Future<void> onTipTap() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _setPageVisibility(false);
    await TipManager.openTipSheet(
      userId: reelData.value.userId ?? -1,
      postId: reelData.value.id?.toInt(),
      userName: reelData.value.user?.username,
      userPhoto: reelData.value.user?.profilePhoto,
      onCompletion: (coins) {
        HapticManager.shared.light();
      },
    );
    _setPageVisibility(true);
  }

  Future<void> onRepostTap() async {
    final post = reelData.value;
    final result = await SocialService.instance.repostPost(postId: post.id?.toInt() ?? 0);
    if (result.status == true) {
      HapticManager.shared.light();
      Get.snackbar('Done', 'Reposted to your profile', snackPosition: SnackPosition.BOTTOM);
      reelData.update((val) {
        val?.repostCount = (val.repostCount ?? 0) + 1;
      });
    } else {
      Get.snackbar('Oops', result.message ?? 'Failed to repost', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> onDuetTap() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final post = reelData.value;
    if (post.id == null || post.id == -1) return;
    _setPageVisibility(false);
    await Get.to(() => DuetRecordingScreen(sourcePost: post));
    _setPageVisibility(true);
  }

  Future<void> onStitchTap() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final post = reelData.value;
    if (post.id == null || post.id == -1) return;
    _setPageVisibility(false);
    await Get.to(() => StitchClipSelectorScreen(sourcePost: post));
    _setPageVisibility(true);
  }

  Future<void> onAudioTap(Music? music) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _setPageVisibility(false);
    await Get.bottomSheet(AudioSheet(music: music), isScrollControlled: true);
    _setPageVisibility(true);
  }

  Future<void> onUseAudioTap(Music? music) async {
    if (music == null) return;
    FocusManager.instance.primaryFocus?.unfocus();

    // Create a SelectedMusic from the reel's music and navigate to camera
    final downloadUrl = music.sound?.addBaseURL();
    if (downloadUrl == null || downloadUrl.isEmpty) {
      Get.snackbar('Error', 'Audio not available',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Download audio first, then open camera with it pre-loaded
    final selectedMusic = SelectedMusic(music, 0, downloadUrl, null);
    Get.to(() => CameraScreen(
          cameraType: CameraScreenType.post,
          selectedMusic: selectedMusic,
        ));
  }

  void onUserTap(User? user) {
    if (reelData.value.id == -1) return;
    _setPageVisibility(false);
    NavigationService.shared.openProfileScreen(user, onUserUpdate: (user) async {
      final HomeScreenController homeScreenController;
      if (Get.isRegistered<HomeScreenController>()) {
        if (user?.isBlock == true) {
          homeScreenController = Get.find<HomeScreenController>();
          homeScreenController.onRefreshPage();
        }
      }
    }).then((value) {
      _setPageVisibility(true);
    });
  }

  Future<void> onNotInterestedTap() async {
    final post = reelData.value;
    final postId = post.id?.toInt() ?? -1;
    if (postId == -1) return;

    // Remove from current feed
    if (Get.isRegistered<HomeScreenController>()) {
      final homeController = Get.find<HomeScreenController>();
      homeController.reels.removeWhere((r) => r.id == post.id);
      homeController.reelFeedItems.removeWhere(
        (item) => item is PostFeedItem && item.post.id == post.id,
      );
    }

    // Call API
    final success = await PostService.instance.markNotInterested(postId: postId);

    if (success) {
      Get.snackbar(
        LKey.notInterested.tr,
        LKey.notInterestedDone.tr,
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () async {
            Get.closeCurrentSnackbar();
            await PostService.instance.undoNotInterested(postId: postId);
            if (Get.isRegistered<HomeScreenController>()) {
              Get.find<HomeScreenController>().onRefreshPage();
            }
          },
          child: Text(LKey.undo.tr),
        ),
      );
    }
  }

  Future<void> onGetEmbedCode() async {
    final postId = reelData.value.id?.toInt() ?? -1;
    if (postId == -1) return;
    final data = await PostService.instance.generateEmbedCode(postId: postId);
    if (data != null && data['embed_code'] != null) {
      await (data['embed_code'] as String).copyText;
      Get.snackbar(
        LKey.getEmbedCode.tr,
        LKey.embedCodeCopied.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _setPageVisibility(bool visible) {
    if (Get.isRegistered<ReelsScreenController>(tag: ReelsScreenController.tag)) {
      Get.find<ReelsScreenController>(tag: ReelsScreenController.tag)
          .isCurrentPageVisible.value = visible;
    }
  }

  void notifyCommentSheet(PostByIdData? data) {
    if (data != null && (data.comment != null || data.reply != null)) {
      DebounceAction.shared.call(() {
        onCommentTap(postByIdData: data, isFromNotification: true);
      }, milliseconds: 1000);
    }
  }
}
