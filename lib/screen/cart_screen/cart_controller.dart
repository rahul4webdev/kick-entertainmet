import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/cart_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/cart/cart_model.dart';
import 'package:shortzz/screen/cart_screen/checkout_screen.dart';

class CartController extends BaseController {
  RxList<CartItem> cartItems = <CartItem>[].obs;
  RxList<ShippingAddress> addresses = <ShippingAddress>[].obs;
  RxInt totalCoins = 0.obs;
  RxBool isLoadingCart = true.obs;
  RxBool isLoadingAddresses = false.obs;
  RxBool isCheckingOut = false.obs;
  Rx<ShippingAddress?> selectedAddress = Rx(null);

  @override
  void onInit() {
    super.onInit();
    fetchCart();
    fetchAddresses();
  }

  Future<void> fetchCart() async {
    isLoadingCart.value = true;
    try {
      final response = await CartService.instance.fetchCart();
      if (response.status == true && response.data != null) {
        cartItems.value = response.data!;
        totalCoins.value = response.totalCoins ?? 0;
      }
    } catch (_) {}
    isLoadingCart.value = false;
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    try {
      final response = await CartService.instance.addToCart(
        productId: productId,
        quantity: quantity,
      );
      if (response.status == true) {
        showSnackBar(LKey.addedToCart);
        fetchCart();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      removeItem(item);
      return;
    }
    final oldQuantity = item.quantity;
    item.quantity = newQuantity;
    cartItems.refresh();
    _recalculateTotal();

    try {
      final response = await CartService.instance.updateCartItem(
        cartItemId: item.id!,
        quantity: newQuantity,
      );
      if (response.status != true) {
        item.quantity = oldQuantity;
        cartItems.refresh();
        _recalculateTotal();
      }
    } catch (_) {
      item.quantity = oldQuantity;
      cartItems.refresh();
      _recalculateTotal();
    }
  }

  Future<void> removeItem(CartItem item) async {
    cartItems.remove(item);
    _recalculateTotal();
    try {
      await CartService.instance.removeFromCart(cartItemId: item.id!);
    } catch (_) {
      fetchCart();
    }
  }

  Future<void> clearCart() async {
    cartItems.clear();
    totalCoins.value = 0;
    try {
      await CartService.instance.clearCart();
    } catch (_) {
      fetchCart();
    }
  }

  void _recalculateTotal() {
    int total = 0;
    for (final item in cartItems) {
      total += item.itemTotal;
    }
    totalCoins.value = total;
  }

  bool get hasInrItems =>
      cartItems.any((item) =>
          (item.product?.pricePaise != null && item.product!.pricePaise! > 0) ||
          (item.variant?.pricePaise != null && item.variant!.pricePaise! > 0));

  double get totalRupees {
    double total = 0;
    for (final item in cartItems) {
      total += item.itemTotalRupees;
    }
    return total;
  }

  // Addresses
  Future<void> fetchAddresses() async {
    isLoadingAddresses.value = true;
    try {
      final response = await CartService.instance.fetchAddresses();
      if (response.status == true && response.data != null) {
        addresses.value = response.data!;
        final defaultAddr = addresses.where((a) => a.isDefault == true);
        if (defaultAddr.isNotEmpty) {
          selectedAddress.value = defaultAddr.first;
        } else if (addresses.isNotEmpty) {
          selectedAddress.value = addresses.first;
        }
      }
    } catch (_) {}
    isLoadingAddresses.value = false;
  }

  Future<void> addNewAddress({
    required String name,
    String? phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    String? state,
    required String zipCode,
    String? country,
    bool isDefault = false,
  }) async {
    showLoader();
    try {
      final response = await CartService.instance.addAddress(
        name: name,
        phone: phone,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        zipCode: zipCode,
        country: country,
        isDefault: isDefault,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.addressAdded);
        fetchAddresses();
        Get.back();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> deleteAddress(int id) async {
    addresses.removeWhere((a) => a.id == id);
    if (selectedAddress.value?.id == id) {
      selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
    }
    try {
      await CartService.instance.deleteAddress(id: id);
    } catch (_) {
      fetchAddresses();
    }
  }

  void goToCheckout() {
    if (cartItems.isEmpty) return;
    Get.to(() => const CheckoutScreen());
  }

  Future<void> placeOrder({String? note}) async {
    isCheckingOut.value = true;
    try {
      final response = await CartService.instance.checkout(
        addressId: selectedAddress.value?.id,
        note: note,
      );
      isCheckingOut.value = false;
      if (response.status == true) {
        cartItems.clear();
        totalCoins.value = 0;
        Get.back();
        showSnackBar(LKey.orderPlaced);
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      isCheckingOut.value = false;
      showSnackBar(LKey.somethingWentWrong);
    }
  }
}
