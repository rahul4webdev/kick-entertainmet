import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_tab_switcher.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/post_list.dart';
import 'package:shortzz/common/widget/reel_list.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/collection/collection_model.dart';
import 'package:shortzz/screen/saved_post_screen/saved_post_screen_controller.dart';
import 'package:shortzz/screen/saved_post_screen/collection_detail_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SavedPostScreen extends StatelessWidget {
  const SavedPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SavedPostScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: LKey.savedPosts.tr,
            widget: CustomTabSwitcher(
                onTap: (index) {
                  controller.onChangeTab(index);
                  controller.pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear);
                },
                selectedIndex: controller.selectedTabIndex,
                items: controller.items,
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10)),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Obx(
              () => controller.isLoading.value &&
                      (controller.selectedTabIndex.value == 0
                          ? controller.posts.isEmpty
                          : controller.selectedTabIndex.value == 1
                              ? controller.reels.isEmpty
                              : controller.collections.isEmpty)
                  ? const LoaderWidget()
                  : PageView(
                      controller: controller.pageController,
                      onPageChanged: controller.onChangeTab,
                      children: [
                        ReelList(
                          reels: controller.reels,
                          isLoading: controller.isReelLoading,
                          onFetchMoreData: controller.fetchReel,
                          onBackResponse: controller.onBackResponse,
                        ),
                        PostList(
                          posts: controller.posts,
                          isLoading: controller.isPostLoading,
                          onFetchMoreData: controller.fetchPost,
                        ),
                        _CollectionsTab(controller: controller),
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }
}

class _CollectionsTab extends StatelessWidget {
  final SavedPostScreenController controller;

  const _CollectionsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCollectionsLoading.value && controller.collections.isEmpty) {
        return const LoaderWidget();
      }
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create new collection button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () => _showCreateCollectionDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: textLightGrey(context).withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: themeColor(context), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        LKey.newCollection.tr,
                        style: TextStyleCustom.outFitMedium500(
                          color: themeColor(context),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Pending invites
            if (controller.collectionInvites.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Invites',
                  style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context),
                    fontSize: 15,
                  ),
                ),
              ),
              ...controller.collectionInvites.map((invite) {
                final collection = invite['collection'] as Map<String, dynamic>?;
                final inviter = invite['inviter'] as Map<String, dynamic>?;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: bgMediumGrey(context),
                    child: const Icon(Icons.people_outline, size: 20),
                  ),
                  title: Text(
                    collection?['name'] ?? 'Collection',
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 14, color: textDarkGrey(context)),
                  ),
                  subtitle: Text(
                    'from ${inviter?['fullname'] ?? 'User'}',
                    style: TextStyleCustom.outFitLight300(
                        fontSize: 12, color: textLightGrey(context)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => controller.respondToInvite(invite['id'], true),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red.shade400),
                        onPressed: () => controller.respondToInvite(invite['id'], false),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
            // My collections
            if (controller.collections.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'My Collections',
                  style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context),
                    fontSize: 15,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: controller.collections.length,
                itemBuilder: (context, index) {
                  final collection = controller.collections[index];
                  return _CollectionCard(
                    collection: collection,
                    onTap: () {
                      Get.to(() => CollectionDetailScreen(collection: collection));
                    },
                    onLongPress: collection.isDefault
                        ? null
                        : () => _showDeleteDialog(context, collection),
                  );
                },
              ),
            ],
            // Shared with me
            if (controller.sharedCollections.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Shared with Me',
                  style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context),
                    fontSize: 15,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: controller.sharedCollections.length,
                itemBuilder: (context, index) {
                  final collection = controller.sharedCollections[index];
                  return _CollectionCard(
                    collection: collection,
                    onTap: () {
                      Get.to(() => CollectionDetailScreen(collection: collection));
                    },
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text(LKey.newCollection.tr),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: LKey.collectionName.tr,
            border: const OutlineInputBorder(),
          ),
          maxLength: 100,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LKey.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                controller.createCollection(name);
                Get.back();
              }
            },
            child: Text(LKey.createCollection.tr),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SaveCollection collection) {
    Get.dialog(
      AlertDialog(
        title: Text(LKey.deleteCollection.tr),
        content: Text(LKey.deleteCollectionConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LKey.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              if (collection.id != null) {
                controller.deleteCollection(collection.id!);
              }
              Get.back();
            },
            child: Text(LKey.delete.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final SaveCollection collection;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CollectionCard({
    required this.collection,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: bgLightGrey(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgGrey(context),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: collection.coverPost?.thumbnail != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          collection.coverPost!.thumbnail!.addBaseURL(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _placeholderIcon(context),
                        ),
                      )
                    : _placeholderIcon(context),
              ),
            ),
            // Name + count
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name ?? '',
                    style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${collection.postCount} ${LKey.posts.tr.toLowerCase()}',
                        style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context),
                          fontSize: 12,
                        ),
                      ),
                      if (collection.isShared) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.people_outline,
                            size: 14, color: themeColor(context)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon(BuildContext context) {
    return Center(
      child: Icon(
        Icons.bookmark_outline,
        size: 40,
        color: textLightGrey(context),
      ),
    );
  }
}
