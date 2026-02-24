import 'package:shortzz/model/user_model/user_model.dart';

class CoinTransactionListModel {
  bool? status;
  String? message;
  List<CoinTransaction>? data;

  CoinTransactionListModel({this.status, this.message, this.data});

  CoinTransactionListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(CoinTransaction.fromJson(v));
      });
    }
  }
}

class CoinTransaction {
  int? id;
  int? userId;
  int? type;
  int? coins;
  int? direction;
  int? relatedUserId;
  int? referenceId;
  String? note;
  String? createdAt;
  String? updatedAt;
  User? relatedUser;

  CoinTransaction({
    this.id,
    this.userId,
    this.type,
    this.coins,
    this.direction,
    this.relatedUserId,
    this.referenceId,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.relatedUser,
  });

  CoinTransaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    type = json['type'];
    coins = json['coins'];
    direction = json['direction'];
    relatedUserId = json['related_user_id'];
    referenceId = json['reference_id'];
    note = json['note'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    relatedUser = json['related_user'] != null
        ? User.fromJson(json['related_user'])
        : null;
  }

  String get typeLabel {
    switch (type) {
      case 1:
        return 'Gift Received';
      case 2:
        return 'Gift Sent';
      case 3:
        return 'Purchase';
      case 4:
        return 'Withdrawal';
      case 5:
        return 'Ad Reward';
      case 6:
        return 'Admin Credit';
      case 7:
        return 'Registration Bonus';
      case 8:
        return 'Tip Received';
      case 9:
        return 'Tip Sent';
      case 10:
        return 'Subscription Received';
      case 11:
        return 'Subscription Sent';
      case 12:
        return 'Series Purchase';
      case 13:
        return 'Series Revenue';
      case 14:
        return 'Ad Revenue';
      case 15:
        return 'Product Purchase';
      case 16:
        return 'Product Revenue';
      case 17:
        return 'Marketplace Payout';
      case 18:
        return 'Marketplace Earning';
      case 19:
        return 'Affiliate Earning';
      default:
        return 'Transaction';
    }
  }

  bool get isCredit => direction == 1;
}
