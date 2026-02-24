import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/gradient_text.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/hashtag_model.dart';
import 'package:shortzz/model/post_story/post/enhanced_explore_model.dart';
import 'package:shortzz/model/post_story/post/explore_page_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/challenge_screen/challenge_screen.dart';
import 'package:shortzz/screen/explore_screen/explore_screen_controller.dart';
import 'package:shortzz/screen/search_screen/search_screen.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExploreScreenController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchScreenTopView(controller: controller),
        Expanded(
          child: Obx(() {
            final isLoading = controller.isLoading.value;
            final exploreData = controller.explorePageData.value;
            final enhanced = controller.enhancedData.value;
            final hasData = (exploreData?.highPostHashtags?.isNotEmpty ?? false) ||
                enhanced != null;

            return MyRefreshIndicator(
              onRefresh: controller.refreshAll,
              child: isLoading && exploreData == null
                  ? const LoaderWidget()
                  : NoDataView(
                      showShow: !isLoading && !hasData,
                      title: LKey.searchPageEmptyTitle.tr,
                      description: LKey.searchPageEmptyDescription.tr,
                      child: _ExploreBody(
                        exploreData: exploreData,
                        enhancedData: enhanced,
                        controller: controller,
                      ),
                    ),
            );
          }),
        ),
      ],
    );
  }
}

/// Main body that combines enhanced sections with the existing hashtag grid
class _ExploreBody extends StatelessWidget {
  final ExplorePageData? exploreData;
  final EnhancedExploreData? enhancedData;
  final ExploreScreenController controller;

  const _ExploreBody({
    required this.exploreData,
    required this.enhancedData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Featured content carousel
        if (enhancedData?.featured?.isNotEmpty ?? false)
          _FeaturedSection(
            posts: enhancedData!.featured!,
            controller: controller,
          ),

        // Popular creators horizontal list
        if (enhancedData?.popularCreators?.isNotEmpty ?? false)
          _PopularCreatorsSection(
            creators: enhancedData!.popularCreators!,
            controller: controller,
          ),

        // Challenges banner
        _ChallengesBanner(),

        // Content type sections (Music Videos, Trailers, News)
        if (enhancedData?.contentSections?.isNotEmpty ?? false)
          ...enhancedData!.contentSections!.map((section) =>
              _ContentTypeSection(section: section, controller: controller)),

        // Existing hashtag-based grid
        if (exploreData?.highPostHashtags?.isNotEmpty ?? false)
          ...exploreData!.highPostHashtags!.map((item) {
            final posts = _preparePostList(item);
            if (posts.isEmpty) return const SizedBox.shrink();
            return Column(
              children: [
                _HashtagHeader(item: item, controller: controller),
                _PostGrid(posts: posts, controller: controller),
              ],
            );
          }),
      ],
    );
  }

  List<Post> _preparePostList(HighPostHashtags highPostHashtags) {
    final posts = List<Post>.from(highPostHashtags.postList ?? []);
    if (posts.length >= 5) {
      final reelPostIndex =
          posts.indexWhere((p) => p.postType == PostType.reel);
      if (reelPostIndex != -1) {
        final reelPost = posts.removeAt(reelPostIndex);
        posts.insert(2, reelPost);
      }
    }
    return posts;
  }
}

// ─── Featured Content Carousel ──────────────────────────────────────

class _FeaturedSection extends StatelessWidget {
  final List<Post> posts;
  final ExploreScreenController controller;

  const _FeaturedSection({required this.posts, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                'Featured',
                style: TextStyleCustom.unboundedSemiBold600(
                  color: textDarkGrey(context),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final image = (post.postType == PostType.image &&
                          (post.images?.isNotEmpty ?? false)
                      ? post.images!.first.image
                      : post.thumbnail)
                  ?.addBaseURL();

              return GestureDetector(
                onTap: () => controller.onPostTap(post),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomImage(
                          size: const Size(150, 200),
                          radius: 10,
                          image: image,
                          isShowPlaceHolder: true,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black87, Colors.transparent],
                              ),
                            ),
                            child: Text(
                              post.description ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Popular Creators ───────────────────────────────────────────────

class _PopularCreatorsSection extends StatelessWidget {
  final List<User> creators;
  final ExploreScreenController controller;

  const _PopularCreatorsSection({
    required this.creators,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Row(
            children: [
              Icon(Icons.people_rounded,
                  color: themeAccentSolid(context), size: 20),
              const SizedBox(width: 6),
              Text(
                'Popular Creators',
                style: TextStyleCustom.unboundedSemiBold600(
                  color: textDarkGrey(context),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: creators.length,
            itemBuilder: (context, index) {
              final user = creators[index];
              return GestureDetector(
                onTap: () => controller.onCreatorTap(user),
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                themeAccentSolid(context).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CustomImage(
                            size: const Size(56, 56),
                            radius: 28,
                            image: user.profilePhoto?.addBaseURL(),
                            isShowPlaceHolder: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.username ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyleCustom.outFitRegular400(
                          color: textDarkGrey(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Content Type Section (Music Videos, Trailers, News) ────────────

class _ContentTypeSection extends StatelessWidget {
  final ContentSection section;
  final ExploreScreenController controller;

  const _ContentTypeSection({
    required this.section,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final posts = section.posts ?? [];
    if (posts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Text(
            section.label ?? 'Content',
            style: TextStyleCustom.unboundedSemiBold600(
              color: textDarkGrey(context),
              fontSize: 15,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final image = post.thumbnail?.addBaseURL();
              return GestureDetector(
                onTap: () => controller.onPostTap(post),
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomImage(
                          size: const Size(130, 180),
                          radius: 10,
                          image: image,
                          isShowPlaceHolder: true,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black87, Colors.transparent],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (post.contentMetadata?['artist'] != null)
                                  Text(
                                    post.contentMetadata!['artist'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                Text(
                                  post.description ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Existing Components (preserved) ────────────────────────────────

class SearchScreenTopView extends StatelessWidget {
  final ExploreScreenController controller;

  const SearchScreenTopView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scaffoldBackgroundColor(context),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          _buildSearchBar(context),
          _buildHashtagList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Get.to(() => const SearchScreen()),
              child: Container(
                height: 35,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(cornerRadius: 7),
                    side: BorderSide(color: bgGrey(context)),
                  ),
                  color: bgMediumGrey(context),
                ),
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  LKey.searchHere.tr,
                  style: TextStyleCustom.outFitLight300(
                    fontSize: 15,
                    color: textLightGrey(context),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: controller.onScanQrCode,
            child: Image.asset(AssetRes.icQrCode, height: 26, width: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildHashtagList() {
    return Obx(
      () {
        // Prefer trending hashtags from enhanced data, fall back to explore data
        final hashtags =
            controller.enhancedData.value?.trendingHashtags ??
            controller.explorePageData.value?.hashtags ??
            [];
        return SearchScreenHashTagView(
          hashtags: hashtags,
          controller: controller,
        );
      },
    );
  }
}

class SearchScreenHashTagView extends StatelessWidget {
  final List<Hashtag> hashtags;
  final ExploreScreenController controller;

  const SearchScreenHashTagView({
    super.key,
    required this.hashtags,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (hashtags.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 35,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: hashtags.length,
        itemBuilder: (context, index) =>
            _buildHashtagItem(context, hashtags[index]),
      ),
    );
  }

  Widget _buildHashtagItem(BuildContext context, Hashtag hashtag) {
    return InkWell(
      onTap: () => controller.onExploreTap(hashtag.hashtag ?? ''),
      child: FittedBox(
        child: Container(
          height: 35,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 7, cornerSmoothing: 1),
              side: BorderSide(color: bgGrey(context)),
            ),
            color: bgMediumGrey(context),
          ),
          alignment: Alignment.center,
          child: Text(
            '#${hashtag.hashtag}',
            style: TextStyleCustom.outFitRegular400(
              color: textLightGrey(context),
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChallengesBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const ChallengeScreen()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeAccentSolid(context),
              themeAccentSolid(context).withValues(alpha: .7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Challenges',
                    style: TextStyleCustom.outFitSemiBold600(
                        fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Join trending challenges & win prizes',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

class _HashtagHeader extends StatelessWidget {
  final HighPostHashtags item;
  final ExploreScreenController controller;

  const _HashtagHeader({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 10, top: 12, bottom: 12),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: themeAccentSolid(context).withValues(alpha: .2),
                width: 1.5,
              ),
            ),
            child: GradientText(
              '#',
              gradient: StyleRes.themeGradient,
              style: TextStyleCustom.outFitMedium500(fontSize: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.hashtag ?? '',
                  style: TextStyleCustom.unboundedSemiBold600(
                    color: textDarkGrey(context),
                  ),
                ),
                Text(
                  '${(item.postList?.length ?? 0).numberFormat} ${LKey.posts.tr}',
                  style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => controller.onExploreTap(item.hashtag),
            child: Row(
              children: [
                Text(
                  LKey.explore.tr,
                  style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context),
                  ),
                ),
                Image.asset(
                  AssetRes.icRightArrow,
                  color: textLightGrey(context),
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostGrid extends StatelessWidget {
  final List<Post> posts;
  final ExploreScreenController controller;

  const _PostGrid({required this.posts, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: posts.length >= 5 ? 5 : posts.length,
      padding: EdgeInsets.zero,
      gridDelegate: SliverQuiltedGridDelegate(
          crossAxisCount: 3,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          repeatPattern: QuiltedGridRepeatPattern.inverted,
          pattern: [
            const QuiltedGridTile(1, 1),
            const QuiltedGridTile(1, 1),
            posts.length <= 4
                ? const QuiltedGridTile(1, 1)
                : const QuiltedGridTile(2, 1),
            const QuiltedGridTile(1, 1),
            const QuiltedGridTile(1, 1),
          ]),
      itemBuilder: (context, index) {
        final post = posts[index];
        final image =
            (post.postType == PostType.image &&
                        (post.images?.isNotEmpty ?? false)
                    ? post.images!.first.image
                    : post.thumbnail)
                ?.addBaseURL();

        return InkWell(
          onTap: () => controller.onPostTap(post),
          child: CustomImage(
            size: const Size(double.infinity, double.infinity),
            radius: 0,
            image: image,
            isShowPlaceHolder: true,
          ),
        );
      },
    );
  }
}
