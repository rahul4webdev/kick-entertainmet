import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/instagram_service.dart';
import 'package:shortzz/model/general/instagram_media_model.dart';
import 'package:shortzz/screen/instagram_import_screen/widget/instagram_oauth_webview.dart';

class InstagramImportScreenController extends BaseController {
  RxBool isConnected = false.obs;
  RxBool autoSyncEnabled = false.obs;
  RxBool isLoadingMedia = false.obs;
  RxBool isImporting = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool tokenExpired = false.obs;
  RxString instagramUserId = ''.obs;
  RxList<InstagramMedia> mediaList = <InstagramMedia>[].obs;
  String? nextCursor;

  int get selectedCount => mediaList.where((m) => m.isSelected).length;

  @override
  void onInit() {
    super.onInit();
    fetchConnectionStatus();
  }

  Future<void> fetchConnectionStatus() async {
    try {
      final result = await InstagramService.instance.getConnectionStatus();
      if (result.status == true && result.data != null) {
        isConnected.value = result.data!.isConnected;
        autoSyncEnabled.value = result.data!.autoSyncEnabled;
        instagramUserId.value = result.data!.instagramUserId ?? '';
        tokenExpired.value = result.data!.tokenExpired;
        if (isConnected.value && !tokenExpired.value) {
          fetchMedia();
        }
      }
    } catch (e) {
      showSnackBar('Failed to check connection status');
    }
  }

  Future<void> connectInstagram() async {
    final settings = SessionManager.instance.getSettings();
    final appId = settings?.instagramAppId;
    final redirectUri = settings?.instagramRedirectUri;

    if (appId == null || redirectUri == null) {
      showSnackBar('Instagram is not configured');
      return;
    }

    final authUrl = 'https://www.instagram.com/oauth/authorize'
        '?client_id=$appId'
        '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
        '&scope=instagram_business_basic,instagram_business_content_publish'
        '&response_type=code'
        '&state=instagram_connect';

    final code = await Get.to<String?>(
      () => InstagramOAuthWebView(
        authUrl: authUrl,
        redirectUri: redirectUri,
      ),
    );

    if (code != null && code.isNotEmpty) {
      showLoader();
      try {
        final result =
            await InstagramService.instance.handleOAuthCallback(code: code);
        stopLoader();
        if (result.status == true) {
          showSnackBar('Instagram connected successfully');
          fetchConnectionStatus();
        } else {
          showSnackBar(result.message ?? 'Failed to connect Instagram');
        }
      } catch (e) {
        stopLoader();
        showSnackBar('Failed to connect Instagram');
      }
    }
  }

  Future<void> disconnectInstagram() async {
    showLoader();
    try {
      final result = await InstagramService.instance.disconnect();
      stopLoader();
      if (result.status == true) {
        isConnected.value = false;
        autoSyncEnabled.value = false;
        instagramUserId.value = '';
        tokenExpired.value = false;
        mediaList.clear();
        nextCursor = null;
        showSnackBar('Instagram disconnected');
      } else {
        showSnackBar(result.message ?? 'Failed to disconnect');
      }
    } catch (e) {
      stopLoader();
      showSnackBar('Failed to disconnect');
    }
  }

  Future<void> fetchMedia({bool loadMore = false}) async {
    if (loadMore && nextCursor == null) return;
    if (loadMore) {
      isLoadingMore.value = true;
    } else {
      isLoadingMedia.value = true;
      mediaList.clear();
    }

    try {
      final result = await InstagramService.instance.fetchMedia(
        after: loadMore ? nextCursor : null,
      );
      if (result.status == true && result.data != null) {
        if (loadMore) {
          mediaList.addAll(result.data!.media ?? []);
        } else {
          mediaList.value = result.data!.media ?? [];
        }
        nextCursor = result.data!.nextCursor;
      } else {
        if (!loadMore) showSnackBar(result.message ?? 'Failed to load media');
      }
    } catch (e) {
      if (!loadMore) showSnackBar('Failed to load media');
    } finally {
      isLoadingMedia.value = false;
      isLoadingMore.value = false;
    }
  }

  void toggleSelection(int index) {
    final media = mediaList[index];
    if (media.isImported == true) return;
    media.isSelected = !media.isSelected;
    mediaList.refresh();
  }

  void selectAll() {
    for (var media in mediaList) {
      if (media.isImported != true) {
        media.isSelected = true;
      }
    }
    mediaList.refresh();
  }

  void deselectAll() {
    for (var media in mediaList) {
      media.isSelected = false;
    }
    mediaList.refresh();
  }

  Future<void> importSelected() async {
    final selected = mediaList.where((m) => m.isSelected).toList();
    if (selected.isEmpty) {
      showSnackBar('No videos selected');
      return;
    }

    isImporting.value = true;
    try {
      if (selected.length == 1) {
        final media = selected.first;
        final result = await InstagramService.instance.importVideo(
          instagramMediaId: media.id!,
          mediaData: media.toJson(),
        );
        if (result.status == true) {
          media.isImported = true;
          media.isSelected = false;
          mediaList.refresh();
          showSnackBar('Video queued for import');
        } else {
          showSnackBar(result.message ?? 'Import failed');
        }
      } else {
        final mediaListData = selected.map((m) => m.toJson()).toList();
        final result = await InstagramService.instance.importBulk(
          mediaList: mediaListData,
        );
        if (result.status == true) {
          for (var media in selected) {
            media.isImported = true;
            media.isSelected = false;
          }
          mediaList.refresh();
          showSnackBar('${selected.length} videos queued for import');
        } else {
          showSnackBar(result.message ?? 'Import failed');
        }
      }
    } catch (e) {
      showSnackBar('Import failed');
    } finally {
      isImporting.value = false;
    }
  }

  Future<void> toggleAutoSync(bool enabled) async {
    try {
      final result =
          await InstagramService.instance.toggleAutoSync(enabled: enabled);
      if (result.status == true) {
        autoSyncEnabled.value = enabled;
        showSnackBar(
            enabled ? 'Auto-sync enabled' : 'Auto-sync disabled');
      } else {
        showSnackBar(result.message ?? 'Failed to update auto-sync');
      }
    } catch (e) {
      showSnackBar('Failed to update auto-sync');
    }
  }

  Future<void> refreshData() async {
    await fetchConnectionStatus();
  }
}
