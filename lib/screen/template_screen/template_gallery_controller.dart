import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/template_service.dart';
import 'package:shortzz/model/template/template_model.dart';

class TemplateGalleryController extends BaseController {
  RxList<VideoTemplate> templates = <VideoTemplate>[].obs;
  RxList<String> categories = <String>[].obs;
  Rx<String?> selectedCategory = Rx(null);
  ScrollController scrollController = ScrollController();

  /// 0 = All, 1 = Trending, 2 = Creator Templates
  final sourceTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTemplates(reset: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && templates.isNotEmpty) {
        fetchTemplates();
      }
    }
  }

  Future<void> fetchTemplates({bool reset = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    final lastId = reset ? null : templates.lastOrNull?.id;
    if (reset) templates.clear();

    if (sourceTab.value == 1) {
      // Trending
      final result = await TemplateService.instance.fetchTrendingTemplates(
        lastItemId: lastId,
      );
      if (result.status == true && result.data != null) {
        templates.addAll(result.data!);
        if (reset && result.categories != null) {
          categories.value = result.categories!;
        }
      }
    } else {
      final source = sourceTab.value == 2 ? 'user' : null;
      final result = await TemplateService.instance.fetchTemplates(
        category: selectedCategory.value,
        source: source,
        lastItemId: lastId,
      );
      if (result.status == true && result.data != null) {
        templates.addAll(result.data!);
        if (reset && result.categories != null) {
          categories.value = result.categories!;
        }
      }
    }

    isLoading.value = false;
  }

  void onCategorySelected(String? category) {
    selectedCategory.value = category;
    fetchTemplates(reset: true);
  }

  void onSourceTabChanged(int tab) {
    sourceTab.value = tab;
    selectedCategory.value = null;
    fetchTemplates(reset: true);
  }

  Future<void> onLikeTemplate(VideoTemplate template) async {
    final result =
        await TemplateService.instance.likeTemplate(templateId: template.id!);
    if (result.status == true) {
      final index = templates.indexWhere((t) => t.id == template.id);
      if (index != -1) {
        final t = templates[index];
        t.isLiked = !t.isLiked;
        t.likeCount += t.isLiked ? 1 : -1;
        templates[index] = t;
      }
    }
  }
}
