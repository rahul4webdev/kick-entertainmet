import 'package:shortzz/model/product/product_model.dart';

class AffiliateLinkListModel {
  bool? status;
  String? message;
  List<AffiliateLink>? data;

  AffiliateLinkListModel({this.status, this.message, this.data});

  factory AffiliateLinkListModel.fromJson(dynamic json) {
    return AffiliateLinkListModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => AffiliateLink.fromJson(v)).toList()
          : null,
    );
  }
}

class AffiliateLinkModel {
  bool? status;
  String? message;
  AffiliateLink? data;

  AffiliateLinkModel({this.status, this.message, this.data});

  factory AffiliateLinkModel.fromJson(dynamic json) {
    return AffiliateLinkModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? AffiliateLink.fromJson(json['data']) : null,
    );
  }
}

class AffiliateLink {
  int? id;
  int? creatorId;
  int? productId;
  String? affiliateCode;
  double commissionRate;
  int clickCount;
  int purchaseCount;
  int totalEarnings;
  int status;
  Product? product;
  bool hasAffiliateLink;
  String? createdAt;

  AffiliateLink({
    this.id,
    this.creatorId,
    this.productId,
    this.affiliateCode,
    this.commissionRate = 10.0,
    this.clickCount = 0,
    this.purchaseCount = 0,
    this.totalEarnings = 0,
    this.status = 1,
    this.product,
    this.hasAffiliateLink = false,
    this.createdAt,
  });

  bool get isActive => status == 1;

  factory AffiliateLink.fromJson(dynamic json) {
    return AffiliateLink(
      id: json['id'],
      creatorId: json['creator_id'],
      productId: json['product_id'],
      affiliateCode: json['affiliate_code'],
      commissionRate: (json['commission_rate'] ?? 10.0).toDouble(),
      clickCount: json['click_count'] ?? 0,
      purchaseCount: json['purchase_count'] ?? 0,
      totalEarnings: json['total_earnings'] ?? 0,
      status: json['status'] ?? 1,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      hasAffiliateLink: json['has_affiliate_link'] ?? false,
      createdAt: json['created_at'],
    );
  }
}

class AffiliateEarningListModel {
  bool? status;
  String? message;
  List<AffiliateEarning>? data;

  AffiliateEarningListModel({this.status, this.message, this.data});

  factory AffiliateEarningListModel.fromJson(dynamic json) {
    return AffiliateEarningListModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => AffiliateEarning.fromJson(v)).toList()
          : null,
    );
  }
}

class AffiliateEarning {
  int? id;
  int? affiliateLinkId;
  int? orderId;
  int commissionCoins;
  int status;
  AffiliateLink? affiliateLink;
  dynamic order;
  String? createdAt;

  AffiliateEarning({
    this.id,
    this.affiliateLinkId,
    this.orderId,
    this.commissionCoins = 0,
    this.status = 1,
    this.affiliateLink,
    this.order,
    this.createdAt,
  });

  factory AffiliateEarning.fromJson(dynamic json) {
    return AffiliateEarning(
      id: json['id'],
      affiliateLinkId: json['affiliate_link_id'],
      orderId: json['order_id'],
      commissionCoins: json['commission_coins'] ?? 0,
      status: json['status'] ?? 1,
      affiliateLink: json['affiliate_link'] != null
          ? AffiliateLink.fromJson(json['affiliate_link'])
          : null,
      order: json['order'],
      createdAt: json['created_at'],
    );
  }
}

class AffiliateDashboardModel {
  bool? status;
  String? message;
  AffiliateDashboardData? data;

  AffiliateDashboardModel({this.status, this.message, this.data});

  factory AffiliateDashboardModel.fromJson(dynamic json) {
    return AffiliateDashboardModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? AffiliateDashboardData.fromJson(json['data'])
          : null,
    );
  }
}

class AffiliateDashboardData {
  int totalLinks;
  int totalEarnings;
  int totalPurchases;
  int totalClicks;
  int last30DaysEarnings;
  List<AffiliateLink>? topProducts;

  AffiliateDashboardData({
    this.totalLinks = 0,
    this.totalEarnings = 0,
    this.totalPurchases = 0,
    this.totalClicks = 0,
    this.last30DaysEarnings = 0,
    this.topProducts,
  });

  factory AffiliateDashboardData.fromJson(dynamic json) {
    return AffiliateDashboardData(
      totalLinks: json['total_links'] ?? 0,
      totalEarnings: json['total_earnings'] ?? 0,
      totalPurchases: json['total_purchases'] ?? 0,
      totalClicks: json['total_clicks'] ?? 0,
      last30DaysEarnings: json['last_30_days_earnings'] ?? 0,
      topProducts: json['top_products'] != null
          ? (json['top_products'] as List).map((v) => AffiliateLink.fromJson(v)).toList()
          : null,
    );
  }
}

// Product with affiliate info (used in browse affiliate products)
class AffiliateProductListModel {
  bool? status;
  String? message;
  List<Product>? data;

  AffiliateProductListModel({this.status, this.message, this.data});

  factory AffiliateProductListModel.fromJson(dynamic json) {
    return AffiliateProductListModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => Product.fromJson(v)).toList()
          : null,
    );
  }
}
