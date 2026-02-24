import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/gift_wallet/withdraw_model.dart';
import 'package:shortzz/model/monetization/tip_amount_model.dart';
import 'package:shortzz/model/monetization/creator_tier_model.dart';
import 'package:shortzz/model/monetization/tier_status_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/utilities/app_res.dart';

class GiftWalletService {
  GiftWalletService._();

  static final GiftWalletService instance = GiftWalletService._();

  Future<StatusModel> sendGift({int? userId, int? giftId}) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.giftWallet.sendGift,
        fromJson: StatusModel.fromJson,
        param: {Params.userId: userId, Params.giftId: giftId});
    return response;
  }

  Future<List<Withdraw>> fetchMyWithdrawalRequest({int? lastItemId}) async {
    WithdrawModel response = await ApiService.instance.call(
        url: WebService.giftWallet.fetchMyWithdrawalRequest,
        fromJson: WithdrawModel.fromJson,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId,
        });

    return response.data ?? [];
  }

  Future<StatusModel> submitWithdrawalRequest(
      {required String coins,
      required String gateway,
      required String account}) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.giftWallet.submitWithdrawalRequest,
        fromJson: StatusModel.fromJson,
        param: {
          Params.coins: coins,
          Params.gateway: gateway,
          Params.account: account
        });

    return response;
  }

  Future<User?> buyCoins({required int id, String? purchasedAt}) async {
    UserModel response = await ApiService.instance.call(
        url: WebService.giftWallet.buyCoins,
        fromJson: UserModel.fromJson,
        param: {
          Params.coinPackageId: id,
          Params.purchasedAt: purchasedAt,
        });
    if (response.status == true) {
      return response.data;
    }
    return null;
  }

  Future<StatusModel> sendTip({
    required int userId,
    required int coins,
    int? postId,
  }) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.giftWallet.sendTip,
        fromJson: StatusModel.fromJson,
        param: {
          Params.userId: userId,
          Params.coins: coins,
          if (postId != null) Params.postId: postId,
        });
    return response;
  }

  Future<List<TipAmount>> fetchTipAmounts() async {
    TipAmountsModel response = await ApiService.instance.call(
        url: WebService.giftWallet.fetchTipAmounts,
        fromJson: TipAmountsModel.fromJson,
        param: {});
    return response.data ?? [];
  }

  Future<List<CreatorTier>> fetchCreatorTiers() async {
    CreatorTiersModel response = await ApiService.instance.call(
        url: WebService.giftWallet.fetchCreatorTiers,
        fromJson: CreatorTiersModel.fromJson,
        param: {});
    return response.data ?? [];
  }

  Future<TierStatusData?> fetchMyTierStatus() async {
    TierStatusModel response = await ApiService.instance.call(
        url: WebService.giftWallet.fetchMyTierStatus,
        fromJson: TierStatusModel.fromJson,
        param: {});
    if (response.status == true) {
      return response.data;
    }
    return null;
  }
}
