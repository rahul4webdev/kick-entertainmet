import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/languages/languages_keys.dart';

class KeywordFiltersScreenController extends BaseController {
  RxList<Map<String, dynamic>> keywords = <Map<String, dynamic>>[].obs;
  RxBool isDataLoading = true.obs;
  final TextEditingController textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadKeywords();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> _loadKeywords() async {
    isDataLoading.value = true;
    keywords.value = await UserService.instance.fetchMyKeywordFilters();
    isDataLoading.value = false;
  }

  Future<void> addKeyword() async {
    final keyword = textController.text.trim();
    if (keyword.isEmpty) return;

    if (keywords.length >= 200) {
      showSnackBar(LKey.maxKeywordsReached.tr);
      return;
    }

    showLoader(barrierDismissible: true);
    final result =
        await UserService.instance.addKeywordFilter(keyword: keyword);
    stopLoader();

    if (result.status == true) {
      textController.clear();
      await _loadKeywords();
    }
    showSnackBar(result.message);
  }

  Future<void> removeKeyword(int keywordId) async {
    showLoader(barrierDismissible: true);
    final result =
        await UserService.instance.removeKeywordFilter(keywordId: keywordId);
    stopLoader();

    if (result.status == true) {
      keywords.removeWhere((k) => k['id'] == keywordId);
    }
    showSnackBar(result.message);
  }
}
