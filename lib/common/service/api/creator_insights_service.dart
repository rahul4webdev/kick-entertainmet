import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/creator/creator_insight_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class CreatorInsightsService {
  CreatorInsightsService._();
  static final CreatorInsightsService instance = CreatorInsightsService._();

  Future<CreatorInsightListModel> generateInsights() async {
    return await ApiService.instance.call(
      url: WebService.creatorInsights.generateInsights,
      fromJson: CreatorInsightListModel.fromJson,
      param: {},
    );
  }

  Future<CreatorInsightListModel> fetchInsights({
    int? lastItemId,
    int limit = 20,
  }) async {
    return await ApiService.instance.call(
      url: WebService.creatorInsights.fetchInsights,
      fromJson: CreatorInsightListModel.fromJson,
      param: {
        'limit': limit,
        if (lastItemId != null) 'last_item_id': lastItemId,
      },
    );
  }

  Future<StatusModel> markInsightRead({int? insightId}) async {
    return await ApiService.instance.call(
      url: WebService.creatorInsights.markInsightRead,
      fromJson: StatusModel.fromJson,
      param: {
        if (insightId != null) 'insight_id': insightId,
      },
    );
  }

  Future<StatusModel> fetchTrendingTopics() async {
    return await ApiService.instance.call(
      url: WebService.creatorInsights.fetchTrendingTopics,
      fromJson: StatusModel.fromJson,
      param: {},
    );
  }
}
