import 'package:shortzz/common/extensions/string_extension.dart';

class ProductListModel {
  bool? status;
  String? message;
  List<Product>? data;

  ProductListModel({this.status, this.message, this.data});

  ProductListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(Product.fromJson(v));
      });
    }
  }
}

class ProductDetailModel {
  bool? status;
  String? message;
  Product? data;

  ProductDetailModel({this.status, this.message, this.data});

  ProductDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Product.fromJson(json['data']) : null;
  }
}

class Product {
  int? id;
  int? sellerId;
  int? categoryId;
  String? name;
  String? description;
  int? priceCoins;
  List<String>? images;
  List<String>? imageUrls;
  int? stock;
  int? soldCount;
  int? ratingCount;
  double? avgRating;
  int? viewCount;
  int? status; // 1=pending, 2=approved, 3=rejected
  bool? isActive;
  bool? isDigital;
  String? categoryName;
  ProductSeller? sellerInfo;
  bool? hasPurchased;
  bool hasAffiliateLink = false;
  double? affiliateCommissionRate;
  ReviewSummary? reviewSummary;
  List<ProductReview>? recentReviews;
  String? createdAt;

  Product({
    this.id,
    this.sellerId,
    this.categoryId,
    this.name,
    this.description,
    this.priceCoins,
    this.images,
    this.imageUrls,
    this.stock,
    this.soldCount,
    this.ratingCount,
    this.avgRating,
    this.viewCount,
    this.status,
    this.isActive,
    this.isDigital,
    this.categoryName,
    this.sellerInfo,
    this.hasPurchased,
    this.hasAffiliateLink = false,
    this.affiliateCommissionRate,
    this.reviewSummary,
    this.recentReviews,
    this.createdAt,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sellerId = json['seller_id'];
    categoryId = json['category_id'];
    name = json['name'];
    description = json['description'];
    priceCoins = json['price_coins'];
    if (json['images'] != null) {
      images = List<String>.from(json['images']);
    }
    if (json['image_urls'] != null) {
      imageUrls = List<String>.from(json['image_urls']);
    }
    stock = json['stock'];
    soldCount = json['sold_count'];
    ratingCount = json['rating_count'];
    avgRating = (json['avg_rating'] as num?)?.toDouble();
    viewCount = json['view_count'];
    status = json['status'];
    isActive = json['is_active'] == true;
    isDigital = json['is_digital'] == true;
    categoryName = json['category_name'];
    sellerInfo = json['seller_info'] != null
        ? ProductSeller.fromJson(json['seller_info'])
        : null;
    hasPurchased = json['has_purchased'] == true;
    hasAffiliateLink = json['has_affiliate_link'] == true;
    affiliateCommissionRate = (json['affiliate_commission_rate'] as num?)?.toDouble();
    if (json['seller'] != null && sellerInfo == null) {
      sellerInfo = ProductSeller.fromJson(json['seller']);
    }
    if (json['category'] != null && categoryName == null) {
      categoryName = json['category']['name'];
    }
    if (json['review_summary'] != null) {
      reviewSummary = ReviewSummary.fromJson(json['review_summary']);
    }
    if (json['recent_reviews'] != null) {
      recentReviews = [];
      json['recent_reviews'].forEach((v) {
        recentReviews!.add(ProductReview.fromJson(v));
      });
    }
    createdAt = json['created_at'];
  }

  bool get isPending => status == 1;
  bool get isApproved => status == 2;
  bool get isRejected => status == 3;
  bool get isUnlimitedStock => stock == -1;
  bool get isInStock => stock == -1 || (stock != null && stock! > 0);

  String get firstImageUrl {
    if (imageUrls != null && imageUrls!.isNotEmpty) return imageUrls!.first;
    if (images != null && images!.isNotEmpty) return images!.first.addBaseURL();
    return '';
  }

  String get statusLabel {
    switch (status) {
      case 1:
        return 'Pending';
      case 2:
        return 'Approved';
      case 3:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}

class ProductSeller {
  int? id;
  String? username;
  String? fullname;
  String? profilePhoto;
  int? isVerify;

  ProductSeller({
    this.id,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.isVerify,
  });

  ProductSeller.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    fullname = json['fullname'];
    profilePhoto = json['profile_photo'];
    isVerify = json['is_verify'];
  }
}

class ReviewSummary {
  int? total;
  double? average;

  ReviewSummary({this.total, this.average});

  ReviewSummary.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    average = (json['average'] as num?)?.toDouble();
  }
}

class ProductReview {
  int? id;
  int? productId;
  int? userId;
  int? rating;
  String? reviewText;
  List<String>? photos;
  List<String>? photoUrls;
  bool? isVerifiedPurchase;
  ProductSeller? reviewer;
  String? createdAt;

  ProductReview({
    this.id,
    this.productId,
    this.userId,
    this.rating,
    this.reviewText,
    this.photos,
    this.photoUrls,
    this.isVerifiedPurchase,
    this.reviewer,
    this.createdAt,
  });

  ProductReview.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    userId = json['user_id'];
    rating = json['rating'];
    reviewText = json['review_text'];
    if (json['photos'] != null) {
      photos = List<String>.from(json['photos']);
    }
    if (json['photo_urls'] != null) {
      photoUrls = List<String>.from(json['photo_urls']);
    }
    isVerifiedPurchase = json['is_verified_purchase'] == true;
    reviewer = json['reviewer'] != null
        ? ProductSeller.fromJson(json['reviewer'])
        : null;
    createdAt = json['created_at'];
  }
}

class ProductCategoryModel {
  bool? status;
  String? message;
  List<ProductCategory>? data;

  ProductCategoryModel({this.status, this.message, this.data});

  ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(ProductCategory.fromJson(v));
      });
    }
  }
}

class ProductCategory {
  int? id;
  String? name;
  String? icon;
  int? sortOrder;

  ProductCategory({this.id, this.name, this.icon, this.sortOrder});

  ProductCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    sortOrder = json['sort_order'];
  }
}

class ProductOrderListModel {
  bool? status;
  String? message;
  List<ProductOrder>? data;

  ProductOrderListModel({this.status, this.message, this.data});

  ProductOrderListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(ProductOrder.fromJson(v));
      });
    }
  }
}

class ProductOrder {
  int? id;
  int? productId;
  int? buyerId;
  int? sellerId;
  int? quantity;
  int? totalCoins;
  int? status; // 0=pending, 1=confirmed, 2=shipped, 3=delivered, 4=cancelled, 5=refunded
  String? shippingAddress;
  String? trackingNumber;
  String? buyerNote;
  String? sellerNote;
  Product? product;
  ProductSeller? buyer;
  ProductSeller? seller;
  String? createdAt;

  ProductOrder({
    this.id,
    this.productId,
    this.buyerId,
    this.sellerId,
    this.quantity,
    this.totalCoins,
    this.status,
    this.shippingAddress,
    this.trackingNumber,
    this.buyerNote,
    this.sellerNote,
    this.product,
    this.buyer,
    this.seller,
    this.createdAt,
  });

  ProductOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    buyerId = json['buyer_id'];
    sellerId = json['seller_id'];
    quantity = json['quantity'];
    totalCoins = json['total_coins'];
    status = json['status'];
    shippingAddress = json['shipping_address'];
    trackingNumber = json['tracking_number'];
    buyerNote = json['buyer_note'];
    sellerNote = json['seller_note'];
    product =
        json['product'] != null ? Product.fromJson(json['product']) : null;
    buyer = json['buyer'] != null
        ? ProductSeller.fromJson(json['buyer'])
        : null;
    seller = json['seller'] != null
        ? ProductSeller.fromJson(json['seller'])
        : null;
    createdAt = json['created_at'];
  }

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Shipped';
      case 3:
        return 'Delivered';
      case 4:
        return 'Cancelled';
      case 5:
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }
}

class FeaturedProductsModel {
  bool? status;
  String? message;
  FeaturedProductsData? data;

  FeaturedProductsModel({this.status, this.message, this.data});

  FeaturedProductsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? FeaturedProductsData.fromJson(json['data']) : null;
  }
}

class FeaturedProductsData {
  List<Product>? featured;
  List<Product>? trending;

  FeaturedProductsData({this.featured, this.trending});

  FeaturedProductsData.fromJson(Map<String, dynamic> json) {
    if (json['featured'] != null) {
      featured = [];
      json['featured'].forEach((v) => featured!.add(Product.fromJson(v)));
    }
    if (json['trending'] != null) {
      trending = [];
      json['trending'].forEach((v) => trending!.add(Product.fromJson(v)));
    }
  }
}

class SellerProductsModel {
  bool? status;
  String? message;
  SellerProductsData? data;

  SellerProductsModel({this.status, this.message, this.data});

  SellerProductsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? SellerProductsData.fromJson(json['data']) : null;
  }
}

class SellerProductsData {
  ProductSeller? seller;
  List<Product>? products;

  SellerProductsData({this.seller, this.products});

  SellerProductsData.fromJson(Map<String, dynamic> json) {
    seller = json['seller'] != null ? ProductSeller.fromJson(json['seller']) : null;
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) => products!.add(Product.fromJson(v)));
    }
  }
}

class PurchaseResultModel {
  bool? status;
  String? message;
  PurchaseResult? data;

  PurchaseResultModel({this.status, this.message, this.data});

  PurchaseResultModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? PurchaseResult.fromJson(json['data']) : null;
  }
}

class PurchaseResult {
  int? orderId;
  int? coinsRemaining;

  PurchaseResult({this.orderId, this.coinsRemaining});

  PurchaseResult.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    coinsRemaining = json['coins_remaining'];
  }
}
