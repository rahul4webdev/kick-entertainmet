import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/payment/payment_model.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  // ─── Checkout & Payment ─────────────────────────────────

  Future<CheckoutSummaryModel> getCheckoutSummary() async {
    return await ApiService.instance.call(
      url: WebService.payment.checkoutSummary,
      fromJson: CheckoutSummaryModel.fromJson,
    );
  }

  Future<InitiateCheckoutModel> initiateCheckout({
    required int addressId,
    required String paymentMethod, // 'prepaid' or 'cod'
    String? gateway, // 'razorpay', 'cashfree', 'phonepe'
    String? note,
  }) async {
    return await ApiService.instance.call(
      url: WebService.payment.initiateCheckout,
      fromJson: InitiateCheckoutModel.fromJson,
      param: {
        'address_id': addressId,
        'payment_method': paymentMethod,
        'gateway': gateway,
        'note': note,
      },
    );
  }

  Future<VerifyPaymentModel> verifyPayment({
    required int transactionId,
    required Map<String, dynamic> gatewayResponse,
  }) async {
    return await ApiService.instance.call(
      url: WebService.payment.verify,
      fromJson: VerifyPaymentModel.fromJson,
      param: {
        'transaction_id': transactionId,
        'gateway_response': gatewayResponse,
      },
    );
  }

  Future<PaymentGatewaysModel> getPaymentGateways() async {
    return await ApiService.instance.call(
      url: WebService.payment.gateways,
      fromJson: PaymentGatewaysModel.fromJson,
    );
  }

  // ─── Order Management ───────────────────────────────────

  Future<OrderTrackingModel> trackOrder({required int orderId}) async {
    return await ApiService.instance.call(
      url: WebService.payment.trackOrder,
      fromJson: OrderTrackingModel.fromJson,
      param: {'order_id': orderId},
    );
  }

  Future<StatusModel> shipOrder({
    required int orderId,
    String? shippingMethod, // 'shiprocket', 'delhivery', 'self'
    String? trackingNumber,
    String? courierName,
  }) async {
    return await ApiService.instance.call(
      url: WebService.payment.shipOrder,
      fromJson: StatusModel.fromJson,
      param: {
        'order_id': orderId,
        'shipping_method': shippingMethod,
        'tracking_number': trackingNumber,
        'courier_name': courierName,
      },
    );
  }

  Future<StatusModel> markDelivered({required int orderId}) async {
    return await ApiService.instance.call(
      url: WebService.payment.markDelivered,
      fromJson: StatusModel.fromJson,
      param: {'order_id': orderId},
    );
  }

  Future<StatusModel> cancelOrder({required int orderId}) async {
    return await ApiService.instance.call(
      url: WebService.payment.cancelOrder,
      fromJson: StatusModel.fromJson,
      param: {'order_id': orderId},
    );
  }

  // ─── Seller Earnings ───────────────────────────────────

  Future<SellerEarningsModel> getSellerEarnings({int? limit}) async {
    return await ApiService.instance.call(
      url: WebService.payment.sellerEarnings,
      fromJson: SellerEarningsModel.fromJson,
      param: {'limit': limit ?? 10},
    );
  }

  // ─── Returns ───────────────────────────────────────────

  Future<ReturnDetailModel> requestReturn({
    required int orderId,
    int? orderItemId,
    required String reason,
    required String description,
    String? returnType, // 'refund', 'replacement', 'exchange'
    List<XFile?>? photos,
  }) async {
    final param = <String, dynamic>{
      'order_id': orderId,
      'order_item_id': orderItemId,
      'reason': reason,
      'description': description,
      'return_type': returnType ?? 'refund',
    };

    if (photos != null && photos.isNotEmpty) {
      return await ApiService.instance.multiPartCallApi(
        url: WebService.returns.request,
        fromJson: ReturnDetailModel.fromJson,
        param: param,
        filesMap: {'photos[]': photos},
      );
    }

    return await ApiService.instance.call(
      url: WebService.returns.request,
      fromJson: ReturnDetailModel.fromJson,
      param: param,
    );
  }

  Future<ReturnDetailModel> respondToReturn({
    required int returnId,
    required String action, // 'approve' or 'reject'
    String? sellerResponse,
  }) async {
    return await ApiService.instance.call(
      url: WebService.returns.respond,
      fromJson: ReturnDetailModel.fromJson,
      param: {
        'return_id': returnId,
        'action': action,
        'seller_response': sellerResponse,
      },
    );
  }

  Future<ReturnListModel> fetchReturns({
    String? role, // 'buyer' or 'seller'
    int? status,
    int? lastItemId,
    int? limit,
  }) async {
    return await ApiService.instance.call(
      url: WebService.returns.fetch,
      fromJson: ReturnListModel.fromJson,
      param: {
        'role': role ?? 'buyer',
        'status': status,
        'last_item_id': lastItemId,
        'limit': limit ?? 20,
      },
    );
  }

  Future<ReturnDetailModel> inspectReturn({
    required int returnId,
    required String inspectionResult, // 'passed' or 'failed'
    String? adminNotes,
    List<XFile?>? inspectionPhotos,
  }) async {
    final param = <String, dynamic>{
      'return_id': returnId,
      'inspection_result': inspectionResult,
      'admin_notes': adminNotes,
    };

    if (inspectionPhotos != null && inspectionPhotos.isNotEmpty) {
      return await ApiService.instance.multiPartCallApi(
        url: WebService.returns.inspect,
        fromJson: ReturnDetailModel.fromJson,
        param: param,
        filesMap: {'inspection_photos[]': inspectionPhotos},
      );
    }

    return await ApiService.instance.call(
      url: WebService.returns.inspect,
      fromJson: ReturnDetailModel.fromJson,
      param: param,
    );
  }

  // ─── Seller Application ────────────────────────────────

  Future<SellerApplicationModel> submitSellerApplication({
    required String businessName,
    required String businessType,
    String? gstin,
    required String pan,
    String? businessAddress,
    String? businessCity,
    String? businessState,
    String? businessPincode,
    List<XFile?>? documents,
  }) async {
    final param = <String, dynamic>{
      'business_name': businessName,
      'business_type': businessType,
      'gstin': gstin,
      'pan': pan,
      'business_address': businessAddress,
      'business_city': businessCity,
      'business_state': businessState,
      'business_pincode': businessPincode,
    };

    if (documents != null && documents.isNotEmpty) {
      return await ApiService.instance.multiPartCallApi(
        url: WebService.seller.submitApplication,
        fromJson: SellerApplicationModel.fromJson,
        param: param,
        filesMap: {'documents[]': documents},
      );
    }

    return await ApiService.instance.call(
      url: WebService.seller.submitApplication,
      fromJson: SellerApplicationModel.fromJson,
      param: param,
    );
  }

  Future<SellerApplicationModel> fetchMySellerApplication() async {
    return await ApiService.instance.call(
      url: WebService.seller.fetchMyApplication,
      fromJson: SellerApplicationModel.fromJson,
    );
  }

  Future<StatusModel> updateSellerBankDetails({
    required String accountNumber,
    required String ifsc,
    required String accountHolderName,
  }) async {
    return await ApiService.instance.call(
      url: WebService.seller.updateBankDetails,
      fromJson: StatusModel.fromJson,
      param: {
        'account_number': accountNumber,
        'ifsc': ifsc,
        'account_holder_name': accountHolderName,
      },
    );
  }

  Future<StatusModel> updateSellerBusinessAddress({
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) async {
    return await ApiService.instance.call(
      url: WebService.seller.updateBusinessAddress,
      fromJson: StatusModel.fromJson,
      param: {
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
      },
    );
  }

  // ─── Affiliate Application ─────────────────────────────

  Future<StatusModel> submitAffiliateApplication({
    String? platformUrl,
    String? audienceDescription,
  }) async {
    return await ApiService.instance.call(
      url: WebService.affiliateApplication.submit,
      fromJson: StatusModel.fromJson,
      param: {
        'platform_url': platformUrl,
        'audience_description': audienceDescription,
      },
    );
  }

  Future<Map<String, dynamic>> fetchMyAffiliateApplication() async {
    return await ApiService.instance.call(
      url: WebService.affiliateApplication.fetchMine,
      fromJson: (json) => json,
    );
  }

  // ─── Shoot Requests ────────────────────────────────────

  Future<StatusModel> createShootRequest({
    required int productId,
    required String requestType, // 'photo', 'video', 'both'
    required String description,
    List<XFile?>? referenceImages,
  }) async {
    final param = <String, dynamic>{
      'product_id': productId,
      'request_type': requestType,
      'description': description,
    };

    if (referenceImages != null && referenceImages.isNotEmpty) {
      return await ApiService.instance.multiPartCallApi(
        url: WebService.shootRequest.create,
        fromJson: StatusModel.fromJson,
        param: param,
        filesMap: {'reference_images[]': referenceImages},
      );
    }

    return await ApiService.instance.call(
      url: WebService.shootRequest.create,
      fromJson: StatusModel.fromJson,
      param: param,
    );
  }

  Future<StatusModel> respondToShootRequest({
    required int requestId,
    required String action, // 'accept' or 'decline'
    int? quotePaise,
  }) async {
    return await ApiService.instance.call(
      url: WebService.shootRequest.respond,
      fromJson: StatusModel.fromJson,
      param: {
        'request_id': requestId,
        'action': action,
        'quote_paise': quotePaise,
      },
    );
  }

  Future<StatusModel> sendShootMessage({
    required int requestId,
    required String message,
  }) async {
    return await ApiService.instance.call(
      url: WebService.shootRequest.sendMessage,
      fromJson: StatusModel.fromJson,
      param: {
        'request_id': requestId,
        'message': message,
      },
    );
  }

  Future<ShootMessageListModel> fetchShootMessages({
    required int requestId,
    int? lastItemId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.shootRequest.fetchMessages,
      fromJson: ShootMessageListModel.fromJson,
      param: {
        'request_id': requestId,
        'last_item_id': lastItemId,
      },
    );
  }

  Future<ShootRequestListModel> fetchMyShootRequests({
    String? role, // 'seller' or 'creator'
    int? status,
    int? lastItemId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.shootRequest.fetchMyRequests,
      fromJson: ShootRequestListModel.fromJson,
      param: {
        'role': role,
        'status': status,
        'last_item_id': lastItemId,
      },
    );
  }

  Future<StatusModel> updateShootRequestStatus({
    required int requestId,
    required int status,
  }) async {
    return await ApiService.instance.call(
      url: WebService.shootRequest.updateStatus,
      fromJson: StatusModel.fromJson,
      param: {
        'request_id': requestId,
        'status': status,
      },
    );
  }
}
