import 'package:shortzz/model/subscription/subscription_tier_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';

class CreatorSubscription {
  int? id;
  int? subscriberId;
  int? creatorId;
  int? tierId;
  int? priceCoins;
  int? status; // 1=active, 2=cancelled, 3=expired
  bool? autoRenew;
  String? startedAt;
  String? expiresAt;
  String? cancelledAt;
  User? subscriber;
  User? creator;
  SubscriptionTier? tier;

  CreatorSubscription({
    this.id,
    this.subscriberId,
    this.creatorId,
    this.tierId,
    this.priceCoins,
    this.status,
    this.autoRenew,
    this.startedAt,
    this.expiresAt,
    this.cancelledAt,
    this.subscriber,
    this.creator,
    this.tier,
  });

  CreatorSubscription.fromJson(dynamic json) {
    id = json['id'];
    subscriberId = json['subscriber_id'];
    creatorId = json['creator_id'];
    tierId = json['tier_id'];
    priceCoins = json['price_coins'];
    status = json['status'];
    autoRenew = json['auto_renew'];
    startedAt = json['started_at'];
    expiresAt = json['expires_at'];
    cancelledAt = json['cancelled_at'];
    subscriber = json['subscriber'] != null
        ? User.fromJson(json['subscriber'])
        : null;
    creator =
        json['creator'] != null ? User.fromJson(json['creator']) : null;
    tier = json['tier'] != null
        ? SubscriptionTier.fromJson(json['tier'])
        : null;
  }

  bool get isActive => status == 1;
  bool get isCancelled => status == 2;
  bool get isExpired => status == 3;
}
