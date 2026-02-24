import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/ad_revenue/ad_revenue_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class AdRevenueService {
  AdRevenueService._();

  static final AdRevenueService instance = AdRevenueService._();

  Future<AdRevenueStatusModel> fetchAdRevenueStatus() async {
    AdRevenueStatusModel response = await ApiService.instance.call(
      url: WebService.adRevenue.fetchAdRevenueStatus,
      fromJson: AdRevenueStatusModel.fromJson,
    );
    return response;
  }

  Future<StatusModel> enrollInAdRevenueShare() async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.adRevenue.enrollInAdRevenueShare,
      fromJson: StatusModel.fromJson,
    );
    return response;
  }

  Future<AdRevenueSummaryModel> fetchAdRevenueSummary() async {
    AdRevenueSummaryModel response = await ApiService.instance.call(
      url: WebService.adRevenue.fetchAdRevenueSummary,
      fromJson: AdRevenueSummaryModel.fromJson,
    );
    return response;
  }

  Future<StatusModel> logAdImpression({
    int? postId,
    required int creatorId,
    required String adType,
    String? adNetwork,
    String? platform,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.adRevenue.logAdImpression,
      fromJson: StatusModel.fromJson,
      param: {
        'post_id': postId,
        'creator_id': creatorId,
        'ad_type': adType,
        'ad_network': adNetwork,
        'platform': platform,
      },
    );
    return response;
  }
}
