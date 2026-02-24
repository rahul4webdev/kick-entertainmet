import 'package:shortzz/model/user_model/user_model.dart';

class RewardedAdClaimModel {
  bool? status;
  String? message;
  RewardedAdClaimData? data;

  RewardedAdClaimModel({this.status, this.message, this.data});

  RewardedAdClaimModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? RewardedAdClaimData.fromJson(json['data'])
        : null;
  }
}

class RewardedAdClaimData {
  int? remainingAdsToday;
  User? user;

  RewardedAdClaimData({this.remainingAdsToday, this.user});

  RewardedAdClaimData.fromJson(Map<String, dynamic> json) {
    remainingAdsToday = json['remaining_ads_today'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
}
