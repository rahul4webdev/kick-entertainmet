import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/add_post_story_service.dart';
import 'package:shortzz/common/service/api/common_service.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/model/content/content_genre_model.dart';
import 'package:shortzz/model/content/content_language_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';

enum ContentUploadType { musicVideo, trailer, news }

class ContentUploadController extends GetxController {
  final ContentUploadType uploadType;

  ContentUploadController(this.uploadType);

  final descriptionController = TextEditingController();

  // Media
  Rx<XFile?> videoFile = Rx(null);
  Rx<XFile?> thumbnailFile = Rx(null);

  // Metadata
  RxList<ContentGenre> genres = <ContentGenre>[].obs;
  RxList<ContentLanguageItem> languages = <ContentLanguageItem>[].obs;
  Rx<ContentGenre?> selectedGenre = Rx(null);
  Rx<ContentLanguageItem?> selectedLanguage = Rx(null);

  // Music Video specific
  final artistController = TextEditingController();
  final releaseDateController = TextEditingController();

  // Trailer specific
  final productionController = TextEditingController();

  // News specific
  final sourceController = TextEditingController();
  final categoryController = TextEditingController();
  RxBool isBreaking = false.obs;

  // Link to previous part
  final linkedPostIdController = TextEditingController();

  // Product links
  RxList<ProductLink> productLinks = <ProductLink>[].obs;

  // State
  RxBool canComment = true.obs;
  RxBool isAiGenerated = false.obs;
  RxBool isUploading = false.obs;
  RxDouble uploadProgress = 0.0.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadGenresAndLanguages();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    artistController.dispose();
    releaseDateController.dispose();
    productionController.dispose();
    sourceController.dispose();
    categoryController.dispose();
    linkedPostIdController.dispose();
    super.onClose();
  }

  int get contentTypeInt {
    switch (uploadType) {
      case ContentUploadType.musicVideo:
        return 1;
      case ContentUploadType.trailer:
        return 2;
      case ContentUploadType.news:
        return 3;
    }
  }

  String get uploadTypeLabel {
    switch (uploadType) {
      case ContentUploadType.musicVideo:
        return 'Music Video';
      case ContentUploadType.trailer:
        return 'Trailer';
      case ContentUploadType.news:
        return 'News';
    }
  }

  bool get isAccountAllowed {
    final user = SessionManager.instance.getUser();
    if (user == null) return false;
    switch (uploadType) {
      case ContentUploadType.musicVideo:
      case ContentUploadType.trailer:
        return user.accountType == 3; // Production House
      case ContentUploadType.news:
        return user.accountType == 4; // News & Media
    }
  }

  Future<void> _loadGenresAndLanguages() async {
    try {
      final genreResults =
          await PostService.instance.fetchContentGenres(contentType: contentTypeInt);
      genres.value = genreResults;
    } catch (_) {}
    try {
      final langResults = await PostService.instance.fetchContentLanguages();
      languages.value = langResults;
    } catch (_) {}
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      videoFile.value = picked;
    }
  }

  Future<void> pickThumbnail() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      thumbnailFile.value = picked;
    }
  }

  Future<void> pickReleaseDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      releaseDateController.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  bool _validate() {
    if (videoFile.value == null) {
      errorMessage.value = 'Please select a video';
      return false;
    }
    if (thumbnailFile.value == null) {
      errorMessage.value = 'Please select a thumbnail';
      return false;
    }
    if (uploadType == ContentUploadType.musicVideo ||
        uploadType == ContentUploadType.trailer) {
      if (selectedGenre.value == null) {
        errorMessage.value = 'Please select a genre';
        return false;
      }
    }
    errorMessage.value = '';
    return true;
  }

  Future<void> upload() async {
    if (!_validate()) return;
    if (!isAccountAllowed) {
      errorMessage.value = 'Your account type cannot upload this content';
      return;
    }

    isUploading.value = true;
    uploadProgress.value = 0;

    try {
      // 1. Upload video file
      uploadProgress.value = 5;
      final videoResult = await CommonService.instance
          .uploadFileGivePath(videoFile.value!, onProgress: (p) {
        uploadProgress.value = 5 + (p * 0.4); // 5-45%
      });
      if (videoResult.data == null) {
        errorMessage.value = 'Video upload failed';
        isUploading.value = false;
        return;
      }

      // 2. Upload thumbnail
      uploadProgress.value = 50;
      final thumbResult = await CommonService.instance
          .uploadFileGivePath(thumbnailFile.value!, onProgress: (p) {
        uploadProgress.value = 50 + (p * 0.3); // 50-80%
      });
      if (thumbResult.data == null) {
        errorMessage.value = 'Thumbnail upload failed';
        isUploading.value = false;
        return;
      }

      // 3. Build content_metadata
      final metadata = _buildMetadata();

      // 4. Build params
      final Map<String, dynamic> param = {
        Params.video: videoResult.data,
        Params.thumbnail: thumbResult.data,
        Params.canComment: canComment.value ? 1 : 0,
        'is_ai_generated': isAiGenerated.value ? 1 : 0,
        Params.contentMetadata: jsonEncode(metadata),
      };

      if (descriptionController.text.isNotEmpty) {
        param[Params.description] = descriptionController.text;
      }
      if (linkedPostIdController.text.isNotEmpty) {
        param[Params.linkedPreviousPostId] =
            int.tryParse(linkedPostIdController.text);
      }
      if (productLinks.isNotEmpty) {
        param['product_links'] =
            jsonEncode(productLinks.map((e) => e.toJson()).toList());
      }

      // 5. Call appropriate endpoint
      uploadProgress.value = 85;
      PostModel result;
      switch (uploadType) {
        case ContentUploadType.musicVideo:
          result = await AddPostStoryService.instance
              .addPostMusicVideo(param: param);
          break;
        case ContentUploadType.trailer:
          result =
              await AddPostStoryService.instance.addPostTrailer(param: param);
          break;
        case ContentUploadType.news:
          result =
              await AddPostStoryService.instance.addPostNews(param: param);
          break;
      }

      uploadProgress.value = 100;
      isUploading.value = false;

      if (result.status == true) {
        Get.back();
        Get.snackbar('Success', '$uploadTypeLabel uploaded successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade800,
            colorText: Colors.white);
      } else {
        errorMessage.value = result.message ?? 'Upload failed';
      }
    } catch (e) {
      errorMessage.value = 'Upload error: $e';
      isUploading.value = false;
    }
  }

  Map<String, dynamic> _buildMetadata() {
    final Map<String, dynamic> meta = {};

    if (selectedGenre.value != null) {
      meta['genre'] = selectedGenre.value!.name;
    }
    if (selectedLanguage.value != null) {
      meta['language'] = selectedLanguage.value!.name;
    }

    switch (uploadType) {
      case ContentUploadType.musicVideo:
        if (artistController.text.isNotEmpty) {
          meta['artist'] = artistController.text;
        }
        if (releaseDateController.text.isNotEmpty) {
          meta['release_date'] = releaseDateController.text;
        }
        break;
      case ContentUploadType.trailer:
        if (productionController.text.isNotEmpty) {
          meta['production'] = productionController.text;
        }
        if (releaseDateController.text.isNotEmpty) {
          meta['release_date'] = releaseDateController.text;
        }
        break;
      case ContentUploadType.news:
        if (categoryController.text.isNotEmpty) {
          meta['category'] = categoryController.text;
        }
        if (sourceController.text.isNotEmpty) {
          meta['source'] = sourceController.text;
        }
        meta['is_breaking'] = isBreaking.value;
        break;
    }

    return meta;
  }

  void addProductLink() {
    if (productLinks.length >= 3) return;
    productLinks.add(ProductLink(
      buttonType: ProductButtonType.buyNow,
    ));
  }

  void removeProductLink(int index) {
    if (index < productLinks.length) {
      productLinks.removeAt(index);
    }
  }

  void updateProductLink(int index, {String? label, String? url, ProductButtonType? buttonType}) {
    if (index >= productLinks.length) return;
    final link = productLinks[index];
    if (label != null) link.label = label;
    if (url != null) link.url = url;
    if (buttonType != null) link.buttonType = buttonType;
    productLinks.refresh();
  }
}
