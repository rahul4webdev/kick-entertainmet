import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/search_result_tile.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/common/widget/user_list.dart';
import 'package:shortzz/common/service/api/product_service.dart';
import 'package:shortzz/model/product/product_model.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/hashtag_model.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen_controller.dart';
import 'package:shortzz/screen/create_feed_screen/widget/create_feed_location_bar.dart';
import 'package:shortzz/screen/create_feed_screen/widget/feed_ai_generated_toggle.dart';
import 'package:shortzz/screen/create_feed_screen/widget/feed_comment_toggle.dart';
import 'package:shortzz/screen/create_feed_screen/widget/feed_hide_like_count_toggle.dart';
import 'package:shortzz/screen/create_feed_screen/widget/feed_visibility_picker.dart';
import 'package:shortzz/screen/create_feed_screen/widget/feed_image_view.dart';
import 'package:shortzz/screen/create_feed_screen/widget/feed_poll_view.dart';
import 'package:shortzz/screen/create_feed_screen/widget/feed_text_field_view.dart';
import 'package:shortzz/screen/thread_screen/create_thread_screen.dart';
import 'package:shortzz/screen/create_feed_screen/widget/feed_video_view.dart';
import 'package:shortzz/screen/create_feed_screen/widget/reel_preview_card.dart';
import 'package:shortzz/screen/create_feed_screen/widget/url_meta_data_card.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

enum CreateFeedType { feed, reel }

class CreateFeedScreen extends StatelessWidget {
  final CreateFeedType createType;
  final PostStoryContent? content;
  final Function({Post? post, CreateFeedType? type})? onAddPost;

  const CreateFeedScreen(
      {super.key, required this.createType, this.onAddPost, this.content});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(CreateFeedScreenController(onAddPost, createType, content.obs));

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.createFeed.tr),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  controller.commentHelper.detectableTextFocusNode.unfocus(),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ReelPreviewCard(controller: controller),
                        CreateFeedLocationBar(controller: controller),
                        const FeedTextFieldView(),
                        UrlMetaDataCard(controller: controller),
                        if (createType == CreateFeedType.feed)
                          mediaSelectionView(controller),
                        const SizedBox(height: 5),
                        Obx(
                          () => switch (controller.feedPostType.value) {
                            FeedPostType.text => const SizedBox(),
                            FeedPostType.image => FeedImageView(
                                files: controller.images,
                                controller: controller),
                            FeedPostType.video =>
                              FeedVideoView(controller: controller),
                            FeedPostType.poll =>
                              FeedPollView(controller: controller),
                          },
                        ),
                        const FeedVisibilityPicker(),
                        const FeedCommentToggle(),
                        const FeedHideLikeCountToggle(),
                        const FeedAiGeneratedToggle(),
                        _collaboratorRow(controller, context),
                        _productTagRow(controller, context),
                        if (createType == CreateFeedType.reel)
                          _captionRow(controller, context),
                        _scheduleRow(controller, context),
                        _uploadButton(controller, context),
                        _saveAsDraftButton(controller, context),
                      ],
                    ),
                  ),
                  Obx(() => mentionOrHashtagView(controller, context))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget mediaSelectionView(CreateFeedScreenController controller) {
    return Obx(
        () => controller.images.isNotEmpty ||
                controller.video.value != null ||
                controller.feedPostType.value == FeedPostType.poll
            ? const SizedBox()
            : Row(
                children: [
                  BuildImageContainer(
                      image: AssetRes.icImage,
                      onTap: () => controller.onMediaTap(FeedPostType.image)),
                  const SizedBox(width: 5),
                  BuildImageContainer(
                      image: AssetRes.icVideo,
                      onTap: () => controller.onMediaTap(FeedPostType.video)),
                  const SizedBox(width: 5),
                  _BuildPollButton(
                      onTap: () => controller.onMediaTap(FeedPostType.poll)),
                  const SizedBox(width: 5),
                  _BuildThreadButton(
                      onTap: () => Get.to(() => const CreateThreadScreen())),
                ],
              ));
  }

  Widget _captionRow(
      CreateFeedScreenController controller, BuildContext context) {
    return Obx(() {
      final hasCaptions = controller.captionsList.isNotEmpty;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: InkWell(
          onTap: controller.onCaptionsTap,
          child: Row(
            children: [
              Icon(Icons.closed_caption,
                  size: 22, color: textDarkGrey(context)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasCaptions ? LKey.editCaptions.tr : LKey.addCaptions.tr,
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 14, color: whitePure(context)),
                ),
              ),
              if (hasCaptions)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${controller.captionsList.length}',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 12, color: themeAccentSolid(context)),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right,
                  size: 20, color: textLightGrey(context)),
            ],
          ),
        ),
      );
    });
  }

  Widget _collaboratorRow(
      CreateFeedScreenController controller, BuildContext context) {
    return Obx(() {
      final collabs = controller.selectedCollaborators;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: InkWell(
          onTap: () => _showCollaboratorPicker(context, controller),
          child: Row(
            children: [
              Icon(Icons.people_outline,
                  size: 22, color: textDarkGrey(context)),
              const SizedBox(width: 10),
              Expanded(
                child: collabs.isEmpty
                    ? Text(
                        'Add Collaborators',
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 14, color: whitePure(context)),
                      )
                    : SizedBox(
                        height: 28,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: collabs.length,
                          itemBuilder: (context, index) {
                            final user = collabs[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: themeAccentSolid(context)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomImage(
                                    size: const Size(18, 18),
                                    image: user.profilePhoto?.addBaseURL(),
                                    strokeWidth: 0,
                                    fullName: user.fullname,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.username ?? '',
                                    style: TextStyleCustom.outFitRegular400(
                                        fontSize: 11,
                                        color: themeAccentSolid(context)),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => collabs.removeAt(index),
                                    child: Icon(Icons.close,
                                        size: 14,
                                        color: themeAccentSolid(context)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
              if (collabs.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${collabs.length}/5',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 12, color: themeAccentSolid(context)),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right,
                  size: 20, color: textLightGrey(context)),
            ],
          ),
        ),
      );
    });
  }

  void _showCollaboratorPicker(
      BuildContext context, CreateFeedScreenController controller) {
    final searchController = TextEditingController();
    final searchResults = <User>[].obs;
    final isSearching = false.obs;

    void search(String query) async {
      if (query.length < 2) {
        searchResults.clear();
        return;
      }
      isSearching.value = true;
      try {
        final results = await UserService.instance
            .searchUsers(keyWord: query, limit: 20);
        // Filter out already selected and self
        searchResults.value = results
            .where((u) =>
                u.id != controller.myUser?.id &&
                !controller.selectedCollaborators.any((c) => c.id == u.id))
            .toList();
      } catch (_) {}
      isSearching.value = false;
    }

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textLightGrey(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Collaborators',
              style: TextStyleCustom.unboundedMedium500(
                  fontSize: 16, color: textDarkGrey(context)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: search,
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 14, color: textDarkGrey(context)),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyleCustom.outFitRegular400(
                      fontSize: 14, color: textLightGrey(context)),
                  prefixIcon:
                      Icon(Icons.search, color: textLightGrey(context)),
                  filled: true,
                  fillColor: bgMediumGrey(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (isSearching.value) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                if (searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      searchController.text.length < 2
                          ? 'Type to search for users'
                          : 'No users found',
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 14, color: textLightGrey(context)),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: searchResults.length,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemBuilder: (context, index) {
                    final user = searchResults[index];
                    return ListTile(
                      leading: CustomImage(
                        size: const Size(40, 40),
                        image: user.profilePhoto?.addBaseURL(),
                        strokeWidth: 0,
                        fullName: user.fullname,
                      ),
                      title: Text(
                        user.username ?? '',
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 14, color: textDarkGrey(context)),
                      ),
                      subtitle: Text(
                        user.fullname ?? '',
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 12, color: textLightGrey(context)),
                      ),
                      trailing: Icon(Icons.add_circle_outline,
                          color: themeAccentSolid(context)),
                      onTap: () {
                        if (controller.selectedCollaborators.length >= 5) {
                          Get.snackbar('Limit Reached',
                              'Maximum 5 collaborators per post');
                          return;
                        }
                        controller.selectedCollaborators.add(user);
                        searchResults.removeAt(index);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _productTagRow(
      CreateFeedScreenController controller, BuildContext context) {
    return Obx(() {
      final tagIds = controller.selectedProductTagIds;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: InkWell(
          onTap: () => _showProductTagPicker(context, controller),
          child: Row(
            children: [
              Icon(Icons.shopping_bag_outlined,
                  size: 22, color: textDarkGrey(context)),
              const SizedBox(width: 10),
              Expanded(
                child: tagIds.isEmpty
                    ? Text(
                        LKey.tagProducts,
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 14, color: whitePure(context)),
                      )
                    : Text(
                        '${tagIds.length} ${LKey.productsTagged}',
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 14, color: themeAccentSolid(context)),
                      ),
              ),
              if (tagIds.isNotEmpty)
                GestureDetector(
                  onTap: () => tagIds.clear(),
                  child: Icon(Icons.close,
                      size: 18, color: textLightGrey(context)),
                ),
              if (tagIds.isNotEmpty) const SizedBox(width: 8),
              if (tagIds.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tagIds.length}/5',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 12, color: themeAccentSolid(context)),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right,
                  size: 20, color: textLightGrey(context)),
            ],
          ),
        ),
      );
    });
  }

  void _showProductTagPicker(
      BuildContext context, CreateFeedScreenController controller) {
    final searchController = TextEditingController();
    final searchResults = <Product>[].obs;
    final isSearching = false.obs;

    void search(String query) async {
      if (query.length < 2) {
        searchResults.clear();
        return;
      }
      isSearching.value = true;
      try {
        final response =
            await ProductService.instance.fetchProducts(search: query, limit: 20);
        if (response.status == true && response.data != null) {
          searchResults.value = response.data!
              .where((p) =>
                  !controller.selectedProductTagIds.contains(p.id))
              .toList();
        }
      } catch (_) {}
      isSearching.value = false;
    }

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textLightGrey(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LKey.tagProducts,
              style: TextStyleCustom.unboundedMedium500(
                  fontSize: 16, color: textDarkGrey(context)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: search,
                decoration: InputDecoration(
                  hintText: LKey.searchProducts,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (isSearching.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      searchController.text.length < 2
                          ? LKey.searchProducts
                          : LKey.noProducts,
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 14, color: textLightGrey(context)),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final product = searchResults[index];
                    return ListTile(
                      leading: product.firstImageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                product.firstImageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 40,
                                  height: 40,
                                  color: bgMediumGrey(context),
                                  child: const Icon(Icons.shopping_bag_outlined,
                                      size: 20),
                                ),
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: bgMediumGrey(context),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined,
                                  size: 20),
                            ),
                      title: Text(
                        product.name ?? '',
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 14, color: textDarkGrey(context)),
                      ),
                      subtitle: Text(
                        '${product.priceCoins ?? 0} ${LKey.coinsText}',
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 12, color: themeAccentSolid(context)),
                      ),
                      trailing: Icon(Icons.add_circle_outline,
                          color: themeAccentSolid(context)),
                      onTap: () {
                        if (controller.selectedProductTagIds.length >= 5) {
                          Get.snackbar(LKey.error,
                              'Maximum 5 product tags per post');
                          return;
                        }
                        if (product.id != null) {
                          controller.selectedProductTagIds.add(product.id!);
                          searchResults.removeAt(index);
                        }
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _scheduleRow(
      CreateFeedScreenController controller, BuildContext context) {
    return Obx(() {
      final scheduled = controller.scheduledAt.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: InkWell(
          onTap: controller.onScheduleTap,
          child: Row(
            children: [
              Icon(Icons.schedule,
                  size: 22, color: textDarkGrey(context)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  scheduled != null
                      ? '${LKey.scheduledFor.tr} ${DateFormat('MMM d, yyyy – h:mm a').format(scheduled)}'
                      : LKey.schedulePost.tr,
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 14, color: whitePure(context)),
                ),
              ),
              if (scheduled != null)
                InkWell(
                  onTap: controller.clearSchedule,
                  child: Icon(Icons.close,
                      size: 18, color: textLightGrey(context)),
                ),
              if (scheduled == null)
                Icon(Icons.chevron_right,
                    size: 20, color: textLightGrey(context)),
            ],
          ),
        ),
      );
    });
  }

  Widget _uploadButton(
      CreateFeedScreenController controller, BuildContext context) {
    return Obx(() {
      RxBool isEmpty = (createType == CreateFeedType.feed &&
              controller.commentHelper.isDetectableTextEmpty.value &&
              controller.feedPostType.value == FeedPostType.text)
          .obs;

      final isScheduled = controller.scheduledAt.value != null;
      return TextButtonCustom(
        onTap: controller.handleUpload,
        title: isScheduled ? LKey.schedulePost.tr : LKey.uploadNow.tr,
        backgroundColor:
            textDarkGrey(context).withValues(alpha: isEmpty.value ? .5 : 1),
        titleColor:
            whitePure(context).withValues(alpha: isEmpty.value ? .5 : 1),
        margin: EdgeInsets.symmetric(
            vertical: AppBar().preferredSize.height, horizontal: 20),
      );
    });
  }

  Widget _saveAsDraftButton(
      CreateFeedScreenController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: controller.saveAsDraft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_outlined, size: 18, color: textLightGrey(context)),
            const SizedBox(width: 6),
            Text(
              LKey.saveAsDraft.tr,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 14, color: textLightGrey(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget mentionOrHashtagView(
      CreateFeedScreenController controller, BuildContext context) {
    if (!controller.commentHelper.isMentionUserView.value &&
        !controller.commentHelper.isHashTagView.value) {
      return const SizedBox();
    }
    final bool isMentionView = controller.commentHelper.isMentionUserView.value;
    final items = isMentionView
        ? controller.commentHelper.searchUsers
        : controller.commentHelper.hashTags;

    itemBuilder(context, index) {
      final item = items[index];
      if (isMentionView) {
        User user = item as User;
        return UserCard(
          onTap: () => controller.commentHelper
              .appendDetection(user, DetectType.atSign, type: 1),
          fullName: user.fullname,
          profilePhoto: user.profilePhoto,
          userName: user.username,
        );
      }
      Hashtag hashtag = item as Hashtag;
      return SearchResultTile(
        description: '${hashtag.postCount} ${LKey.posts.tr}',
        title: '${AppRes.hash}${hashtag.hashtag ?? ' '}',
        onTap: () => controller.commentHelper
            .appendDetection(hashtag, DetectType.hashTag, type: 1),
        image: AssetRes.icHashtag,
      );
    }

    return Container(
      color: (!controller.commentHelper.isLoading.value && items.isEmpty)
          ? null
          : bgLightGrey(context),
      height: double.infinity,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 180),
      child: controller.commentHelper.isLoading.value
          ? const LoaderWidget()
          : items.isEmpty
              ? const SizedBox()
              : ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.only(top: 5, left: 13, right: 13),
                  itemBuilder: itemBuilder),
    );
  }
}

class BuildImageContainer extends StatelessWidget {
  final String image;
  final VoidCallback onTap;

  const BuildImageContainer(
      {super.key, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 59,
          decoration: BoxDecoration(color: bgLightGrey(context)),
          child: Center(
            child: Image.asset(image,
                color: textDarkGrey(context), height: 29, width: 29),
          ),
        ),
      ),
    );
  }
}

class _BuildPollButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BuildPollButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 59,
          decoration: BoxDecoration(color: bgLightGrey(context)),
          child: Center(
            child: Icon(Icons.poll_outlined,
                color: textDarkGrey(context), size: 29),
          ),
        ),
      ),
    );
  }
}

class _BuildThreadButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BuildThreadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 59,
          decoration: BoxDecoration(color: bgLightGrey(context)),
          child: Center(
            child: Icon(Icons.segment,
                color: textDarkGrey(context), size: 29),
          ),
        ),
      ),
    );
  }
}
