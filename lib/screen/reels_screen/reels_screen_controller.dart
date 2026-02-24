import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/model/post_story/comment/fetch_comment_model.dart';
import 'package:shortzz/model/post_story/feed_item.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/comment_sheet/helper/comment_helper.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:shortzz/screen/profile_screen/profile_screen_controller.dart';
import 'package:shortzz/screen/profile_screen/widget/post_options_sheet.dart';
import 'package:shortzz/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:shortzz/screen/report_sheet/report_sheet.dart';

class ReelsScreenController extends BaseController {
  static const String tag = "REEL";
  PageController pageController = PageController();

  final RxList<Post> reels;
  final RxList<FeedItem>? reelFeedItems;
  final RxInt currentIndex;
  final Future<void> Function()? onFetchMoreData;
  final bool isHomePage;

  final RxBool isRefreshing = false.obs;
  CommentHelper commentHelper = CommentHelper();

  ReelsScreenController({required this.reels,
    this.reelFeedItems,
    required this.currentIndex,
    this.onFetchMoreData,
    this.isHomePage = false});

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentIndex.value);
  }

  @override
  void onReady() {
    super.onReady();
    initFirstPlayers();
  }

  /// Initialize first two players
  Future<void> initFirstPlayers() async {
    isLoading.value = true;
    if (reels.length <= 1) {
      await onFetchMoreData?.call();
    }

    if (reels.length - 1 == currentIndex.value) {
      await onFetchMoreData?.call();
    }
    isLoading.value = false;
  }

  /// Handle page change
  Future<void> onPageChanged(int index) async {
    currentIndex.value = index;
    // Count remaining real posts for fetch-more trigger
    final items = reelFeedItems;
    if (items != null && items.isNotEmpty) {
      int remaining = 0;
      for (int i = index + 1; i < items.length; i++) {
        if (items[i] is PostFeedItem) remaining++;
      }
      if (remaining <= 3) {
        onFetchMoreData?.call();
      }
    } else if (index >= reels.length - 3) {
      onFetchMoreData?.call();
    }
  }

  RxBool isCurrentPageVisible = true.obs;

  /// Handle refresh logic
  Future<void> handleRefresh(Future<void> Function()? onRefresh) async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;

    await Future.delayed(const Duration(milliseconds: 100));
    await onRefresh?.call();
    await Future.delayed(const Duration(milliseconds: 200));

    if (reels.isNotEmpty) {
      currentIndex.value = 0;
      pageController.jumpToPage(0);
    }

    isRefreshing.value = false;
    update();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> onReportTap() async {
    isCurrentPageVisible.value = false;
    await Get.bottomSheet(
        ReportSheet(reportType: ReportType.post, id: reels[currentIndex.value].id?.toInt()),
        isScrollControlled: true);
    isCurrentPageVisible.value = true;
  }

  void onUpdateComment(Comment comment, bool isReplyComment) {
    final post = reels.firstWhereOrNull((e) => e.id == comment.postId);
    if (post == null) {
      return Loggers.error('Post not found');
    }
    final controllerTag = post.id.toString();
    if (Get.isRegistered<ReelController>(tag: controllerTag)) {
      Get.find<ReelController>(tag: controllerTag)
          .reelData
          .update((val) => val?.updateCommentCount(1));
    }
  }

  Future<void> openPostOptionsSheet() async {
    const tag = ProfileScreenController.tag;

    final controller = Get.isRegistered<ProfileScreenController>(tag: tag)
        ? Get.find<ProfileScreenController>(tag: tag)
        : Get.put(ProfileScreenController(SessionManager.instance.getUser().obs, (user) {}),
            tag: tag);

    isCurrentPageVisible.value = false;
    await Get.bottomSheet(
        PostOptionsSheet(
          controller: controller,
          onChanged: (type) {
            if (type == PublishType.goLive) {
              Future.delayed(
                const Duration(seconds: 1),
                () {
                  final controller = Get.find<DashboardScreenController>();
                  controller.onChanged(2);
                },
              );
            }
          },
        ),
        isScrollControlled: true);
    isCurrentPageVisible.value = true;
  }

  onUpdateReelData(Post reel) {
    final index = reels.indexWhere((element) => element.id == reel.id);
    if (index != -1) {
      reels[index] = reel;
      update();
    }
  }
}
