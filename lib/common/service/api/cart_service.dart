import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/cart/cart_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class CartService {
  CartService._();

  static final CartService instance = CartService._();

  Future<CartModel> fetchCart() async {
    CartModel response = await ApiService.instance.call(
      url: WebService.cart.fetchCart,
      fromJson: CartModel.fromJson,
    );
    return response;
  }

  Future<CartActionModel> addToCart({
    required int productId,
    int? quantity,
  }) async {
    CartActionModel response = await ApiService.instance.call(
      url: WebService.cart.addToCart,
      fromJson: CartActionModel.fromJson,
      param: {
        'product_id': productId,
        'quantity': quantity ?? 1,
      },
    );
    return response;
  }

  Future<StatusModel> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.cart.updateCartItem,
      fromJson: StatusModel.fromJson,
      param: {
        'cart_item_id': cartItemId,
        'quantity': quantity,
      },
    );
    return response;
  }

  Future<StatusModel> removeFromCart({required int cartItemId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.cart.removeFromCart,
      fromJson: StatusModel.fromJson,
      param: {'cart_item_id': cartItemId},
    );
    return response;
  }

  Future<StatusModel> clearCart() async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.cart.clearCart,
      fromJson: StatusModel.fromJson,
    );
    return response;
  }

  Future<CheckoutResultModel> checkout({
    int? addressId,
    String? note,
  }) async {
    CheckoutResultModel response = await ApiService.instance.call(
      url: WebService.cart.checkout,
      fromJson: CheckoutResultModel.fromJson,
      param: {
        'address_id': addressId,
        'note': note,
      },
    );
    return response;
  }

  // Shipping Addresses
  Future<ShippingAddressListModel> fetchAddresses() async {
    ShippingAddressListModel response = await ApiService.instance.call(
      url: WebService.cart.fetchAddresses,
      fromJson: ShippingAddressListModel.fromJson,
    );
    return response;
  }

  Future<StatusModel> addAddress({
    required String name,
    String? phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    String? state,
    required String zipCode,
    String? country,
    bool? isDefault,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.cart.addAddress,
      fromJson: StatusModel.fromJson,
      param: {
        'name': name,
        'phone': phone,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'country': country,
        'is_default': isDefault == true ? 1 : 0,
      },
    );
    return response;
  }

  Future<StatusModel> editAddress({
    required int id,
    String? name,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.cart.editAddress,
      fromJson: StatusModel.fromJson,
      param: {
        'id': id,
        'name': name,
        'phone': phone,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'country': country,
        'is_default': isDefault == true ? 1 : 0,
      },
    );
    return response;
  }

  Future<StatusModel> deleteAddress({required int id}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.cart.deleteAddress,
      fromJson: StatusModel.fromJson,
      param: {'id': id},
    );
    return response;
  }
}
