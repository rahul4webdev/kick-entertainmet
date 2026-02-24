import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/collaboration_service.dart';
import 'package:shortzz/common/service/api/notification_service.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/model/misc/activity_notification_model.dart';
import 'package:shortzz/model/misc/admin_notification_model.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/notification_screen/widget/activity_notification_page.dart';
import 'package:shortzz/screen/post_screen/single_post_screen.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';

class NotificationScreenController extends BaseController {
  RxInt selectedTabIndex = RxInt(0);

  RxList<AdminNotificationData> adminNotifications =
      <AdminNotificationData>[].obs;
  RxList<ActivityNotification> activityNotifications =
      <ActivityNotification>[].obs;

  RxBool isActivityNotification = RxBool(false);
  RxBool isAdminNotification = RxBool(false);

  PageController pageController = PageController();

  // Category filtering
  static const List<String> categories = [
    'all',
    'likes',
    'comments',
    'mentions',
    'follows',
  ];

  RxString selectedCategory = 'all'.obs;
  RxMap<String, List<ActivityNotification>> categoryNotifications =
      <String, List<ActivityNotification>>{}.obs;
  RxMap<String, bool> isCategoryLoading = <String, bool>{}.obs;

  // Unread counts
  RxInt totalUnreadCount = 0.obs;
  RxMap<String, int> unreadByCategory = <String, int>{}.obs;

  @override
  void onInit() {
    iniData();
    super.onInit();
  }

  onTabChange(int index) {
    selectedTabIndex.value = index;
  }

  void iniData() {
    fetchActivityNotifications();
    fetchAdminNotification();
    fetchUnreadCounts();
  }

  Future<void> fetchAdminNotification() async {
    if (isAdminNotification.value) return;
    isAdminNotification.value = true;
    List<AdminNotificationData> items = await NotificationService.instance
        .fetchAdminNotifications(lastItemId: adminNotifications.lastOrNull?.id);
    isAdminNotification.value = false;
    if (items.isNotEmpty) {
      adminNotifications.addAll(items);
    }
  }

  Future<void> fetchActivityNotifications() async {
    if (isActivityNotification.value) return;
    isActivityNotification.value = true;
    List<ActivityNotification> items = await NotificationService.instance
        .fetchActivityNotifications(
            lastItemId: activityNotifications.lastOrNull?.id);
    isActivityNotification.value = false;
    if (items.isNotEmpty) {
      activityNotifications.addAll(items);
    }
  }

  /// Fetch notifications filtered by a specific category
  Future<void> fetchNotificationsByCategory(String category) async {
    if (category == 'all') {
      await fetchActivityNotifications();
      return;
    }
    if (isCategoryLoading[category] == true) return;
    isCategoryLoading[category] = true;

    final existing = categoryNotifications[category] ?? [];
    List<ActivityNotification> items = await NotificationService.instance
        .fetchNotificationsByCategory(
            category: category, lastItemId: existing.lastOrNull?.id);

    isCategoryLoading[category] = false;
    if (items.isNotEmpty) {
      final list = List<ActivityNotification>.from(existing)..addAll(items);
      categoryNotifications[category] = list;
    }
  }

  /// Get the active list based on selected category
  List<ActivityNotification> get activeNotificationsList {
    if (selectedCategory.value == 'all') {
      return activityNotifications;
    }
    return categoryNotifications[selectedCategory.value] ?? [];
  }

  /// Check if current category is loading
  bool get isActiveLoading {
    if (selectedCategory.value == 'all') {
      return isActivityNotification.value;
    }
    return isCategoryLoading[selectedCategory.value] == true;
  }

  /// Switch category and load data if needed
  void onCategoryChange(String category) {
    selectedCategory.value = category;
    if (category != 'all' &&
        (categoryNotifications[category] == null ||
            categoryNotifications[category]!.isEmpty)) {
      fetchNotificationsByCategory(category);
    }
  }

  /// Load more for current category
  Future<void> loadMoreActiveCategory() async {
    await fetchNotificationsByCategory(selectedCategory.value);
  }

  /// Fetch unread notification counts
  Future<void> fetchUnreadCounts() async {
    final result =
        await NotificationService.instance.fetchUnreadNotificationCount();
    if (result.status == true) {
      totalUnreadCount.value = result.total;
      unreadByCategory.value = result.byCategory;
    }
  }

  /// Mark all notifications as read (optionally by category)
  Future<void> markAllAsRead({String? category}) async {
    await NotificationService.instance
        .markAllNotificationsAsRead(category: category);

    // Update local state
    if (category == null) {
      for (var n in activityNotifications) {
        n.isRead = true;
      }
      activityNotifications.refresh();
      for (var key in categoryNotifications.keys) {
        for (var n in categoryNotifications[key]!) {
          n.isRead = true;
        }
      }
      categoryNotifications.refresh();
      totalUnreadCount.value = 0;
      unreadByCategory.clear();
    } else {
      final list = categoryNotifications[category];
      if (list != null) {
        for (var n in list) {
          n.isRead = true;
        }
        categoryNotifications.refresh();
      }
      // Also mark in the all list
      for (var n in activityNotifications) {
        if (n.category == category) {
          n.isRead = true;
        }
      }
      activityNotifications.refresh();
      unreadByCategory.remove(category);
      totalUnreadCount.value =
          unreadByCategory.values.fold(0, (sum, v) => sum + v);
    }
  }

  /// Mark a single notification as read on tap
  Future<void> markAsReadOnTap(ActivityNotification notification) async {
    if (notification.isRead || notification.id == null) return;
    notification.isRead = true;
    activityNotifications.refresh();
    categoryNotifications.refresh();
    if (totalUnreadCount.value > 0) {
      totalUnreadCount.value--;
    }
    final cat = notification.category;
    if (cat != null && (unreadByCategory[cat] ?? 0) > 0) {
      unreadByCategory[cat] = (unreadByCategory[cat] ?? 1) - 1;
    }
    NotificationService.instance
        .markNotificationsAsRead(notificationIds: [notification.id!]);
  }

  void onPostTap(ActivityNotification? data) async {
    if (data != null) markAsReadOnTap(data);

    Post? post = data?.data?.post;
    int? commentId = data?.data?.comment?.id;
    int? replyCommentId = data?.data?.reply?.id;

    if (post?.id == null) return;

    showLoader();
    final PostByIdModel result = await PostService.instance.fetchPostById(
        postId: post!.id!, commentId: commentId, replyId: replyCommentId);
    stopLoader();

    if (result.status != true || result.data == null) {
      showSnackBar(result.message);
      return;
    }
    final Post? fetchedPost = result.data?.post;
    if (fetchedPost == null) return;
    final postType = post.postType;

    if (postType == PostType.reel) {
      Get.to(() => ReelsScreen(
            reels: [fetchedPost].obs,
            position: 0,
            postByIdData: result.data,
          ));
    } else if ([PostType.image, PostType.video, PostType.text]
        .contains(postType)) {
      Get.to(() => SinglePostScreen(
          post: fetchedPost,
          postByIdData: result.data,
          isFromNotification: true));
    }
  }

  void onDescriptionTap(ActivityNotification data) {
    if ([
      ActivityNotifyType.notifyLikePost,
      ActivityNotifyType.notifyCommentPost,
      ActivityNotifyType.notifyMentionPost,
      ActivityNotifyType.notifyMentionComment,
      ActivityNotifyType.notifyReplyComment,
      ActivityNotifyType.notifyMentionReply,
      ActivityNotifyType.notifyCreatorLikedComment,
    ].contains(data.type)) {
      onPostTap(data);
    } else if (data.type == ActivityNotifyType.notifyCollabInvite) {
      markAsReadOnTap(data);
      _showCollabInviteDialog(data);
    } else if ([
      ActivityNotifyType.notifyFollowUser,
      ActivityNotifyType.notifyFollowRequest,
      ActivityNotifyType.notifyNewSubscriber,
      ActivityNotifyType.notifyCollabAccepted,
    ].contains(data.type)) {
      markAsReadOnTap(data);
      onUserTap(data.fromUser);
    }
  }

  void onUserTap(User? user) async {
    NavigationService.shared.openProfileScreen(user);
  }

  void _showCollabInviteDialog(ActivityNotification data) {
    final postId = data.data?.post?.id;
    if (postId == null) {
      onUserTap(data.fromUser);
      return;
    }

    CollaborationService.instance.fetchPendingInvites().then((invites) {
      final matching = invites.firstWhereOrNull(
        (inv) => inv.postId == postId,
      );

      if (matching == null) {
        onUserTap(data.fromUser);
        return;
      }

      final collabId = matching.id;
      if (collabId == null) {
        onUserTap(data.fromUser);
        return;
      }

      Get.defaultDialog(
        title: 'Collaboration Invite',
        middleText:
            '${data.fromUser?.username ?? 'Someone'} invited you to collaborate on this post.',
        textConfirm: 'Accept',
        textCancel: 'Decline',
        onConfirm: () async {
          Get.back();
          await CollaborationService.instance
              .respondToInvite(collaborationId: collabId, action: 'accept');
          showSnackBar('Collaboration accepted');
        },
        onCancel: () async {
          await CollaborationService.instance
              .respondToInvite(collaborationId: collabId, action: 'decline');
          showSnackBar('Collaboration declined');
        },
      );
    });
  }
}
