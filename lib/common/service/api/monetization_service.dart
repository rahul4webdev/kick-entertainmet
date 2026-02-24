import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/gift_wallet/coin_transaction_model.dart';
import 'package:shortzz/model/gift_wallet/earnings_summary_model.dart';
import 'package:shortzz/model/gift_wallet/monetization_status_model.dart';
import 'package:shortzz/model/gift_wallet/rewarded_ad_claim_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/utilities/app_res.dart';

class MonetizationService {
  MonetizationService._();

  static final MonetizationService instance = MonetizationService._();

  Future<MonetizationStatusModel> fetchMonetizationStatus() async {
    MonetizationStatusModel response = await ApiService.instance.call(
      url: WebService.monetization.fetchMonetizationStatus,
      fromJson: MonetizationStatusModel.fromJson,
    );
    return response;
  }

  Future<UserModel> applyForMonetization() async {
    UserModel response = await ApiService.instance.call(
      url: WebService.monetization.applyForMonetization,
      fromJson: UserModel.fromJson,
    );
    return response;
  }

  Future<StatusModel> submitKycDocument({
    required XFile document,
    required String documentType,
  }) async {
    StatusModel response = await ApiService.instance.multiPartCallApi(
      url: WebService.monetization.submitKycDocument,
      param: {Params.documentType: documentType},
      filesMap: {
        Params.document: [document]
      },
      fromJson: StatusModel.fromJson,
    );
    return response;
  }

  Future<EarningsSummaryModel> fetchEarningsSummary() async {
    EarningsSummaryModel response = await ApiService.instance.call(
      url: WebService.monetization.fetchEarningsSummary,
      fromJson: EarningsSummaryModel.fromJson,
    );
    return response;
  }

  Future<List<CoinTransaction>> fetchTransactionHistory({
    int? lastItemId,
    int? type,
  }) async {
    CoinTransactionListModel response = await ApiService.instance.call(
      url: WebService.monetization.fetchTransactionHistory,
      fromJson: CoinTransactionListModel.fromJson,
      param: {
        Params.limit: AppRes.paginationLimit,
        Params.lastItemId: lastItemId,
        Params.type: type,
      },
    );
    return response.data ?? [];
  }

  Future<RewardedAdClaimModel> claimRewardedAd() async {
    RewardedAdClaimModel response = await ApiService.instance.call(
      url: WebService.monetization.claimRewardedAd,
      fromJson: RewardedAdClaimModel.fromJson,
    );
    return response;
  }
}
