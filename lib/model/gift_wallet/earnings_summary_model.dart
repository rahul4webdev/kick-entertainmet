class EarningsSummaryModel {
  bool? status;
  String? message;
  EarningsSummary? data;

  EarningsSummaryModel({this.status, this.message, this.data});

  EarningsSummaryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? EarningsSummary.fromJson(json['data']) : null;
  }
}

class EarningsSummary {
  int? totalEarnings;
  int? todayEarnings;
  int? thisMonthEarnings;
  List<TopSupporter>? topSupporters;
  Map<String, dynamic>? earningsBySource;

  EarningsSummary({
    this.totalEarnings,
    this.todayEarnings,
    this.thisMonthEarnings,
    this.topSupporters,
    this.earningsBySource,
  });

  EarningsSummary.fromJson(Map<String, dynamic> json) {
    totalEarnings = json['total_earnings'];
    todayEarnings = json['today_earnings'];
    thisMonthEarnings = json['this_month_earnings'];
    if (json['top_supporters'] != null) {
      topSupporters = [];
      json['top_supporters'].forEach((v) {
        topSupporters?.add(TopSupporter.fromJson(v));
      });
    }
    earningsBySource = json['earnings_by_source'] != null
        ? Map<String, dynamic>.from(json['earnings_by_source'])
        : {};
  }
}

class TopSupporter {
  int? userId;
  String? username;
  String? fullname;
  String? profilePhoto;
  int? isVerify;
  int? totalCoins;

  TopSupporter({
    this.userId,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.isVerify,
    this.totalCoins,
  });

  TopSupporter.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    fullname = json['fullname'];
    profilePhoto = json['profile_photo'];
    isVerify = json['is_verify'];
    totalCoins = json['total_coins'];
  }
}
