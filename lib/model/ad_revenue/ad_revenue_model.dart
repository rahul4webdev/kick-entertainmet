class AdRevenueStatusModel {
  bool? status;
  String? message;
  AdRevenueStatusData? data;

  AdRevenueStatusModel({this.status, this.message, this.data});

  AdRevenueStatusModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? AdRevenueStatusData.fromJson(json['data'])
        : null;
  }
}

class AdRevenueStatusData {
  bool? isEnrolled;
  AdRevenueEnrollment? enrollment;
  double? ecpmRate;
  int? revenueSharePercent;
  int? minFollowersRequired;
  bool? isMonetized;

  AdRevenueStatusData({
    this.isEnrolled,
    this.enrollment,
    this.ecpmRate,
    this.revenueSharePercent,
    this.minFollowersRequired,
    this.isMonetized,
  });

  AdRevenueStatusData.fromJson(Map<String, dynamic> json) {
    isEnrolled = json['is_enrolled'] == true;
    enrollment = json['enrollment'] != null
        ? AdRevenueEnrollment.fromJson(json['enrollment'])
        : null;
    ecpmRate = (json['ecpm_rate'] as num?)?.toDouble();
    revenueSharePercent = json['revenue_share_percent'];
    minFollowersRequired = json['min_followers_required'];
    isMonetized = json['is_monetized'] == true;
  }
}

class AdRevenueEnrollment {
  int? id;
  int? userId;
  int? status; // 0=pending, 1=approved, 2=rejected
  int? minFollowersAtEnrollment;
  int? minViewsAtEnrollment;
  String? approvedAt;
  String? rejectionReason;
  String? createdAt;

  AdRevenueEnrollment({
    this.id,
    this.userId,
    this.status,
    this.minFollowersAtEnrollment,
    this.minViewsAtEnrollment,
    this.approvedAt,
    this.rejectionReason,
    this.createdAt,
  });

  AdRevenueEnrollment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    status = json['status'];
    minFollowersAtEnrollment = json['min_followers_at_enrollment'];
    minViewsAtEnrollment = json['min_views_at_enrollment'];
    approvedAt = json['approved_at'];
    rejectionReason = json['rejection_reason'];
    createdAt = json['created_at'];
  }

  bool get isPending => status == 0;
  bool get isApproved => status == 1;
  bool get isRejected => status == 2;
}

class AdRevenueSummaryModel {
  bool? status;
  String? message;
  AdRevenueSummary? data;

  AdRevenueSummaryModel({this.status, this.message, this.data});

  AdRevenueSummaryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? AdRevenueSummary.fromJson(json['data'])
        : null;
  }
}

class AdRevenueSummary {
  int? revenueSharePercent;
  double? ecpmRate;
  RevenueStats? total;
  RevenueStats? today;
  RevenueStats? thisMonth;
  List<AdTypeBreakdown>? byAdType;
  List<DailyBreakdown>? dailyBreakdown;
  List<TopEarningPost>? topEarningPosts;
  List<AdRevenuePayout>? payouts;
  int? totalCoinsEarned;

  AdRevenueSummary({
    this.revenueSharePercent,
    this.ecpmRate,
    this.total,
    this.today,
    this.thisMonth,
    this.byAdType,
    this.dailyBreakdown,
    this.topEarningPosts,
    this.payouts,
    this.totalCoinsEarned,
  });

  AdRevenueSummary.fromJson(Map<String, dynamic> json) {
    revenueSharePercent = json['revenue_share_percent'];
    ecpmRate = (json['ecpm_rate'] as num?)?.toDouble();
    total = json['total'] != null ? RevenueStats.fromJson(json['total']) : null;
    today = json['today'] != null ? RevenueStats.fromJson(json['today']) : null;
    thisMonth = json['this_month'] != null
        ? RevenueStats.fromJson(json['this_month'])
        : null;
    if (json['by_ad_type'] != null) {
      byAdType = [];
      json['by_ad_type'].forEach((v) {
        byAdType!.add(AdTypeBreakdown.fromJson(v));
      });
    }
    if (json['daily_breakdown'] != null) {
      dailyBreakdown = [];
      json['daily_breakdown'].forEach((v) {
        dailyBreakdown!.add(DailyBreakdown.fromJson(v));
      });
    }
    if (json['top_earning_posts'] != null) {
      topEarningPosts = [];
      json['top_earning_posts'].forEach((v) {
        topEarningPosts!.add(TopEarningPost.fromJson(v));
      });
    }
    if (json['payouts'] != null) {
      payouts = [];
      json['payouts'].forEach((v) {
        payouts!.add(AdRevenuePayout.fromJson(v));
      });
    }
    totalCoinsEarned = json['total_coins_earned'];
  }
}

class RevenueStats {
  int? impressions;
  double? revenue;
  double? creatorShare;

  RevenueStats({this.impressions, this.revenue, this.creatorShare});

  RevenueStats.fromJson(Map<String, dynamic> json) {
    impressions = json['impressions'];
    revenue = (json['revenue'] as num?)?.toDouble();
    creatorShare = (json['creator_share'] as num?)?.toDouble();
  }
}

class AdTypeBreakdown {
  String? adType;
  int? impressions;
  double? totalRevenue;
  double? creatorShare;

  AdTypeBreakdown(
      {this.adType, this.impressions, this.totalRevenue, this.creatorShare});

  AdTypeBreakdown.fromJson(Map<String, dynamic> json) {
    adType = json['ad_type'];
    impressions = json['impressions'];
    totalRevenue = (json['total_revenue'] as num?)?.toDouble();
    creatorShare = (json['creator_share'] as num?)?.toDouble();
  }
}

class DailyBreakdown {
  String? date;
  int? impressions;
  double? totalRevenue;
  double? creatorShare;

  DailyBreakdown(
      {this.date, this.impressions, this.totalRevenue, this.creatorShare});

  DailyBreakdown.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    impressions = json['impressions'];
    totalRevenue = (json['total_revenue'] as num?)?.toDouble();
    creatorShare = (json['creator_share'] as num?)?.toDouble();
  }
}

class TopEarningPost {
  int? postId;
  String? thumbnail;
  String? description;
  int? views;
  int? likes;
  int? impressions;
  double? totalRevenue;
  double? creatorShare;

  TopEarningPost({
    this.postId,
    this.thumbnail,
    this.description,
    this.views,
    this.likes,
    this.impressions,
    this.totalRevenue,
    this.creatorShare,
  });

  TopEarningPost.fromJson(Map<String, dynamic> json) {
    postId = json['post_id'];
    thumbnail = json['thumbnail'];
    description = json['description'];
    views = json['views'];
    likes = json['likes'];
    impressions = json['impressions'];
    totalRevenue = (json['total_revenue'] as num?)?.toDouble();
    creatorShare = (json['creator_share'] as num?)?.toDouble();
  }
}

class AdRevenuePayout {
  int? id;
  int? userId;
  String? periodStart;
  String? periodEnd;
  int? totalImpressions;
  double? totalEstimatedRevenue;
  double? creatorShare;
  double? platformShare;
  int? coinsCredit;
  int? status; // 0=pending, 1=processed, 2=paid
  String? processedAt;

  AdRevenuePayout({
    this.id,
    this.userId,
    this.periodStart,
    this.periodEnd,
    this.totalImpressions,
    this.totalEstimatedRevenue,
    this.creatorShare,
    this.platformShare,
    this.coinsCredit,
    this.status,
    this.processedAt,
  });

  AdRevenuePayout.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    periodStart = json['period_start'];
    periodEnd = json['period_end'];
    totalImpressions = json['total_impressions'];
    totalEstimatedRevenue =
        (json['total_estimated_revenue'] as num?)?.toDouble();
    creatorShare = (json['creator_share'] as num?)?.toDouble();
    platformShare = (json['platform_share'] as num?)?.toDouble();
    coinsCredit = json['coins_credited'];
    status = json['status'];
    processedAt = json['processed_at'];
  }

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Processed';
      case 2:
        return 'Paid';
      default:
        return 'Unknown';
    }
  }
}
