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
  // Real money (INR) fields
  int? pricePaise;
  int? compareAtPricePaise;
  int? shippingChargePaise;
  double? priceRupees;
  double? compareAtPriceRupees;
  double? shippingChargeRupees;
  double? gstRate;
  String? hsnCode;
  String? sku;
  String? brandName;
  int? weightGrams;
  double? lengthCm;
  double? breadthCm;
  double? heightCm;
  bool? hasVariants;
  int? minOrderQty;
  int? maxOrderQty;
  String? shippingType; // self, platform, both
  bool? codAvailable;
  int? returnWindowDays;
  bool? isReturnable;
  String? pickupLocationName;
  List<ProductVariant>? variants;

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
    this.pricePaise,
    this.compareAtPricePaise,
    this.shippingChargePaise,
    this.priceRupees,
    this.compareAtPriceRupees,
    this.shippingChargeRupees,
    this.gstRate,
    this.hsnCode,
    this.sku,
    this.brandName,
    this.weightGrams,
    this.lengthCm,
    this.breadthCm,
    this.heightCm,
    this.hasVariants,
    this.minOrderQty,
    this.maxOrderQty,
    this.shippingType,
    this.codAvailable,
    this.returnWindowDays,
    this.isReturnable,
    this.pickupLocationName,
    this.variants,
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
    // Real money fields
    pricePaise = json['price_paise'];
    compareAtPricePaise = json['compare_at_price_paise'];
    shippingChargePaise = json['shipping_charge_paise'];
    priceRupees = (json['price_rupees'] as num?)?.toDouble();
    compareAtPriceRupees = (json['compare_at_price_rupees'] as num?)?.toDouble();
    shippingChargeRupees = (json['shipping_charge_rupees'] as num?)?.toDouble();
    gstRate = (json['gst_rate'] as num?)?.toDouble();
    hsnCode = json['hsn_code'];
    sku = json['sku'];
    brandName = json['brand_name'];
    weightGrams = json['weight_grams'];
    lengthCm = (json['length_cm'] as num?)?.toDouble();
    breadthCm = (json['breadth_cm'] as num?)?.toDouble();
    heightCm = (json['height_cm'] as num?)?.toDouble();
    hasVariants = json['has_variants'] == true;
    minOrderQty = json['min_order_qty'];
    maxOrderQty = json['max_order_qty'];
    shippingType = json['shipping_type'];
    codAvailable = json['cod_available'] == true;
    returnWindowDays = json['return_window_days'];
    isReturnable = json['is_returnable'] == true;
    pickupLocationName = json['pickup_location_name'];
    if (json['variants'] != null) {
      variants = [];
      json['variants'].forEach((v) {
        variants!.add(ProductVariant.fromJson(v));
      });
    }
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

  /// Get display price in rupees. Falls back to coins if no INR price.
  double get displayPriceRupees => priceRupees ?? (pricePaise != null ? pricePaise! / 100.0 : 0);

  /// Formatted price string (e.g., "₹999.00")
  String get formattedPrice {
    final rupees = displayPriceRupees;
    if (rupees > 0) return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
    if (priceCoins != null && priceCoins! > 0) return '$priceCoins coins';
    return 'Free';
  }

  /// Formatted compare-at price (strikethrough price)
  String? get formattedCompareAtPrice {
    if (compareAtPricePaise == null || compareAtPricePaise == 0) return null;
    final rupees = compareAtPricePaise! / 100.0;
    return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
  }

  /// Discount percentage
  int? get discountPercent {
    if (compareAtPricePaise == null || compareAtPricePaise == 0 || pricePaise == null || pricePaise == 0) return null;
    if (compareAtPricePaise! <= pricePaise!) return null;
    return (((compareAtPricePaise! - pricePaise!) / compareAtPricePaise!) * 100).round();
  }

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

class ProductVariant {
  int? id;
  int? productId;
  String? size;
  String? color;
  String? sku;
  int? pricePaise;
  double? priceRupees;
  int? stock;
  List<String>? images;
  List<String>? imageUrls;
  bool? isActive;

  ProductVariant({
    this.id,
    this.productId,
    this.size,
    this.color,
    this.sku,
    this.pricePaise,
    this.priceRupees,
    this.stock,
    this.images,
    this.imageUrls,
    this.isActive,
  });

  ProductVariant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    size = json['size'];
    color = json['color'];
    sku = json['sku'];
    pricePaise = json['price_paise'];
    priceRupees = (json['price_rupees'] as num?)?.toDouble();
    stock = json['stock'];
    if (json['images'] != null) {
      images = List<String>.from(json['images']);
    }
    if (json['image_urls'] != null) {
      imageUrls = List<String>.from(json['image_urls']);
    }
    isActive = json['is_active'] != false;
  }

  String get label {
    final parts = <String>[];
    if (size != null && size!.isNotEmpty) parts.add(size!);
    if (color != null && color!.isNotEmpty) parts.add(color!);
    return parts.join(' / ');
  }

  bool get isInStock => stock == -1 || (stock != null && stock! > 0);
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
  int? status; // 0=pending, 1=confirmed, 2=shipped, 3=delivered, 4=cancelled, 5=refunded, 6=return_requested, 7=return_in_progress, 8=return_completed
  String? shippingAddress;
  String? trackingNumber;
  String? buyerNote;
  String? sellerNote;
  // Real money fields
  int? totalAmountPaise;
  int? shippingChargePaise;
  int? gstAmountPaise;
  String? paymentMethod; // prepaid, cod
  String? shippingMethod; // self, shiprocket, delhivery
  String? awbCode;
  String? courierName;
  String? shippingLabelUrl;
  String? estimatedDeliveryDate;
  String? deliveredAt;
  String? returnWindowExpiresAt;
  String? invoiceNumber;
  List<OrderItem>? items;
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
    this.totalAmountPaise,
    this.shippingChargePaise,
    this.gstAmountPaise,
    this.paymentMethod,
    this.shippingMethod,
    this.awbCode,
    this.courierName,
    this.shippingLabelUrl,
    this.estimatedDeliveryDate,
    this.deliveredAt,
    this.returnWindowExpiresAt,
    this.invoiceNumber,
    this.items,
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
    shippingAddress = json['shipping_address'] is String ? json['shipping_address'] : null;
    trackingNumber = json['tracking_number'];
    buyerNote = json['buyer_note'];
    sellerNote = json['seller_note'];
    totalAmountPaise = json['total_amount_paise'];
    shippingChargePaise = json['shipping_charge_paise'];
    gstAmountPaise = json['gst_amount_paise'];
    paymentMethod = json['payment_method'];
    shippingMethod = json['shipping_method'];
    awbCode = json['awb_code'];
    courierName = json['courier_name'];
    shippingLabelUrl = json['shipping_label_url'];
    estimatedDeliveryDate = json['estimated_delivery_date'];
    deliveredAt = json['delivered_at'];
    returnWindowExpiresAt = json['return_window_expires_at'];
    invoiceNumber = json['invoice_number'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add(OrderItem.fromJson(v));
      });
    }
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    buyer = json['buyer'] != null ? ProductSeller.fromJson(json['buyer']) : null;
    seller = json['seller'] != null ? ProductSeller.fromJson(json['seller']) : null;
    createdAt = json['created_at'];
  }

  /// Display total in rupees
  double get totalRupees => (totalAmountPaise ?? 0) / 100.0;

  /// Formatted total (e.g., "₹999")
  String get formattedTotal {
    if (totalAmountPaise != null && totalAmountPaise! > 0) {
      final rupees = totalAmountPaise! / 100.0;
      return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
    }
    if (totalCoins != null && totalCoins! > 0) return '$totalCoins coins';
    return '₹0';
  }

  bool get isReturnWindowOpen {
    if (returnWindowExpiresAt == null) return false;
    return DateTime.tryParse(returnWindowExpiresAt!)?.isAfter(DateTime.now()) ?? false;
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
      case 6:
        return 'Return Requested';
      case 7:
        return 'Return In Progress';
      case 8:
        return 'Return Completed';
      default:
        return 'Unknown';
    }
  }
}

class OrderItem {
  int? id;
  int? orderId;
  int? productId;
  int? variantId;
  int? quantity;
  int? pricePaise;
  String? variantLabel;
  Product? product;
  ProductVariant? variant;

  OrderItem({this.id, this.orderId, this.productId, this.variantId, this.quantity, this.pricePaise, this.variantLabel, this.product, this.variant});

  OrderItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    productId = json['product_id'];
    variantId = json['variant_id'];
    quantity = json['quantity'];
    pricePaise = json['price_paise'];
    variantLabel = json['variant_label'];
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    variant = json['variant'] != null ? ProductVariant.fromJson(json['variant']) : null;
  }

  double get priceRupees => (pricePaise ?? 0) / 100.0;
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
