import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/model/post_story/feed_item.dart';
import 'package:shortzz/screen/content_screen/widget/content_filter_bar.dart';
import 'package:shortzz/screen/content_screen/widget/content_sub_tabs.dart';
import 'package:shortzz/screen/content_screen/widget/content_reel_page.dart';
import 'package:shortzz/screen/home_screen/home_screen_controller.dart';
import 'package:shortzz/screen/reels_screen/reel/native_ad_reel_page.dart';
import 'package:shortzz/screen/reels_screen/reel/ima_ad_reel_page.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ContentFeedScreen extends StatefulWidget {
  final HomeScreenController homeController;
  final Widget topBar;

  const ContentFeedScreen({
    super.key,
    required this.homeController,
    required this.topBar,
  });

  @override
  State<ContentFeedScreen> createState() => _ContentFeedScreenState();
}

class _ContentFeedScreenState extends State<ContentFeedScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.homeController;

    return Scaffold(
      backgroundColor: blackPure(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: MyRefreshIndicator(
                  onRefresh: () => ctrl.fetchContentForTab(reset: true),
                  shouldRefresh: true,
                  child: Obx(() {
                    final feedItems = ctrl.contentFeedItems;
                    final posts = ctrl.contentPosts;
                    final isLoading = ctrl.isContentLoading.value;

                    if (isLoading && posts.isEmpty) {
                      return Center(child: CupertinoActivityIndicator(color: textLightGrey(context)));
                    }
                    if (!isLoading && posts.isEmpty) {
                      return const NoDataWidgetWithScroll(
                        title: 'No content yet',
                        description: 'Content will appear here once creators start uploading.',
                      );
                    }

                    return PageView.builder(
                      controller: _pageController,
                      physics: const CustomPageViewScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: feedItems.length,
                      onPageChanged: (index) {
                        // Fetch more when near the end
                        if (index >= feedItems.length - 3) {
                          ctrl.fetchContentForTab(reset: false);
                        }
                      },
                      itemBuilder: (context, index) {
                        final item = feedItems[index];
                        if (item is VastFeedAdItem) {
                          return const ImaAdReelPage();
                        }
                        if (item is NativeAdFeedItem) {
                          return const NativeAdReelPage();
                        }
                        final post = (item as PostFeedItem).post;
                        return ContentReelPage(
                          post: post,
                          autoPlay: true,
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),

          // Top bar (horizontal tabs)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: widget.topBar,
          ),

          // Sub-tabs + Filters below the top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ContentSubTabs(controller: ctrl),
                const SizedBox(height: 6),
                ContentFilterBar(controller: ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
