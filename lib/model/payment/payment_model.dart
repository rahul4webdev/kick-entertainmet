import 'package:shortzz/model/cart/cart_model.dart';
import 'package:shortzz/model/product/product_model.dart';

// ─── Checkout Summary ───────────────────────────────────────

class CheckoutSummaryModel {
  bool? status;
  String? message;
  CheckoutSummaryData? data;

  CheckoutSummaryModel({this.status, this.message, this.data});

  CheckoutSummaryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? CheckoutSummaryData.fromJson(json['data'])
        : null;
  }
}

class CheckoutSummaryData {
  List<CheckoutItem>? items;
  int? subtotalPaise;
  int? shippingPaise;
  int? gstPaise;
  int? grandTotalPaise;
  double? subtotalRupees;
  double? shippingRupees;
  double? gstRupees;
  double? grandTotalRupees;
  bool? codAvailable;
  List<String>? gateways;
  List<ShippingAddress>? addresses;

  CheckoutSummaryData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items!.add(CheckoutItem.fromJson(v));
      });
    }
    subtotalPaise = json['subtotal_paise'];
    shippingPaise = json['shipping_paise'];
    gstPaise = json['gst_paise'];
    grandTotalPaise = json['grand_total_paise'];
    subtotalRupees = (json['subtotal_rupees'] as num?)?.toDouble();
    shippingRupees = (json['shipping_rupees'] as num?)?.toDouble();
    gstRupees = (json['gst_rupees'] as num?)?.toDouble();
    grandTotalRupees = (json['grand_total_rupees'] as num?)?.toDouble();
    codAvailable = json['cod_available'] == true;
    if (json['gateways'] != null) {
      gateways = List<String>.from(json['gateways']);
    }
    if (json['addresses'] != null) {
      addresses = [];
      json['addresses'].forEach((v) {
        addresses!.add(ShippingAddress.fromJson(v));
      });
    }
  }

  String get formattedGrandTotal {
    final rupees = grandTotalRupees ?? (grandTotalPaise != null ? grandTotalPaise! / 100.0 : 0.0);
    return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
  }
}

class CheckoutItem {
  int? productId;
  String? name;
  String? image;
  int? variantId;
  String? variantLabel;
  int? quantity;
  int? pricePaise;
  int? lineTotalPaise;
  int? shippingPaise;
  int? gstPaise;

  CheckoutItem.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    name = json['name'];
    image = json['image'];
    variantId = json['variant_id'];
    variantLabel = json['variant_label'];
    quantity = json['quantity'];
    pricePaise = json['price_paise'];
    lineTotalPaise = json['line_total_paise'];
    shippingPaise = json['shipping_paise'];
    gstPaise = json['gst_paise'];
  }

  double get priceRupees => (pricePaise ?? 0) / 100.0;
  double get lineTotalRupees => (lineTotalPaise ?? 0) / 100.0;
}

// ─── Checkout Initiation (Payment Order) ────────────────────

class InitiateCheckoutModel {
  bool? status;
  String? message;
  InitiateCheckoutData? data;

  InitiateCheckoutModel({this.status, this.message, this.data});

  InitiateCheckoutModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? InitiateCheckoutData.fromJson(json['data'])
        : null;
  }
}

class InitiateCheckoutData {
  List<int>? orderIds;
  String? paymentMethod;
  int? totalAmountPaise;
  PaymentData? payment;

  InitiateCheckoutData.fromJson(Map<String, dynamic> json) {
    if (json['order_ids'] != null) {
      orderIds = List<int>.from(json['order_ids']);
    }
    paymentMethod = json['payment_method'];
    totalAmountPaise = json['total_amount_paise'];
    payment = json['payment'] != null
        ? PaymentData.fromJson(json['payment'])
        : null;
  }
}

class PaymentData {
  String? gateway;
  int? transactionId;
  String? gatewayOrderId;
  String? razorpayKey;
  String? paymentSessionId;
  String? redirectUrl;
  int? amountPaise;

  PaymentData.fromJson(Map<String, dynamic> json) {
    gateway = json['gateway'];
    transactionId = json['transaction_id'];
    gatewayOrderId = json['gateway_order_id'];
    razorpayKey = json['razorpay_key'];
    paymentSessionId = json['payment_session_id'];
    redirectUrl = json['redirect_url'];
    amountPaise = json['amount_paise'];
  }
}

// ─── Payment Verification ───────────────────────────────────

class VerifyPaymentModel {
  bool? status;
  String? message;
  VerifyPaymentData? data;

  VerifyPaymentModel({this.status, this.message, this.data});

  VerifyPaymentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? VerifyPaymentData.fromJson(json['data'])
        : null;
  }
}

class VerifyPaymentData {
  String? transactionStatus;
  String? paymentMethod;
  List<int>? orderIds;

  VerifyPaymentData.fromJson(Map<String, dynamic> json) {
    transactionStatus = json['transaction_status'];
    paymentMethod = json['payment_method'];
    if (json['order_ids'] != null) {
      orderIds = List<int>.from(json['order_ids']);
    }
  }
}

// ─── Payment Gateways ───────────────────────────────────────

class PaymentGatewaysModel {
  bool? status;
  String? message;
  List<String>? data;

  PaymentGatewaysModel({this.status, this.message, this.data});

  PaymentGatewaysModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = List<String>.from(json['data']);
    }
  }
}

// ─── Order Tracking ─────────────────────────────────────────

class OrderTrackingModel {
  bool? status;
  String? message;
  OrderTrackingData? data;

  OrderTrackingModel({this.status, this.message, this.data});

  OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? OrderTrackingData.fromJson(json['data'])
        : null;
  }
}

class OrderTrackingData {
  ProductOrder? order;
  Map<String, dynamic>? tracking;
  List<OrderStatusEntry>? statusHistory;

  OrderTrackingData.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? ProductOrder.fromJson(json['order']) : null;
    tracking = json['tracking'] is Map<String, dynamic> ? json['tracking'] : null;
    if (json['status_history'] != null) {
      statusHistory = [];
      json['status_history'].forEach((v) {
        statusHistory!.add(OrderStatusEntry.fromJson(v));
      });
    }
  }
}

class OrderStatusEntry {
  int? id;
  int? orderId;
  int? status;
  String? title;
  String? description;
  String? createdAt;

  OrderStatusEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    status = json['status'];
    title = json['title'];
    description = json['description'];
    createdAt = json['created_at'];
  }
}

// ─── Seller Earnings ────────────────────────────────────────

class SellerEarningsModel {
  bool? status;
  String? message;
  SellerEarningsData? data;

  SellerEarningsModel({this.status, this.message, this.data});

  SellerEarningsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? SellerEarningsData.fromJson(json['data'])
        : null;
  }
}

class SellerEarningsData {
  EarningsSummary? summary;
  List<PayoutEntry>? recentPayouts;

  SellerEarningsData.fromJson(Map<String, dynamic> json) {
    summary = json['summary'] != null
        ? EarningsSummary.fromJson(json['summary'])
        : null;
    if (json['recent_payouts'] != null) {
      recentPayouts = [];
      json['recent_payouts'].forEach((v) {
        recentPayouts!.add(PayoutEntry.fromJson(v));
      });
    }
  }
}

class EarningsSummary {
  int? walletBalancePaise;
  int? pendingPayoutPaise;
  int? inHoldPaise;
  int? lifetimeEarningsPaise;
  int? totalOrdersCount;
  int? currentMonthEarningsPaise;
  int? previousMonthEarningsPaise;

  EarningsSummary.fromJson(Map<String, dynamic> json) {
    walletBalancePaise = json['wallet_balance_paise'];
    pendingPayoutPaise = json['pending_payout_paise'];
    inHoldPaise = json['in_hold_paise'];
    lifetimeEarningsPaise = json['lifetime_earnings_paise'];
    totalOrdersCount = json['total_orders_count'];
    currentMonthEarningsPaise = json['current_month_earnings_paise'];
    previousMonthEarningsPaise = json['previous_month_earnings_paise'];
  }

  double get walletBalanceRupees => (walletBalancePaise ?? 0) / 100.0;
  double get pendingPayoutRupees => (pendingPayoutPaise ?? 0) / 100.0;
  double get inHoldRupees => (inHoldPaise ?? 0) / 100.0;
  double get lifetimeEarningsRupees => (lifetimeEarningsPaise ?? 0) / 100.0;
  double get currentMonthRupees => (currentMonthEarningsPaise ?? 0) / 100.0;
  double get previousMonthRupees => (previousMonthEarningsPaise ?? 0) / 100.0;
}

class PayoutEntry {
  int? id;
  int? sellerId;
  int? amountPaise;
  String? status;
  String? utrNumber;
  String? method;
  String? bankAccountNumber;
  String? bankIfsc;
  String? createdAt;
  String? processedAt;

  PayoutEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sellerId = json['seller_id'];
    amountPaise = json['amount_paise'];
    status = json['status'];
    utrNumber = json['utr_number'];
    method = json['method'];
    bankAccountNumber = json['bank_account_number'];
    bankIfsc = json['bank_ifsc'];
    createdAt = json['created_at'];
    processedAt = json['processed_at'];
  }

  double get amountRupees => (amountPaise ?? 0) / 100.0;
}

// ─── Returns ────────────────────────────────────────────────

class ReturnListModel {
  bool? status;
  String? message;
  List<ProductReturnItem>? data;

  ReturnListModel({this.status, this.message, this.data});

  ReturnListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(ProductReturnItem.fromJson(v));
      });
    }
  }
}

class ReturnDetailModel {
  bool? status;
  String? message;
  ProductReturnItem? data;

  ReturnDetailModel({this.status, this.message, this.data});

  ReturnDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? ProductReturnItem.fromJson(json['data'])
        : null;
  }
}

class ProductReturnItem {
  int? id;
  int? orderId;
  int? orderItemId;
  int? buyerId;
  int? sellerId;
  int? productId;
  String? reason;
  String? description;
  List<String>? photos;
  String? returnType; // refund, replacement, exchange
  int? status;
  // 0=requested, 1=approved, 2=rejected, 3=pickup_scheduled,
  // 4=in_transit, 5=received_by_seller, 6=inspection_passed,
  // 7=inspection_failed, 8=refund_initiated, 9=refund_completed
  String? sellerResponse;
  int? refundAmountPaise;
  String? refundMethod;
  String? returnAwb;
  String? returnCourier;
  String? adminNotes;
  ProductSeller? buyer;
  ProductSeller? seller;
  Product? product;
  String? approvedAt;
  String? pickupScheduledAt;
  String? receivedAt;
  String? refundInitiatedAt;
  String? refundCompletedAt;
  String? createdAt;

  ProductReturnItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    orderItemId = json['order_item_id'];
    buyerId = json['buyer_id'];
    sellerId = json['seller_id'];
    productId = json['product_id'];
    reason = json['reason'];
    description = json['description'];
    if (json['photos'] != null && json['photos'] is List) {
      photos = List<String>.from(json['photos']);
    }
    returnType = json['return_type'];
    status = json['status'];
    sellerResponse = json['seller_response'];
    refundAmountPaise = json['refund_amount_paise'];
    refundMethod = json['refund_method'];
    returnAwb = json['return_awb'];
    returnCourier = json['return_courier'];
    adminNotes = json['admin_notes'];
    buyer = json['buyer'] != null ? ProductSeller.fromJson(json['buyer']) : null;
    seller = json['seller'] != null ? ProductSeller.fromJson(json['seller']) : null;
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    approvedAt = json['approved_at'];
    pickupScheduledAt = json['pickup_scheduled_at'];
    receivedAt = json['received_at'];
    refundInitiatedAt = json['refund_initiated_at'];
    refundCompletedAt = json['refund_completed_at'];
    createdAt = json['created_at'];
  }

  double get refundAmountRupees => (refundAmountPaise ?? 0) / 100.0;

  String get statusLabel {
    switch (status) {
      case 0: return 'Requested';
      case 1: return 'Approved';
      case 2: return 'Rejected';
      case 3: return 'Pickup Scheduled';
      case 4: return 'In Transit';
      case 5: return 'Received by Seller';
      case 6: return 'Inspection Passed';
      case 7: return 'Inspection Failed';
      case 8: return 'Refund Initiated';
      case 9: return 'Refund Completed';
      default: return 'Unknown';
    }
  }

  String get reasonLabel {
    switch (reason) {
      case 'defective': return 'Defective Product';
      case 'wrong_item': return 'Wrong Item Received';
      case 'not_as_described': return 'Not As Described';
      case 'size_issue': return 'Size Issue';
      case 'change_of_mind': return 'Change of Mind';
      case 'damaged_in_transit': return 'Damaged in Transit';
      case 'other': return 'Other';
      default: return reason ?? 'Unknown';
    }
  }
}

// ─── Seller Application ─────────────────────────────────────

class SellerApplicationModel {
  bool? status;
  String? message;
  SellerApplication? data;

  SellerApplicationModel({this.status, this.message, this.data});

  SellerApplicationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? SellerApplication.fromJson(json['data'])
        : null;
  }
}

class SellerApplication {
  int? id;
  int? userId;
  String? businessName;
  String? businessType;
  String? gstin;
  String? pan;
  int? status; // 0=pending, 1=approved, 2=rejected
  String? rejectionReason;
  String? businessAddress;
  String? businessCity;
  String? businessState;
  String? businessPincode;
  String? bankAccountNumber;
  String? bankIfsc;
  String? bankAccountHolderName;
  String? createdAt;

  SellerApplication.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    businessName = json['business_name'];
    businessType = json['business_type'];
    gstin = json['gstin'];
    pan = json['pan'];
    status = json['status'];
    rejectionReason = json['rejection_reason'];
    businessAddress = json['business_address'];
    businessCity = json['business_city'];
    businessState = json['business_state'];
    businessPincode = json['business_pincode'];
    bankAccountNumber = json['bank_account_number'];
    bankIfsc = json['bank_ifsc'];
    bankAccountHolderName = json['bank_account_holder_name'];
    createdAt = json['created_at'];
  }

  bool get isPending => status == 0;
  bool get isApproved => status == 1;
  bool get isRejected => status == 2;

  String get statusLabel {
    switch (status) {
      case 0: return 'Pending Review';
      case 1: return 'Approved';
      case 2: return 'Rejected';
      default: return 'Unknown';
    }
  }
}

// ─── Shoot Request ──────────────────────────────────────────

class ShootRequestListModel {
  bool? status;
  String? message;
  List<ShootRequest>? data;

  ShootRequestListModel({this.status, this.message, this.data});

  ShootRequestListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(ShootRequest.fromJson(v));
      });
    }
  }
}

class ShootRequest {
  int? id;
  int? sellerId;
  int? productId;
  String? requestType; // photo, video, both
  String? description;
  String? referenceImages;
  int? status; // 0=pending, 1=accepted, 2=completed, 3=cancelled
  int? assignedCreatorId;
  String? quotePaise;
  String? createdAt;

  ShootRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sellerId = json['seller_id'];
    productId = json['product_id'];
    requestType = json['request_type'];
    description = json['description'];
    referenceImages = json['reference_images'];
    status = json['status'];
    assignedCreatorId = json['assigned_creator_id'];
    quotePaise = json['quote_paise']?.toString();
    createdAt = json['created_at'];
  }

  String get statusLabel {
    switch (status) {
      case 0: return 'Pending';
      case 1: return 'Accepted';
      case 2: return 'Completed';
      case 3: return 'Cancelled';
      default: return 'Unknown';
    }
  }
}

class ShootMessageListModel {
  bool? status;
  String? message;
  List<ShootMessage>? data;

  ShootMessageListModel({this.status, this.message, this.data});

  ShootMessageListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(ShootMessage.fromJson(v));
      });
    }
  }
}

class ShootMessage {
  int? id;
  int? requestId;
  int? senderId;
  String? messageText;
  String? attachments;
  String? createdAt;

  ShootMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    requestId = json['request_id'];
    senderId = json['sender_id'];
    messageText = json['message'];
    attachments = json['attachments'];
    createdAt = json['created_at'];
  }
}
