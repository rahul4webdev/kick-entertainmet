import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/creator/creator_dashboard_model.dart';

class CreatorDashboardService {
  CreatorDashboardService._();

  static final CreatorDashboardService instance = CreatorDashboardService._();

  Future<CreatorDashboardData?> fetchCreatorDashboard({
    String period = '30d',
  }) async {
    CreatorDashboardModel response = await ApiService.instance.call(
      url: WebService.creator.fetchCreatorDashboard,
      param: {'period': period},
      fromJson: CreatorDashboardModel.fromJson,
    );
    if (response.status == true) {
      return response.data;
    }
    return null;
  }

  Future<PostAnalyticsData?> fetchPostAnalytics({
    required int postId,
  }) async {
    PostAnalyticsModel response = await ApiService.instance.call(
      url: WebService.creator.fetchPostAnalytics,
      param: {Params.postId: postId},
      fromJson: PostAnalyticsModel.fromJson,
    );
    if (response.status == true) {
      return response.data;
    }
    return null;
  }

  Future<AudienceInsightsData?> fetchAudienceInsights() async {
    AudienceInsightsModel response = await ApiService.instance.call(
      url: WebService.creator.fetchAudienceInsights,
      fromJson: AudienceInsightsModel.fromJson,
    );
    if (response.status == true) {
      return response.data;
    }
    return null;
  }

  Future<SearchInsightsData?> fetchSearchInsights({
    String period = '7d',
  }) async {
    SearchInsightsModel response = await ApiService.instance.call(
      url: WebService.creator.fetchSearchInsights,
      param: {'period': period},
      fromJson: SearchInsightsModel.fromJson,
    );
    if (response.status == true) {
      return response.data;
    }
    return null;
  }
}
