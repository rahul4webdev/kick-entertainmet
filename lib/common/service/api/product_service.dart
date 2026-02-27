import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/product/product_model.dart';

class ProductService {
  ProductService._();

  static final ProductService instance = ProductService._();

  Future<ProductListModel> fetchProducts({
    int? categoryId,
    int? sellerId,
    String? search,
    String? sortBy,
    int? lastItemId,
    int? limit,
  }) async {
    ProductListModel response = await ApiService.instance.call(
      url: WebService.shop.fetchProducts,
      fromJson: ProductListModel.fromJson,
      param: {
        'category_id': categoryId,
        'seller_id': sellerId,
        'search': search,
        'sort_by': sortBy,
        'last_item_id': lastItemId,
        'limit': limit ?? 20,
      },
    );
    return response;
  }

  Future<ProductListModel> fetchMyProducts() async {
    ProductListModel response = await ApiService.instance.call(
      url: WebService.shop.fetchMyProducts,
      fromJson: ProductListModel.fromJson,
    );
    return response;
  }

  Future<ProductDetailModel> fetchProductById({
    required int productId,
  }) async {
    ProductDetailModel response = await ApiService.instance.call(
      url: WebService.shop.fetchProductById,
      fromJson: ProductDetailModel.fromJson,
      param: {'product_id': productId},
    );
    return response;
  }

  Future<StatusModel> createProduct({
    required String name,
    int? priceCoins,
    // Real money (INR) fields
    int? pricePaise,
    int? compareAtPricePaise,
    int? shippingChargePaise,
    double? gstRate,
    String? hsnCode,
    String? sku,
    String? brandName,
    int? weightGrams,
    double? lengthCm,
    double? breadthCm,
    double? heightCm,
    String? shippingType,
    bool? codAvailable,
    int? returnWindowDaysOverride,
    String? pickupLocationName,
    String? description,
    int? categoryId,
    int? stock,
    bool? isDigital,
    int? minOrderQty,
    int? maxOrderQty,
    // Variants as JSON string
    String? variantsJson,
    List<XFile?>? images,
  }) async {
    final param = <String, dynamic>{
      'name': name,
      'price_coins': priceCoins,
      'price_paise': pricePaise,
      'compare_at_price_paise': compareAtPricePaise,
      'shipping_charge_paise': shippingChargePaise,
      'gst_rate': gstRate,
      'hsn_code': hsnCode,
      'sku': sku,
      'brand_name': brandName,
      'weight_grams': weightGrams,
      'length_cm': lengthCm,
      'breadth_cm': breadthCm,
      'height_cm': heightCm,
      'shipping_type': shippingType,
      'cod_available': codAvailable == true ? 1 : null,
      'return_window_days_override': returnWindowDaysOverride,
      'pickup_location_name': pickupLocationName,
      'description': description,
      'category_id': categoryId,
      'stock': stock ?? -1,
      'is_digital': isDigital == true ? 1 : 0,
      'min_order_qty': minOrderQty,
      'max_order_qty': maxOrderQty,
      'variants': variantsJson,
    };

    if (images != null && images.isNotEmpty) {
      return await ApiService.instance.multiPartCallApi(
        url: WebService.shop.createProduct,
        fromJson: StatusModel.fromJson,
        param: param,
        filesMap: {'images[]': images},
      );
    }

    StatusModel response = await ApiService.instance.call(
      url: WebService.shop.createProduct,
      fromJson: StatusModel.fromJson,
      param: param,
    );
    return response;
  }

  Future<StatusModel> updateProduct({
    required int productId,
    String? name,
    int? priceCoins,
    int? pricePaise,
    int? compareAtPricePaise,
    int? shippingChargePaise,
    double? gstRate,
    String? hsnCode,
    String? sku,
    String? brandName,
    int? weightGrams,
    double? lengthCm,
    double? breadthCm,
    double? heightCm,
    String? shippingType,
    bool? codAvailable,
    int? returnWindowDaysOverride,
    String? pickupLocationName,
    String? description,
    int? categoryId,
    int? stock,
    bool? isActive,
    int? minOrderQty,
    int? maxOrderQty,
    String? variantsJson,
    List<XFile?>? images,
  }) async {
    final param = <String, dynamic>{
      'product_id': productId,
      'name': name,
      'price_coins': priceCoins,
      'price_paise': pricePaise,
      'compare_at_price_paise': compareAtPricePaise,
      'shipping_charge_paise': shippingChargePaise,
      'gst_rate': gstRate,
      'hsn_code': hsnCode,
      'sku': sku,
      'brand_name': brandName,
      'weight_grams': weightGrams,
      'length_cm': lengthCm,
      'breadth_cm': breadthCm,
      'height_cm': heightCm,
      'shipping_type': shippingType,
      'cod_available': codAvailable == true ? 1 : (codAvailable == false ? 0 : null),
      'return_window_days_override': returnWindowDaysOverride,
      'pickup_location_name': pickupLocationName,
      'description': description,
      'category_id': categoryId,
      'stock': stock,
      'is_active': isActive,
      'min_order_qty': minOrderQty,
      'max_order_qty': maxOrderQty,
      'variants': variantsJson,
    };

    if (images != null && images.isNotEmpty) {
      return await ApiService.instance.multiPartCallApi(
        url: WebService.shop.updateProduct,
        fromJson: StatusModel.fromJson,
        param: param,
        filesMap: {'images[]': images},
      );
    }

    StatusModel response = await ApiService.instance.call(
      url: WebService.shop.updateProduct,
      fromJson: StatusModel.fromJson,
      param: param,
    );
    return response;
  }

  Future<StatusModel> deleteProduct({required int productId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.shop.deleteProduct,
      fromJson: StatusModel.fromJson,
      param: {'product_id': productId},
    );
    return response;
  }

  Future<PurchaseResultModel> purchaseProduct({
    required int productId,
    int? quantity,
    String? shippingAddress,
    String? buyerNote,
  }) async {
    PurchaseResultModel response = await ApiService.instance.call(
      url: WebService.shop.purchaseProduct,
      fromJson: PurchaseResultModel.fromJson,
      param: {
        'product_id': productId,
        'quantity': quantity ?? 1,
        'shipping_address': shippingAddress,
        'buyer_note': buyerNote,
      },
    );
    return response;
  }

  Future<ProductOrderListModel> fetchMyOrders({int? lastItemId}) async {
    ProductOrderListModel response = await ApiService.instance.call(
      url: WebService.shop.fetchMyOrders,
      fromJson: ProductOrderListModel.fromJson,
      param: {'last_item_id': lastItemId},
    );
    return response;
  }

  Future<ProductOrderListModel> fetchSellerOrders({
    int? lastItemId,
    int? statusFilter,
  }) async {
    ProductOrderListModel response = await ApiService.instance.call(
      url: WebService.shop.fetchSellerOrders,
      fromJson: ProductOrderListModel.fromJson,
      param: {
        'last_item_id': lastItemId,
        'status_filter': statusFilter,
      },
    );
    return response;
  }

  Future<StatusModel> updateOrderStatus({
    required int orderId,
    required int status,
    String? trackingNumber,
    String? sellerNote,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.shop.updateOrderStatus,
      fromJson: StatusModel.fromJson,
      param: {
        'order_id': orderId,
        'status': status,
        'tracking_number': trackingNumber,
        'seller_note': sellerNote,
      },
    );
    return response;
  }

  Future<StatusModel> submitReview({
    required int productId,
    required int rating,
    String? reviewText,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.shop.submitReview,
      fromJson: StatusModel.fromJson,
      param: {
        'product_id': productId,
        'rating': rating,
        'review_text': reviewText,
      },
    );
    return response;
  }

  Future<ProductCategoryModel> fetchCategories() async {
    ProductCategoryModel response = await ApiService.instance.call(
      url: WebService.shop.fetchCategories,
      fromJson: ProductCategoryModel.fromJson,
    );
    return response;
  }

  Future<StatusModel> tagProducts({
    required int postId,
    required List<int> productIds,
    List<String?>? labels,
  }) async {
    final param = <String, dynamic>{
      'post_id': postId,
      'product_ids': productIds.join(','),
    };
    if (labels != null) {
      param['labels'] = labels.toString();
    }
    StatusModel response = await ApiService.instance.call(
      url: WebService.shop.tagProducts,
      fromJson: StatusModel.fromJson,
      param: param,
    );
    return response;
  }

  Future<StatusModel> untagProduct({
    required int postId,
    required int productId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.shop.untagProduct,
      fromJson: StatusModel.fromJson,
      param: {'post_id': postId, 'product_id': productId},
    );
    return response;
  }

  Future<ProductListModel> searchProducts({
    String? query,
    int? categoryId,
    int? minPrice,
    int? maxPrice,
    double? minRating,
    String? sortBy,
    int? lastItemId,
    int? limit,
  }) async {
    return await ApiService.instance.call(
      url: WebService.shop.searchProducts,
      fromJson: ProductListModel.fromJson,
      param: {
        if (query != null) 'query': query,
        if (categoryId != null) 'category_id': categoryId,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (minRating != null) 'min_rating': minRating,
        if (sortBy != null) 'sort_by': sortBy,
        'last_item_id': lastItemId,
        'limit': limit ?? 20,
      },
    );
  }

  Future<FeaturedProductsModel> fetchFeaturedProducts() async {
    return await ApiService.instance.call(
      url: WebService.shop.fetchFeaturedProducts,
      fromJson: FeaturedProductsModel.fromJson,
    );
  }

  Future<StatusModel> tagProductsEnhanced({
    required int postId,
    required List<Map<String, dynamic>> tags,
  }) async {
    return await ApiService.instance.call(
      url: WebService.shop.tagProductsEnhanced,
      fromJson: StatusModel.fromJson,
      param: {
        'post_id': postId,
        'tags': tags,
      },
    );
  }

  Future<SellerProductsModel> fetchSellerProducts({
    required int sellerId,
    int? lastItemId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.shop.fetchSellerProducts,
      fromJson: SellerProductsModel.fromJson,
      param: {
        'seller_id': sellerId,
        'last_item_id': lastItemId,
      },
    );
  }
}
