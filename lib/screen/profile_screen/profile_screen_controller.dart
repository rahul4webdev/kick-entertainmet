import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/ads_controller.dart';
import 'package:shortzz/common/controller/follow_controller.dart';
import 'package:shortzz/common/controller/profile_controller.dart';
import 'package:shortzz/common/enum/chat_enum.dart';
import 'package:shortzz/common/extensions/list_extension.dart';
import 'package:shortzz/common/extensions/user_extension.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/highlight_service.dart';
import 'package:shortzz/common/service/api/moderator_service.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/post_story/story/story_model.dart';
import 'package:shortzz/model/post_story/user_post_model.dart';
import 'package:shortzz/model/story_highlight/story_highlight_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/blocked_user_screen/block_user_controller.dart';
import 'package:shortzz/screen/chat_screen/chat_screen.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen.dart';
import 'package:shortzz/screen/post_screen/post_screen_controller.dart';
import 'package:shortzz/screen/profile_screen/widget/post_options_sheet.dart';
import 'package:shortzz/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:shortzz/screen/report_sheet/report_sheet.dart';
import 'package:shortzz/screen/story_view_screen/story_view_screen.dart';
import 'package:shortzz/utilities/app_res.dart';

class ProfileScreenController extends BlockUserController
    with GetTickerProviderStateMixin {
  static const tag = 'PROFILE';
  final adsController = Get.find<AdsController>();
  RxInt selectedTabIndex = 0.obs;

  Rx<User?> userData;
  RxList<Post> reels = <Post>[].obs;
  RxList<Post> posts = <Post>[].obs;
  RxList<Post> exclusivePosts = <Post>[].obs;
  RxList<StoryHighlight> highlights = <StoryHighlight>[].obs;
  RxBool isReelLoading = false.obs;
  RxBool isPostLoading = false.obs;
  RxBool isExclusiveLoading = false.obs;
  final PageController pageController = PageController();
  RxBool isUserNotFound = false.obs;
  Setting? settingData = SessionManager.instance.getSettings();
  RxBool isFollowUnFollowInProcess = false.obs;
  late ProfileController profileController;
  final Function(User? user)? onUserUpdate;

  ProfileScreenController(this.userData, this.onUserUpdate);

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<ProfileController>(tag: '${userData.value?.id}')) {
      profileController =
          Get.find<ProfileController>(tag: '${userData.value?.id}');
      userData.value = profileController.user;
    } else {
      profileController = Get.put(ProfileController(userData.value),
          tag: '${userData.value?.id}');
    }
    userData.listen((p0) {
      onUserUpdate?.call(p0);
    });
  }

  @override
  void onReady() {
    super.onReady();
    iniData();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  iniData() {
    Future.wait({
      fetchUserDetail(),
      fetchReel(),
      fetchPost(),
      fetchHighlights(),
    });
  }

  bool _exclusiveFetched = false;

  void onTabChanged(int value) {
    selectedTabIndex.value = value;
    // Lazy-load exclusive posts on first visit to that tab
    if (hasExclusiveTab && !_exclusiveFetched) {
      // Exclusive tab is after Q&A (index 4)
      final exclusiveTabIndex = 4;
      if (value == exclusiveTabIndex) {
        _exclusiveFetched = true;
        fetchExclusivePosts();
      }
    }
  }

  Future<void> fetchUserDetail() async {
    isLoading.value = true;
    User? user = await UserService.instance
        .fetchUserDetails(userId: userData.value?.id?.toInt());
    profileController.updateUser(user);
    isLoading.value = false;
    if (user != null) {
      userData.value = user;
    } else {
      isUserNotFound.value = true;
    }
  }

  Future<void> fetchReel({bool isEmpty = false}) async {
    if (isReelLoading.value) return;
    isReelLoading.value = true;
    try {
      UserPostData? items = await PostService.instance.fetchUserPosts(
          type: PostType.reels,
          userId: userData.value?.id?.toInt(),
          lastItemId: isEmpty ? null : reels.lastOrNull?.id?.toInt());
      if (isEmpty) reels.clear();

      if (reels.isEmpty) {
        reels.addAll(items?.pinnedPostList ?? []);
      }

      for (var post in (items?.posts ?? [])) {
        if (reels.firstWhereOrNull((element) => element.id == post.id) ==
            null) {
          reels.add(post);
        }
      }
    } catch (e) {
      Loggers.error('Fetch Reel Error : $e');
    } finally {
      isReelLoading.value = false;
    }
  }

  Future<void> fetchPost({bool isEmpty = false}) async {
    if (isPostLoading.value) return;
    isPostLoading.value = true;
    // Fetch user posts
    UserPostData? items = await PostService.instance.fetchUserPosts(
      type: PostType.posts,
      userId:
          userData.value?.id?.toInt() ?? SessionManager.instance.getUserID(),
      lastItemId: isEmpty ? null : posts.lastOrNull?.id?.toInt(),
    );

    if (isEmpty) {
      posts.clear();
    }
    if (posts.isEmpty) {
      posts.addAll(items?.pinnedPostList ?? []);
    }

    for (var post in (items?.posts ?? [])) {
      if (posts.firstWhereOrNull((element) => element.id == post.id) == null) {
        posts.add(post);
      }
    }
    isPostLoading.value = false;
    posts.refresh();
  }

  bool get hasExclusiveTab =>
      userData.value?.subscriptionsEnabled == true;

  Future<void> fetchExclusivePosts({bool isEmpty = false}) async {
    if (isExclusiveLoading.value) return;
    isExclusiveLoading.value = true;
    try {
      final items = await PostService.instance.fetchSubscriberOnlyPosts(
        creatorId: userData.value?.id?.toInt() ?? 0,
        lastItemId: isEmpty ? null : exclusivePosts.length,
      );
      if (isEmpty) exclusivePosts.clear();
      for (var post in items) {
        if (exclusivePosts.firstWhereOrNull((e) => e.id == post.id) == null) {
          exclusivePosts.add(post);
        }
      }
    } catch (e) {
      Loggers.error('Fetch exclusive posts error: $e');
    } finally {
      isExclusiveLoading.value = false;
    }
  }

  Future<void> fetchHighlights() async {
    try {
      final items = await HighlightService.instance
          .fetchHighlights(userId: userData.value?.id?.toInt());
      highlights.value = items;
    } catch (e) {
      Loggers.error('Fetch highlights error: $e');
    }
  }

  Future<void> deleteHighlight(StoryHighlight highlight) async {
    try {
      await HighlightService.instance
          .deleteHighlight(highlightId: highlight.id!);
      highlights.removeWhere((h) => h.id == highlight.id);
    } catch (e) {
      Loggers.error('Delete highlight error: $e');
    }
  }

  Future<void> onRefresh() async {
    Future.wait([
      fetchUserDetail(),
      fetchPost(isEmpty: true),
      fetchReel(isEmpty: true),
      fetchHighlights(),
    ]);
  }

  void onAddPost({Post? post, CreateFeedType? type}) {
    if (post == null) return; // Exit early if post is null

    // Determine the target list based on the type
    List<Post> targetList = type == CreateFeedType.feed ? posts : reels;

    // Find the position to insert the post after pinned posts
    int pinnedCount =
        targetList.where((element) => element.isPinned == 1).length;

    // Insert the post at the appropriate position
    targetList.insert(pinnedCount, post);
  }

  void onAddStory(Story? story) {
    if (story == null) return; // Exit early if story is null
    userData.update((val) {
      val?.stories?.add(story);
    });
  }

  Future<StatusModel> unpinPost(Post post) async {
    StatusModel response =
        await PostService.instance.unpinPost(postId: post.id?.toInt() ?? -1);
    return response;
  }

  Future<StatusModel> pinPost(Post post) async {
    StatusModel response =
        await PostService.instance.pinPost(postId: post.id?.toInt() ?? -1);
    return response;
  }

  onUpdateUser(User? user) {
    userData.value = user;
    userData.refresh();
  }

  void reportUser(User? user) {
    Get.bottomSheet(ReportSheet(id: user?.id, reportType: ReportType.user),
        isScrollControlled: true);
  }

  onPinUnpinReel(Post post) async {
    if (post.isPinned == 0) {
      List<Post> existingPinPost = [];

      for (var element in reels) {
        if (element.isPinned == 1) {
          existingPinPost.add(element);
        }
      }

      if ((settingData?.maxPostPins ?? AppRes.maxPinFeed) >
          existingPinPost.length) {
        StatusModel model = await pinPost(post);
        if (model.status == true) {
          reels.removeWhere((element) => element.id == post.id);
          post.isPinned = 1;
          reels.insert(0, post);
          reels.refresh();
        }
      } else {
        // showSnackBar('You can maximum ${settingData.value?.maxPostPins} pinned');
        showSnackBar(LKey.pinLimitExceeded.trParams({
          'pin_count':
              '${settingData?.maxPostPins ?? AppRes.maxPinFeed.toString()}'
        }));
      }
    } else {
      StatusModel response = await unpinPost(post);
      if (response.status == true) {
        fetchReel(isEmpty: true);
      }
    }
  }

  onDeleteReel(Post post, {required bool isModerator}) {
    Get.bottomSheet(
      ConfirmationSheet(
          title: LKey.deletePostTitle.tr,
          onTap: () async {
            showLoader();
            StatusModel model;
            if (isModerator) {
              model = await ModeratorService.instance
                  .moderatorDeletePost(postId: post.id?.toInt() ?? -1);
            } else {
              model = await PostService.instance
                  .deletePost(postId: post.id?.toInt() ?? -1);
            }
            if (model.status == true) {
              Get.delete<ReelController>(tag: '${post.id}');
              reels.removeWhere((element) => element.id == post.id);
              post = Post();
            }
            stopLoader();
          },
          description: LKey.deletePostMessage.tr),
    );
  }

  void toggleBlockUnblock(isBlock) {
    if (isBlock) {
      unblockUser(userData.value, () {
        userData.update((val) => val?.updateBlockStatus(false));
      });
    } else {
      blockUser(userData.value, () {
        userData.update(
          (val) {
            val?.updateBlockStatus(true);
          },
        );
      });
    }
  }

  void toggleMuteUnmute(bool isMuted) async {
    final user = userData.value;
    if (user == null) return;
    if (isMuted) {
      StatusModel response =
          await UserService.instance.unMuteUser(userId: user.id ?? -1);
      if (response.status == true) {
        userData.update((val) {
          val?.isMuted = false;
          val?.mutePosts = false;
          val?.muteStories = false;
        });
      }
    } else {
      StatusModel response =
          await UserService.instance.muteUser(userId: user.id ?? -1);
      if (response.status == true) {
        userData.update((val) {
          val?.isMuted = true;
          val?.mutePosts = true;
          val?.muteStories = true;
        });
      }
    }
  }

  void toggleRestrictUnrestrict(bool isRestricted) async {
    final user = userData.value;
    if (user == null) return;
    if (isRestricted) {
      StatusModel response =
          await UserService.instance.unrestrictUser(userId: user.id ?? -1);
      if (response.status == true) {
        userData.update((val) {
          val?.isRestricted = false;
        });
      }
    } else {
      StatusModel response =
          await UserService.instance.restrictUser(userId: user.id ?? -1);
      if (response.status == true) {
        userData.update((val) {
          val?.isRestricted = true;
        });
      }
    }
  }

  void toggleFavorite(bool isFavorite) async {
    final user = userData.value;
    if (user == null) return;
    if (isFavorite) {
      StatusModel response =
          await UserService.instance.removeFromFavorites(userId: user.id ?? -1);
      if (response.status == true) {
        userData.update((val) {
          val?.isFavorite = false;
        });
      }
    } else {
      StatusModel response =
          await UserService.instance.addToFavorites(userId: user.id ?? -1);
      if (response.status == true) {
        userData.update((val) {
          val?.isFavorite = true;
        });
      }
    }
  }

  updatePinPost(Post post) async {
    List<Post> existingPinPost = [];

    for (var element in posts) {
      if (element.isPinned == 1) {
        existingPinPost.add(element);
      }
    }

    if ((settingData?.maxPostPins ?? AppRes.maxPinFeed) >
        existingPinPost.length) {
      StatusModel response = await pinPost(post);
      if (response.status == true) {
        posts.removeWhere((element) => element.id == post.id);
        post.isPinned = 1;
        final controller = Get.find<PostScreenController>(tag: '${post.id}');
        controller.updatePost(post);
        posts.insert(0, post);
        posts.refresh();
      }
    } else {
      // showSnackBar('You can maximum ${settingData.value?.maxPostPins} pinned');
      showSnackBar(LKey.pinLimitExceeded.trParams({
        'pin_count':
            '${settingData?.maxPostPins ?? AppRes.maxPinFeed.toString()}'
      }));
    }
  }

  updateUnPinPost(Post post) async {
    StatusModel response = await unpinPost(post);
    if (response.status == true) {
      final controller = Get.find<PostScreenController>(tag: '${post.id}');
      post.isPinned = 0;
      controller.updatePost(post);
      fetchPost(isEmpty: true);
    }
  }

  Future<void> followUnFollowUser() async {
    int userId = userData.value?.id ?? -1;
    if (isFollowUnFollowInProcess.value) return;
    isFollowUnFollowInProcess.value = true;

    FollowController followController;
    if (Get.isRegistered<FollowController>(tag: userId.toString())) {
      followController = Get.find<FollowController>(tag: userId.toString());
      followController.updateUser(userData.value);
    } else {
      followController =
          Get.put(FollowController(userData), tag: userId.toString());
    }

    User? user = await followController.followUnFollowUser();
    isFollowUnFollowInProcess.value = false;
    userData.update((val) {
      val?.isFollowing = user?.isFollowing;
      val?.followerCount = user?.followerCount;
      val?.followingCount = user?.followingCount;
    });
    profileController.updateUser(userData.value);
  }

  void handlePublishOrMessageBtn(bool isMe) {
    if (isMe) {
      Get.bottomSheet(PostOptionsSheet(controller: this),
          isScrollControlled: true);
    } else {
      // Determine chat type based on receiveMessage setting (Instagram-style)
      // receiveMessage: 1 = Everyone, 2 = Followers only, 0 = Nobody
      // If I follow them AND they allow messages → approved, else → request
      final receiveMsg = userData.value?.receiveMessage ?? 1;
      final iFollow = userData.value?.isFollowing == true;
      ChatType chatType;
      if (receiveMsg == 1 && iFollow) {
        chatType = ChatType.approved;
      } else if (receiveMsg == 2 && iFollow) {
        chatType = ChatType.approved;
      } else {
        chatType = ChatType.request;
      }

      ChatThread conversation = ChatThread(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          lastMsg: '',
          msgCount: 0,
          isDeleted: false,
          deletedId: 0,
          iAmBlocked: false,
          iBlocked: userData.value?.isBlock ?? false,
          requestType: chatType == ChatType.approved
              ? UserRequestAction.accept.title
              : UserRequestAction.reject.title,
          chatType: chatType,
          conversationId: [
            SessionManager.instance.getUserID(),
            userData.value?.id
          ].conversationId,
          userId: userData.value?.id);
      conversation.chatUser = userData.value?.appUser;
      Get.to(() =>
          ChatScreen(conversationUser: conversation, user: userData.value));
    }
  }

  void onStoryTap(bool isStoryAvailable) {
    if (isStoryAvailable) {
      userData.value?.checkIsBlocked(() {
        Get.bottomSheet(
                StoryViewSheet(
                  stories: [userData.value!],
                  userIndex: 0,
                  onUpdateDeleteStory: (story) {
                    userData.update((val) => (val?.stories ?? [])
                        .removeWhere((element) => element.id == story?.id));
                  },
                ),
                isScrollControlled: true,
                ignoreSafeArea: false)
            .then((value) {
          // For check story view or not
          fetchUserDetail();
        });
      });
    }
  }

  void freezeUnfreezeUser(bool isFreeze) async {
    StatusModel result;
    showLoader();
    if (isFreeze) {
      result = await ModeratorService.instance
          .moderatorUnFreezeUser(userId: userData.value?.id);
    } else {
      result = await ModeratorService.instance
          .moderatorFreezeUser(userId: userData.value?.id);
    }
    stopLoader();

    if (result.status == true) {
      userData.update((val) => val?.isFreez = isFreeze ? 0 : 1);
    }
  }
}
