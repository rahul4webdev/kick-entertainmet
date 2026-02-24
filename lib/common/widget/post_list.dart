import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/load_more_widget.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/common/widget/native_ad_card.dart';
import 'package:shortzz/model/post_story/feed_item.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/post_screen/post_card.dart';

class PostList extends StatelessWidget {
  final RxList<Post> posts;
  final RxList<FeedItem>? feedItems;
  final RxBool isLoading;
  final Future<void> Function()? onFetchMoreData;
  final bool shrinkWrap;
  final bool shouldShowPinOption;
  final bool isMe;
  final bool showNoData;

  const PostList({
    super.key,
    required this.posts,
    this.feedItems,
    required this.isLoading,
    this.onFetchMoreData,
    this.shrinkWrap = false,
    this.shouldShowPinOption = false,
    this.isMe = false,
    this.showNoData = true,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value && posts.isEmpty) {
        return const LoaderWidget();
      }

      if (!isLoading.value && posts.isEmpty) {
        return showNoData ? _buildNoDataView() : const SizedBox();
      }

      final items = feedItems;
      final itemCount = items?.length ?? posts.length;

      return LoadMoreWidget(
        loadMore: onFetchMoreData ?? () async {},
        child: ListView.builder(
          itemCount: itemCount,
          primary: !shrinkWrap,
          shrinkWrap: shrinkWrap,
          padding: EdgeInsets.only(bottom: AppBar().preferredSize.height / 2),
          itemBuilder: (context, index) {
            if (items != null && index < items.length) {
              final item = items[index];
              return switch (item) {
                PostFeedItem(:final post) => _buildPostCard(post),
                NativeAdFeedItem() => const NativeAdCard(),
                VastFeedAdItem() => const NativeAdCard(),
              };
            }
            return _buildPostCard(posts[index]);
          },
        ),
      );
    });
  }

  Widget _buildNoDataView() {
    return Stack(
      children: [
        NoDataView(
          title: isMe ? LKey.noMyPostsTitle.tr : LKey.noUserPostsTitle.tr,
          description: isMe
              ? LKey.noMyPostsDescription.tr
              : LKey.noUserPostsDescription.tr,
          showShow: !isLoading.value && posts.isEmpty,
        ),
        SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(Get.context!).size.height,
                width: MediaQuery.of(Get.context!).size.width,
                color: Colors.transparent)),
      ],
    );
  }

  Widget _buildPostCard(Post post) {
    return PostCard(
        post: post,
        shouldShowPinOption: shouldShowPinOption,
        likeKey: GlobalKey());
  }
}
