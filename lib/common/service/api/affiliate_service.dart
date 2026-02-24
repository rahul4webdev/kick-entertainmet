import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/affiliate/affiliate_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class AffiliateService {
  AffiliateService._();

  static final AffiliateService instance = AffiliateService._();

  Future<AffiliateProductListModel> fetchAffiliateProducts({
    int? categoryId,
    String? search,
    int? lastItemId,
  }) async {
    AffiliateProductListModel response = await ApiService.instance.call(
      url: WebService.affiliate.fetchProducts,
      fromJson: AffiliateProductListModel.fromJson,
      param: {
        'category_id': categoryId,
        'search': search,
        'last_item_id': lastItemId,
      },
    );
    return response;
  }

  Future<AffiliateLinkModel> createAffiliateLink({
    required int productId,
  }) async {
    AffiliateLinkModel response = await ApiService.instance.call(
      url: WebService.affiliate.createLink,
      fromJson: AffiliateLinkModel.fromJson,
      param: {'product_id': productId},
    );
    return response;
  }

  Future<StatusModel> removeAffiliateLink({
    required int linkId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.affiliate.removeLink,
      fromJson: StatusModel.fromJson,
      param: {'link_id': linkId},
    );
    return response;
  }

  Future<AffiliateLinkListModel> fetchMyAffiliateLinks() async {
    AffiliateLinkListModel response = await ApiService.instance.call(
      url: WebService.affiliate.fetchMyLinks,
      fromJson: AffiliateLinkListModel.fromJson,
    );
    return response;
  }

  Future<AffiliateEarningListModel> fetchAffiliateEarnings({
    int? lastItemId,
  }) async {
    AffiliateEarningListModel response = await ApiService.instance.call(
      url: WebService.affiliate.fetchEarnings,
      fromJson: AffiliateEarningListModel.fromJson,
      param: {'last_item_id': lastItemId},
    );
    return response;
  }

  Future<AffiliateDashboardModel> fetchAffiliateDashboard() async {
    AffiliateDashboardModel response = await ApiService.instance.call(
      url: WebService.affiliate.fetchDashboard,
      fromJson: AffiliateDashboardModel.fromJson,
    );
    return response;
  }

  Future<StatusModel> trackClick({
    required String affiliateCode,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.affiliate.trackClick,
      fromJson: StatusModel.fromJson,
      param: {'affiliate_code': affiliateCode},
    );
    return response;
  }
}
