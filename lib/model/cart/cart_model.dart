import 'package:shortzz/model/product/product_model.dart';

class CartModel {
  bool? status;
  String? message;
  List<CartItem>? data;
  int? totalCoins;
  int? itemCount;

  CartModel({this.status, this.message, this.data, this.totalCoins, this.itemCount});

  CartModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(CartItem.fromJson(v));
      });
    }
    totalCoins = json['total_coins'];
    itemCount = json['item_count'];
  }
}

class CartItem {
  int? id;
  int? userId;
  int? productId;
  int? quantity;
  Product? product;
  String? createdAt;

  CartItem({
    this.id,
    this.userId,
    this.productId,
    this.quantity,
    this.product,
    this.createdAt,
  });

  CartItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    createdAt = json['created_at'];
  }

  int get itemTotal => (product?.priceCoins ?? 0) * (quantity ?? 1);
}

class CartActionModel {
  bool? status;
  String? message;
  int? cartCount;

  CartActionModel({this.status, this.message, this.cartCount});

  CartActionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    cartCount = json['cart_count'];
  }
}

class CheckoutResultModel {
  bool? status;
  String? message;
  List<int>? orderIds;
  int? totalCoins;
  int? coinsRemaining;

  CheckoutResultModel({
    this.status,
    this.message,
    this.orderIds,
    this.totalCoins,
    this.coinsRemaining,
  });

  CheckoutResultModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['order_ids'] != null) {
      orderIds = List<int>.from(json['order_ids']);
    }
    totalCoins = json['total_coins'];
    coinsRemaining = json['coins_remaining'];
  }
}

class ShippingAddressListModel {
  bool? status;
  String? message;
  List<ShippingAddress>? data;

  ShippingAddressListModel({this.status, this.message, this.data});

  ShippingAddressListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(ShippingAddress.fromJson(v));
      });
    }
  }
}

class ShippingAddress {
  int? id;
  int? userId;
  String? name;
  String? phone;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? zipCode;
  String? country;
  bool? isDefault;

  ShippingAddress({
    this.id,
    this.userId,
    this.name,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.isDefault,
  });

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    phone = json['phone'];
    addressLine1 = json['address_line1'];
    addressLine2 = json['address_line2'];
    city = json['city'];
    state = json['state'];
    zipCode = json['zip_code'];
    country = json['country'];
    isDefault = json['is_default'] == true || json['is_default'] == 1;
  }

  String get fullAddress {
    final parts = <String>[];
    if (addressLine1 != null && addressLine1!.isNotEmpty) parts.add(addressLine1!);
    if (addressLine2 != null && addressLine2!.isNotEmpty) parts.add(addressLine2!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}
