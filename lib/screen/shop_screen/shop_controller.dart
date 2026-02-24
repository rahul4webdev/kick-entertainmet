import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/product_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/product/product_model.dart';

class ShopController extends BaseController {
  RxList<Product> products = <Product>[].obs;
  RxList<Product> myProducts = <Product>[].obs;
  RxList<ProductOrder> myOrders = <ProductOrder>[].obs;
  RxList<ProductOrder> sellerOrders = <ProductOrder>[].obs;
  RxList<ProductCategory> categories = <ProductCategory>[].obs;
  RxBool isLoadingProducts = true.obs;
  RxBool isLoadingMyProducts = false.obs;
  RxBool isLoadingOrders = false.obs;
  RxBool isLoadingSellerOrders = false.obs;
  Rx<int?> selectedCategoryId = Rx(null);
  RxString sortBy = 'latest'.obs;

  // Marketplace search & featured
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  RxBool isSearching = false.obs;
  RxList<Product> searchResults = <Product>[].obs;
  RxList<Product> featuredProducts = <Product>[].obs;
  RxList<Product> trendingProducts = <Product>[].obs;
  RxBool isLoadingFeatured = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchCategories();
    fetchFeaturedProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchFeaturedProducts() async {
    isLoadingFeatured.value = true;
    try {
      final response = await ProductService.instance.fetchFeaturedProducts();
      if (response.status == true && response.data != null) {
        featuredProducts.value = response.data!.featured ?? [];
        trendingProducts.value = response.data!.trending ?? [];
      }
    } catch (_) {}
    isLoadingFeatured.value = false;
  }

  Future<void> searchProducts({bool reset = false}) async {
    if (searchQuery.value.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    isSearching.value = true;
    if (reset) searchResults.clear();
    try {
      final response = await ProductService.instance.searchProducts(
        query: searchQuery.value.trim(),
        categoryId: selectedCategoryId.value,
        lastItemId: searchResults.isNotEmpty ? searchResults.last.id : null,
      );
      if (response.status == true && response.data != null) {
        if (reset) {
          searchResults.value = response.data!;
        } else {
          searchResults.addAll(response.data!);
        }
      }
    } catch (_) {}
    isSearching.value = false;
  }

  void onSearchSubmitted(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    searchProducts(reset: true);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (reset) {
      products.clear();
    }
    isLoadingProducts.value = true;
    try {
      final response = await ProductService.instance.fetchProducts(
        categoryId: selectedCategoryId.value,
        sortBy: sortBy.value == 'latest' ? null : sortBy.value,
        lastItemId: products.isNotEmpty ? products.last.id : null,
      );
      if (response.status == true && response.data != null) {
        if (reset) {
          products.value = response.data!;
        } else {
          products.addAll(response.data!);
        }
      }
    } catch (_) {}
    isLoadingProducts.value = false;
  }

  Future<void> fetchMyProducts() async {
    isLoadingMyProducts.value = true;
    try {
      final response = await ProductService.instance.fetchMyProducts();
      if (response.status == true && response.data != null) {
        myProducts.value = response.data!;
      }
    } catch (_) {}
    isLoadingMyProducts.value = false;
  }

  Future<void> fetchMyOrders() async {
    isLoadingOrders.value = true;
    try {
      final response = await ProductService.instance.fetchMyOrders();
      if (response.status == true && response.data != null) {
        myOrders.value = response.data!;
      }
    } catch (_) {}
    isLoadingOrders.value = false;
  }

  Future<void> fetchSellerOrders() async {
    isLoadingSellerOrders.value = true;
    try {
      final response = await ProductService.instance.fetchSellerOrders();
      if (response.status == true && response.data != null) {
        sellerOrders.value = response.data!;
      }
    } catch (_) {}
    isLoadingSellerOrders.value = false;
  }

  Future<void> fetchCategories() async {
    try {
      final response = await ProductService.instance.fetchCategories();
      if (response.status == true && response.data != null) {
        categories.value = response.data!;
      }
    } catch (_) {}
  }

  Future<void> purchaseProduct(Product product) async {
    showLoader();
    try {
      final response = await ProductService.instance.purchaseProduct(
        productId: product.id!,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.purchaseSuccessful);
        fetchProducts(reset: true);
        fetchMyOrders();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> createProduct({
    required String name,
    required int priceCoins,
    String? description,
    int? categoryId,
    int? stock,
  }) async {
    showLoader();
    try {
      final response = await ProductService.instance.createProduct(
        name: name,
        priceCoins: priceCoins,
        description: description,
        categoryId: categoryId,
        stock: stock,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.productCreated);
        fetchMyProducts();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> deleteProduct(int productId) async {
    showLoader();
    try {
      final response = await ProductService.instance.deleteProduct(
        productId: productId,
      );
      stopLoader();
      if (response.status == true) {
        myProducts.removeWhere((p) => p.id == productId);
        showSnackBar(LKey.productDeleted);
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> updateOrderStatus(int orderId, int status) async {
    showLoader();
    try {
      final response = await ProductService.instance.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.orderStatusUpdated);
        fetchSellerOrders();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  void onCategoryChanged(int? categoryId) {
    selectedCategoryId.value = categoryId;
    fetchProducts(reset: true);
  }

  void onSortChanged(String sort) {
    sortBy.value = sort;
    fetchProducts(reset: true);
  }
}
