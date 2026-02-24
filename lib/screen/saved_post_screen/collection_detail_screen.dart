import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/post_list.dart';
import 'package:shortzz/common/widget/reel_list.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/collection/collection_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CollectionDetailScreen extends StatelessWidget {
  final SaveCollection collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CollectionDetailController(collectionId: collection.id!),
      tag: 'collection_${collection.id}',
    );
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: collection.name ?? LKey.collections.tr),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.posts.isEmpty) {
                return const LoaderWidget();
              }
              if (controller.posts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_outline,
                          size: 64, color: textLightGrey(context)),
                      const SizedBox(height: 12),
                      Text(
                        LKey.noPosts.tr,
                        style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Separate reels and feed posts
              final reels = controller.posts
                  .where((p) => p.postType == PostType.reel)
                  .toList();
              final feedPosts = controller.posts
                  .where((p) => p.postType != PostType.reel)
                  .toList();

              if (reels.isNotEmpty && feedPosts.isEmpty) {
                return ReelList(
                  reels: RxList(reels),
                  isLoading: controller.isLoadingMore,
                  onFetchMoreData: () => controller.fetchMore(),
                );
              }
              if (feedPosts.isNotEmpty && reels.isEmpty) {
                return PostList(
                  posts: RxList(feedPosts),
                  isLoading: controller.isLoadingMore,
                  onFetchMoreData: () => controller.fetchMore(),
                );
              }

              // Mix of both - show as grid
              return GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: controller.posts.length,
                itemBuilder: (context, index) {
                  final post = controller.posts[index];
                  return _PostThumbnail(post: post);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PostThumbnail extends StatelessWidget {
  final Post post;

  const _PostThumbnail({required this.post});

  @override
  Widget build(BuildContext context) {
    final thumbnail = post.thumbnail;
    if (thumbnail != null && thumbnail.isNotEmpty) {
      return Image.network(
        thumbnail,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: bgGrey(context),
          child: Icon(Icons.image, color: textLightGrey(context)),
        ),
      );
    }
    return Container(
      color: bgGrey(context),
      child: Icon(Icons.text_snippet, color: textLightGrey(context)),
    );
  }
}

class CollectionDetailController extends BaseController {
  final int collectionId;
  RxList<Post> posts = <Post>[].obs;
  RxBool isLoadingMore = false.obs;

  CollectionDetailController({required this.collectionId});

  @override
  void onInit() {
    super.onInit();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    isLoading.value = true;
    final result = await PostService.instance.fetchCollectionPosts(
      collectionId: collectionId,
    );
    posts.addAll(result);
    isLoading.value = false;
  }

  Future<List<Post>> fetchMore() async {
    if (isLoadingMore.value) return posts;
    isLoadingMore.value = true;
    final result = await PostService.instance.fetchCollectionPosts(
      collectionId: collectionId,
      lastItemId: posts.lastOrNull?.postSaveId,
    );
    if (result.isNotEmpty) {
      posts.addAll(result);
    }
    isLoadingMore.value = false;
    return posts;
  }
}
