import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/subscription/creator_subscription_model.dart';
class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService instance = SubscriptionService._();

  /// Creator: Enable subscriptions on profile
  Future<StatusModel> enableSubscriptions() async {
    return await ApiService.instance.call(
      url: WebService.subscription.enableSubscriptions,
      param: {},
      fromJson: StatusModel.fromJson,
    );
  }

  /// Creator: Disable subscriptions
  Future<StatusModel> disableSubscriptions() async {
    return await ApiService.instance.call(
      url: WebService.subscription.disableSubscriptions,
      param: {},
      fromJson: StatusModel.fromJson,
    );
  }

  /// Creator: Create a subscription tier
  Future<Map<String, dynamic>> createTier({
    required String name,
    required int priceCoins,
    String? description,
    List<String>? benefits,
  }) async {
    return await ApiService.instance.call(
      url: WebService.subscription.createTier,
      param: {
        'name': name,
        'price_coins': priceCoins,
        if (description != null) 'description': description,
        if (benefits != null) 'benefits': benefits,
      },
      fromJson: (json) => json,
    );
  }

  /// Creator: Update a subscription tier
  Future<Map<String, dynamic>> updateTier({
    required int tierId,
    String? name,
    int? priceCoins,
    String? description,
    List<String>? benefits,
  }) async {
    return await ApiService.instance.call(
      url: WebService.subscription.updateTier,
      param: {
        'tier_id': tierId,
        if (name != null) 'name': name,
        if (priceCoins != null) 'price_coins': priceCoins,
        if (description != null) 'description': description,
        if (benefits != null) 'benefits': benefits,
      },
      fromJson: (json) => json,
    );
  }

  /// Creator: Delete a subscription tier
  Future<StatusModel> deleteTier({required int tierId}) async {
    return await ApiService.instance.call(
      url: WebService.subscription.deleteTier,
      param: {'tier_id': tierId},
      fromJson: StatusModel.fromJson,
    );
  }

  /// Fetch tiers for a creator (+ current subscription status)
  Future<Map<String, dynamic>> fetchTiers({required int creatorId}) async {
    return await ApiService.instance.call(
      url: WebService.subscription.fetchTiers,
      param: {'creator_id': creatorId},
      fromJson: (json) => json,
    );
  }

  /// Subscribe to a creator's tier
  Future<Map<String, dynamic>> subscribe({required int tierId}) async {
    return await ApiService.instance.call(
      url: WebService.subscription.subscribe,
      param: {'tier_id': tierId},
      fromJson: (json) => json,
    );
  }

  /// Cancel subscription to a creator
  Future<StatusModel> cancelSubscription({required int creatorId}) async {
    return await ApiService.instance.call(
      url: WebService.subscription.cancelSubscription,
      param: {'creator_id': creatorId},
      fromJson: StatusModel.fromJson,
    );
  }

  /// Fetch my active subscriptions (what I'm subscribed to)
  Future<List<CreatorSubscription>> fetchMySubscriptions() async {
    final response = await ApiService.instance.call(
      url: WebService.subscription.fetchMySubscriptions,
      param: {},
      fromJson: (json) => json,
    );
    final data = response['data'] as List? ?? [];
    return data.map((e) => CreatorSubscription.fromJson(e)).toList();
  }

  /// Creator: Fetch my subscribers
  Future<List<CreatorSubscription>> fetchMySubscribers({
    int? lastItemId,
    int limit = 20,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.subscription.fetchMySubscribers,
      param: {
        'limit': limit,
        if (lastItemId != null) 'lastItemId': lastItemId,
      },
      fromJson: (json) => json,
    );
    final data = response['data'] as List? ?? [];
    return data.map((e) => CreatorSubscription.fromJson(e)).toList();
  }

  /// Check if I'm subscribed to a creator
  Future<Map<String, dynamic>> checkSubscription({
    required int creatorId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.subscription.checkSubscription,
      param: {'creator_id': creatorId},
      fromJson: (json) => json,
    );
  }
}
