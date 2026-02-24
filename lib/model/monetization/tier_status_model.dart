import 'package:shortzz/model/monetization/creator_tier_model.dart';

class TierStatusModel {
  bool? status;
  String? message;
  TierStatusData? data;

  TierStatusModel({this.status, this.message, this.data});

  TierStatusModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = TierStatusData.fromJson(json['data']);
    }
  }
}

class TierStatusData {
  CreatorTier? currentTier;
  CreatorTier? nextTier;
  TierProgress? progress;
  double? commissionRate;
  TierStats? stats;

  TierStatusData({
    this.currentTier,
    this.nextTier,
    this.progress,
    this.commissionRate,
    this.stats,
  });

  TierStatusData.fromJson(Map<String, dynamic> json) {
    if (json['current_tier'] != null) {
      currentTier = CreatorTier.fromJson(json['current_tier']);
    }
    if (json['next_tier'] != null) {
      nextTier = CreatorTier.fromJson(json['next_tier']);
    }
    if (json['progress'] != null) {
      progress = TierProgress.fromJson(json['progress']);
    }
    commissionRate = double.tryParse('${json['commission_rate'] ?? ''}');
    if (json['stats'] != null) {
      stats = TierStats.fromJson(json['stats']);
    }
  }
}

class TierProgress {
  ProgressMetric? followers;
  ProgressMetric? views;
  ProgressMetric? likes;

  TierProgress({this.followers, this.views, this.likes});

  TierProgress.fromJson(Map<String, dynamic> json) {
    if (json['followers'] != null) {
      followers = ProgressMetric.fromJson(json['followers']);
    }
    if (json['views'] != null) {
      views = ProgressMetric.fromJson(json['views']);
    }
    if (json['likes'] != null) {
      likes = ProgressMetric.fromJson(json['likes']);
    }
  }
}

class ProgressMetric {
  int? current;
  int? required_;
  double? percentage;

  ProgressMetric({this.current, this.required_, this.percentage});

  ProgressMetric.fromJson(Map<String, dynamic> json) {
    current = json['current'];
    required_ = json['required'];
    percentage = double.tryParse('${json['percentage'] ?? ''}');
  }
}

class TierStats {
  int? totalFollowers;
  int? totalViews;
  int? totalLikes;
  int? totalTipsReceived;
  int? tipsThisMonth;

  TierStats({
    this.totalFollowers,
    this.totalViews,
    this.totalLikes,
    this.totalTipsReceived,
    this.tipsThisMonth,
  });

  TierStats.fromJson(Map<String, dynamic> json) {
    totalFollowers = json['total_followers'];
    totalViews = json['total_views'];
    totalLikes = json['total_likes'];
    totalTipsReceived = json['total_tips_received'];
    tipsThisMonth = json['tips_this_month'];
  }
}
