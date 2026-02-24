import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/cart/cart_model.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/livestream/live_shopping_product.dart';

class LiveShoppingService {
  LiveShoppingService._();

  static final LiveShoppingService instance = LiveShoppingService._();

  Future<LiveShoppingProductListModel> fetchLiveProducts({
    required String roomId,
  }) async {
    LiveShoppingProductListModel response = await ApiService.instance.call(
      url: WebService.liveShopping.fetchProducts,
      fromJson: LiveShoppingProductListModel.fromJson,
      param: {'room_id': roomId},
    );
    return response;
  }

  Future<StatusModel> addProductToLive({
    required String roomId,
    required int productId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.liveShopping.addProduct,
      fromJson: StatusModel.fromJson,
      param: {'room_id': roomId, 'product_id': productId},
    );
    return response;
  }

  Future<StatusModel> removeProductFromLive({
    required String roomId,
    required int productId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.liveShopping.removeProduct,
      fromJson: StatusModel.fromJson,
      param: {'room_id': roomId, 'product_id': productId},
    );
    return response;
  }

  Future<StatusModel> pinProduct({
    required String roomId,
    required int productId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.liveShopping.pinProduct,
      fromJson: StatusModel.fromJson,
      param: {'room_id': roomId, 'product_id': productId},
    );
    return response;
  }

  Future<StatusModel> unpinProduct({
    required String roomId,
    required int productId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.liveShopping.unpinProduct,
      fromJson: StatusModel.fromJson,
      param: {'room_id': roomId, 'product_id': productId},
    );
    return response;
  }

  Future<CartActionModel> addToCartFromLive({
    required int productId,
    String? roomId,
    int? quantity,
  }) async {
    CartActionModel response = await ApiService.instance.call(
      url: WebService.liveShopping.addToCart,
      fromJson: CartActionModel.fromJson,
      param: {
        'product_id': productId,
        'room_id': roomId,
        'quantity': quantity ?? 1,
      },
    );
    return response;
  }
}
