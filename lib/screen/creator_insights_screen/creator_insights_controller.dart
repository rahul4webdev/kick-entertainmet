import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/creator_insights_service.dart';
import 'package:shortzz/model/creator/creator_insight_model.dart';

class CreatorInsightsController extends BaseController {
  RxList<CreatorInsight> insights = <CreatorInsight>[].obs;
  RxInt unreadCount = 0.obs;
  RxBool isGenerating = false.obs;
  RxBool hasMore = true.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchInsights(reset: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading.value &&
        hasMore.value) {
      fetchInsights();
    }
  }

  Future<void> fetchInsights({bool reset = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    final lastId = reset ? null : insights.lastOrNull?.id;
    if (reset) {
      insights.clear();
      hasMore.value = true;
    }

    final result = await CreatorInsightsService.instance.fetchInsights(
      lastItemId: lastId,
      limit: 20,
    );

    if (result.data != null) {
      insights.addAll(result.data!);
      if (result.data!.length < 20) hasMore.value = false;
    } else {
      hasMore.value = false;
    }
    unreadCount.value = result.unreadCount;
    isLoading.value = false;
  }

  Future<void> generateInsights() async {
    isGenerating.value = true;
    final result = await CreatorInsightsService.instance.generateInsights();
    isGenerating.value = false;

    if (result.data != null && result.data!.isNotEmpty) {
      // Prepend new insights to the top
      insights.insertAll(0, result.data!);
      unreadCount.value = result.unreadCount;
    }
  }

  Future<void> markRead(CreatorInsight insight) async {
    if (insight.isRead) return;
    await CreatorInsightsService.instance.markInsightRead(
      insightId: insight.id,
    );
    insight.isRead = true;
    insights.refresh();
    if (unreadCount.value > 0) unreadCount.value--;
  }

  Future<void> markAllRead() async {
    await CreatorInsightsService.instance.markInsightRead();
    for (final insight in insights) {
      insight.isRead = true;
    }
    insights.refresh();
    unreadCount.value = 0;
  }
}
