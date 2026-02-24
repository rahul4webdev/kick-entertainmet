import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/model/post_story/post/enhanced_explore_model.dart';
import 'package:shortzz/model/post_story/post/explore_page_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/hashtag_screen/hashtag_screen.dart';
import 'package:shortzz/screen/post_screen/single_post_screen.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/screen/scan_qr_code_screen/scan_qr_code_screen.dart';
import 'package:shortzz/screen/video_player_screen/video_player_screen.dart';

class ExploreScreenController extends BaseController {
  Rx<ExplorePageData?> explorePageData = Rx(null);
  Rx<EnhancedExploreData?> enhancedData = Rx(null);

  @override
  void onInit() {
    super.onInit();
    fetchExplorePageData();
    fetchEnhancedExplore();
  }

  Future<void> fetchExplorePageData() async {
    isLoading.value = true;
    explorePageData.value = await PostService.instance.fetchExplorePageData();
    isLoading.value = false;
  }

  Future<void> fetchEnhancedExplore() async {
    enhancedData.value = await PostService.instance.fetchEnhancedExplore();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchExplorePageData(),
      fetchEnhancedExplore(),
    ]);
  }

  void onExploreTap(String? hashtag) {
    Get.to(() => HashtagScreen(hashtag: hashtag ?? '', index: 0),
        preventDuplicates: false);
  }

  void onPostTap(Post post) {
    switch (post.postType) {
      case PostType.reel:
        Get.to(() => ReelsScreen(reels: [post].obs, position: 0));
        break;
      case PostType.image:
        Get.to(() => SinglePostScreen(post: post, isFromNotification: false));
        break;
      case PostType.video:
        Get.to(() => VideoPlayerScreen(post: post));
        break;
      case PostType.text:
        break;
      case PostType.none:
        Loggers.error('Post Type none');
        break;
    }
  }

  void onCreatorTap(User user) {
    NavigationService.shared.openProfileScreen(user);
  }

  void onScanQrCode() {
    Get.to(() => const ScanQrCodeScreen());
  }
}
