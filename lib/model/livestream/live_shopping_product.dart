import 'package:shortzz/model/product/product_model.dart';

class LiveShoppingProductListModel {
  bool? status;
  String? message;
  List<LiveShoppingProduct>? data;

  LiveShoppingProductListModel({this.status, this.message, this.data});

  LiveShoppingProductListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(LiveShoppingProduct.fromJson(v));
      });
    }
  }
}

class LiveShoppingProduct {
  int? id;
  String? roomId;
  int? productId;
  int? sellerId;
  int? position;
  bool? isPinned;
  int? unitsSold;
  int? revenueCoins;
  bool? isActive;
  Product? product;

  LiveShoppingProduct({
    this.id,
    this.roomId,
    this.productId,
    this.sellerId,
    this.position,
    this.isPinned,
    this.unitsSold,
    this.revenueCoins,
    this.isActive,
    this.product,
  });

  LiveShoppingProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roomId = json['room_id'];
    productId = json['product_id'];
    sellerId = json['seller_id'];
    position = json['position'];
    isPinned = json['is_pinned'] == true || json['is_pinned'] == 1;
    unitsSold = json['units_sold'];
    revenueCoins = json['revenue_coins'];
    isActive = json['is_active'] == true || json['is_active'] == 1;
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
  }
}
