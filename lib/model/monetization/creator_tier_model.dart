class CreatorTiersModel {
  bool? status;
  String? message;
  List<CreatorTier>? data;

  CreatorTiersModel({this.status, this.message, this.data});

  CreatorTiersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data =
          (json['data'] as List).map((e) => CreatorTier.fromJson(e)).toList();
    }
  }
}

class CreatorTier {
  int? id;
  String? name;
  int? level;
  int? minFollowers;
  int? minTotalViews;
  int? minTotalLikes;
  double? commissionRate;
  String? badgeColor;

  CreatorTier({
    this.id,
    this.name,
    this.level,
    this.minFollowers,
    this.minTotalViews,
    this.minTotalLikes,
    this.commissionRate,
    this.badgeColor,
  });

  CreatorTier.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    level = json['level'];
    minFollowers = json['min_followers'];
    minTotalViews = json['min_total_views'];
    minTotalLikes = json['min_total_likes'];
    commissionRate = double.tryParse('${json['commission_rate'] ?? ''}');
    badgeColor = json['badge_color'];
  }
}
