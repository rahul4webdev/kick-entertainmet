import 'package:shortzz/model/user_model/user_model.dart';

class PaidSeries {
  int? id;
  int? creatorId;
  String? title;
  String? description;
  String? coverImage;
  String? coverImageUrl;
  int? priceCoins;
  int? videoCount;
  int? purchaseCount;
  int? totalRevenue;
  bool? isActive;
  int? status; // 1=pending, 2=approved, 3=rejected
  bool? isPurchased;
  User? creator;
  DateTime? createdAt;

  PaidSeries({
    this.id,
    this.creatorId,
    this.title,
    this.description,
    this.coverImage,
    this.coverImageUrl,
    this.priceCoins,
    this.videoCount,
    this.purchaseCount,
    this.totalRevenue,
    this.isActive,
    this.status,
    this.isPurchased,
    this.creator,
    this.createdAt,
  });

  PaidSeries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    creatorId = json['creator_id'];
    title = json['title'];
    description = json['description'];
    coverImage = json['cover_image'];
    coverImageUrl = json['cover_image_url'];
    priceCoins = json['price_coins'];
    videoCount = json['video_count'] ?? 0;
    purchaseCount = json['purchase_count'] ?? 0;
    totalRevenue = json['total_revenue'] ?? 0;
    isActive = json['is_active'];
    status = json['status'];
    isPurchased = json['is_purchased'] ?? false;
    if (json['creator'] != null) {
      creator = User.fromJson(json['creator']);
    }
    createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'])
        : null;
  }

  bool get isApproved => status == 2;
  bool get isPending => status == 1;
  bool get isRejected => status == 3;
}

class PaidSeriesPurchase {
  int? id;
  int? seriesId;
  int? userId;
  int? amountCoins;
  DateTime? purchasedAt;
  PaidSeries? series;

  PaidSeriesPurchase({
    this.id,
    this.seriesId,
    this.userId,
    this.amountCoins,
    this.purchasedAt,
    this.series,
  });

  PaidSeriesPurchase.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    seriesId = json['series_id'];
    userId = json['user_id'];
    amountCoins = json['amount_coins'];
    purchasedAt = json['purchased_at'] != null
        ? DateTime.tryParse(json['purchased_at'])
        : null;
    if (json['series'] != null) {
      series = PaidSeries.fromJson(json['series']);
    }
  }
}
