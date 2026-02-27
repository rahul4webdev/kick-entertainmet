import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/feed_item.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/comment_sheet/widget/hashtag_and_mention_view.dart';
import 'package:shortzz/screen/reels_screen/reel/native_ad_reel_page.dart';
import 'package:shortzz/screen/reels_screen/reel/ima_ad_reel_page.dart';
import 'package:shortzz/screen/reels_screen/reel/reel_page.dart';
import 'package:shortzz/screen/reels_screen/reels_screen_controller.dart';
import 'package:shortzz/screen/reels_screen/widget/reels_text_field.dart';
import 'package:shortzz/screen/reels_screen/widget/reels_top_bar.dart';
import 'package:shortzz/utilities/theme_res.dart';

// ---------------------------------------------------------------
// REELS SCREEN (PAGEVIEW)
// ---------------------------------------------------------------
class ReelsScreen extends StatefulWidget {
  final RxList<Post> reels;
  final RxList<FeedItem>? reelFeedItems;
  final int position;
  final Widget? widget;
  final Future<void> Function()? onFetchMoreData;
  final Future<void> Function()? onRefresh;
  final RxBool? isLoading;
  final PostByIdData? postByIdData;
  final bool isHomePage;
  final bool isFromChat;

  const ReelsScreen({
    super.key,
    required this.reels,
    this.reelFeedItems,
    required this.position,
    this.widget,
    this.onFetchMoreData,
    this.onRefresh,
    this.isLoading,
    this.postByIdData,
    this.isHomePage = false,
    this.isFromChat = false,
  });

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late final ReelsScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
        ReelsScreenController(
          reels: widget.reels,
          reelFeedItems: widget.reelFeedItems,
          currentIndex: widget.position.obs,
          onFetchMoreData: widget.onFetchMoreData,
          isHomePage: widget.isHomePage,
        ),
        tag: widget.isHomePage ? ReelsScreenController.tag : '${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackPure(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: MyRefreshIndicator(
                  onRefresh: () async {
                    await controller.handleRefresh(widget.onRefresh);
                  },
                  shouldRefresh: widget.onRefresh != null,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Obx(() {
                        final feedItems = widget.reelFeedItems;
                        final reels = widget.reels;
                        final itemCount = feedItems?.length ?? reels.length;
                        if (widget.isLoading?.value == true && reels.isEmpty) {
                          return Center(child: CupertinoActivityIndicator(color: textLightGrey(context)));
                        }
                        if (widget.isLoading?.value == false && reels.isEmpty) {
                          return NoDataWidgetWithScroll(
                              title: LKey.reelsEmptyTitle.tr, description: LKey.reelsEmptyDescription.tr);
                        }
                        return PageView.builder(
                          controller: controller.pageController,
                          physics: const CustomPageViewScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: itemCount,
                          onPageChanged: controller.onPageChanged,
                          itemBuilder: (context, index) {
                            if (feedItems != null && index < feedItems.length) {
                              final item = feedItems[index];
                              if (item is VastFeedAdItem) {
                                return const ImaAdReelPage();
                              }
                              if (item is NativeAdFeedItem) {
                                // Native ads are for list view only — auto-skip in reel PageView
                                return _SkipPage(
                                  pageController: controller.pageController,
                                  targetIndex: index + 1 < itemCount ? index + 1 : index - 1,
                                );
                              }
                            }
                            final post = feedItems != null && index < feedItems.length
                                ? (feedItems[index] as PostFeedItem).post
                                : reels[index];
                            return Obx(
                              () {
                                bool isLoading = controller.isLoading.value;
                                return isLoading
                                    ? Center(child: CupertinoActivityIndicator(color: textLightGrey(context)))
                                    : ReelPage(
                                        reelData: post,
                                        autoPlay: index == controller.currentIndex.value,
                                        likeKey: GlobalKey(),
                                        reelsScreenController: controller,
                                        onUpdateReelData: controller.onUpdateReelData,
                                        isHomePage: widget.isHomePage);
                              },
                            );
                          },
                        );
                      }),
                      HashTagAndMentionUserView(helper: controller.commentHelper),
                    ],
                  ),
                ),
              ),
              ReelsTextField(controller: controller),
            ],
          ),
          ReelsTopBar(controller: controller, widget: widget.widget),
        ],
      ),
    );
  }
}

/// Transparent page that immediately jumps the PageView to [targetIndex].
/// Used to skip non-video ad slots (e.g. NativeAdFeedItem) in the reel view.
class _SkipPage extends StatefulWidget {
  final PageController pageController;
  final int targetIndex;

  const _SkipPage({required this.pageController, required this.targetIndex});

  @override
  State<_SkipPage> createState() => _SkipPageState();
}

class _SkipPageState extends State<_SkipPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pageController.hasClients) {
        widget.pageController.jumpToPage(widget.targetIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(mass: 1, stiffness: 1000, damping: 60);
}
