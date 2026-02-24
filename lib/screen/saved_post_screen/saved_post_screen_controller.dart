import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/collection/collection_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';

class SavedPostScreenController extends BaseController {
  RxInt selectedTabIndex = 0.obs;
  PageController pageController = PageController();
  var items = [LKey.reels.tr, LKey.feed.tr, LKey.collections.tr];
  List<int> unsavedIds = [];

  RxList<Post> posts = <Post>[].obs;
  RxList<Post> reels = <Post>[].obs;

  RxBool isReelLoading = false.obs;
  RxBool isPostLoading = false.obs;

  // Collections
  RxList<SaveCollection> collections = <SaveCollection>[].obs;
  RxList<SaveCollection> sharedCollections = <SaveCollection>[].obs;
  RxInt allSavedCount = 0.obs;
  RxBool isCollectionsLoading = false.obs;

  // Collection invites
  RxList<Map<String, dynamic>> collectionInvites = <Map<String, dynamic>>[].obs;

  void onChangeTab(int value) {
    selectedTabIndex.value = value;
    if (value == 2 && collections.isEmpty) {
      fetchCollections();
      fetchSharedCollections();
      fetchCollectionInvites();
    }
  }

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  void initData() async {
    final result = await Future.wait({fetchReel(), fetchPost()});
    List<Post> reels = result[0];
    List<Post> posts = result[1];

    if (reels.isEmpty && posts.isNotEmpty) {
      pageController.animateToPage(1,
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
    }
  }

  Future<List<Post>> fetchPost() async {
    if (isPostLoading.value) return posts;
    isPostLoading.value = true;
    List<Post> _post = await PostService.instance.fetchSavedPosts(
        type: PostType.posts, lastItemId: posts.lastOrNull?.postSaveId);
    if (_post.isNotEmpty) {
      posts.addAll(_post);
    }

    isPostLoading.value = false;
    return posts;
  }

  Future<List<Post>> fetchReel() async {
    if (isReelLoading.value) return reels;
    isReelLoading.value = true;
    List<Post> _post = await PostService.instance.fetchSavedPosts(
        type: PostType.reels, lastItemId: reels.lastOrNull?.postSaveId);
    if (_post.isNotEmpty) {
      reels.addAll(_post);
    }
    isReelLoading.value = false;
    return reels;
  }

  Future<void> fetchCollections() async {
    isCollectionsLoading.value = true;
    final data = await PostService.instance.fetchCollections();
    if (data != null) {
      allSavedCount.value = data.allSavedCount;
      collections.value = data.collections;
    }
    isCollectionsLoading.value = false;
  }

  Future<void> createCollection(String name) async {
    final result = await PostService.instance.createCollection(name: name);
    if (result.status == true) {
      fetchCollections();
      showSnackBar(result.message);
    } else {
      showSnackBar(result.message);
    }
  }

  Future<void> deleteCollection(int collectionId) async {
    final result = await PostService.instance.deleteCollection(collectionId: collectionId);
    if (result.status == true) {
      collections.removeWhere((c) => c.id == collectionId);
      showSnackBar(result.message);
    } else {
      showSnackBar(result.message);
    }
  }

  Future<void> fetchSharedCollections() async {
    try {
      final response = await PostService.instance.fetchSharedCollections();
      if (response['status'] == true) {
        final data = response['data'] as List? ?? [];
        sharedCollections.value =
            data.map((e) => SaveCollection.fromJson(e)).toList();
      }
    } catch (_) {}
  }

  Future<void> fetchCollectionInvites() async {
    try {
      final response = await PostService.instance.fetchCollectionInvites();
      if (response['status'] == true) {
        collectionInvites.value =
            List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (_) {}
  }

  Future<void> respondToInvite(int memberId, bool accept) async {
    final result = await PostService.instance.respondCollectionInvite(
      memberId: memberId,
      accept: accept,
    );
    if (result.status == true) {
      collectionInvites.removeWhere((i) => i['id'] == memberId);
      if (accept) {
        fetchSharedCollections();
      }
      showSnackBar(result.message);
    }
  }

  Future<void> shareCollection(int collectionId, List<int> userIds) async {
    final result = await PostService.instance.shareCollection(
      collectionId: collectionId,
      userIds: userIds,
    );
    if (result.status == true) {
      fetchCollections();
      showSnackBar(result.message);
    } else {
      showSnackBar(result.message);
    }
  }

  void onBackResponse(dynamic value) async {
    Future.delayed(const Duration(milliseconds: 500), () {
      reels.removeWhere((element) => unsavedIds.contains(element.id));
      unsavedIds.clear();
    });
  }
}
