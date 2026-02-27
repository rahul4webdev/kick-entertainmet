import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/payment_service.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/cart/cart_model.dart';
import 'package:shortzz/model/payment/payment_model.dart';
import 'package:shortzz/screen/cart_screen/cart_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    final noteController = TextEditingController();
    final isInr = controller.hasInrItems;

    // For INR: fetch checkout summary from backend
    final checkoutSummary = Rx<CheckoutSummaryData?>(null);
    final isLoadingSummary = true.obs;
    final selectedPaymentMethod = 'prepaid'.obs;
    final selectedGateway = 'razorpay'.obs;
    final codAvailable = false.obs;

    if (isInr) {
      PaymentService.instance.getCheckoutSummary().then((response) {
        if (response.status == true && response.data != null) {
          checkoutSummary.value = response.data;
          codAvailable.value = response.data!.codAvailable ?? false;
        }
        isLoadingSummary.value = false;
      }).catchError((_) {
        isLoadingSummary.value = false;
      });
    } else {
      isLoadingSummary.value = false;
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(
          image: AssetRes.icBackArrow_1,
          height: 25,
          width: 25,
          padding: EdgeInsets.zero,
        ),
        title: Text(
          LKey.checkout,
          style: TextStyleCustom.unboundedMedium500(
              fontSize: 18, color: textDarkGrey(context)),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (isLoadingSummary.value) return const LoaderWidget();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Text(
                LKey.orderSummary,
                style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context), fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildOrderSummary(
                  context, controller, checkoutSummary.value, isInr),

              const SizedBox(height: 24),

              // Payment Method (only for INR)
              if (isInr) ...[
                Text(
                  'Payment Method',
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 16),
                ),
                const SizedBox(height: 10),
                Obx(() => Column(
                      children: [
                        _PaymentMethodTile(
                          label: 'Pay Online',
                          subtitle: 'UPI, Cards, Netbanking, Wallets',
                          icon: Icons.payment_outlined,
                          isSelected:
                              selectedPaymentMethod.value == 'prepaid',
                          onTap: () =>
                              selectedPaymentMethod.value = 'prepaid',
                          context: context,
                        ),
                        const SizedBox(height: 8),
                        if (codAvailable.value)
                          _PaymentMethodTile(
                            label: 'Cash on Delivery',
                            subtitle: 'Pay when you receive the order',
                            icon: Icons.local_shipping_outlined,
                            isSelected: selectedPaymentMethod.value == 'cod',
                            onTap: () =>
                                selectedPaymentMethod.value = 'cod',
                            context: context,
                          ),
                      ],
                    )),

                // Gateway selector (for prepaid)
                Obx(() {
                  if (selectedPaymentMethod.value != 'prepaid') {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Gateway',
                          style: TextStyleCustom.outFitMedium500(
                              color: textDarkGrey(context), fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _GatewayChip(
                              label: 'Razorpay',
                              isSelected:
                                  selectedGateway.value == 'razorpay',
                              onTap: () =>
                                  selectedGateway.value = 'razorpay',
                              context: context,
                            ),
                            _GatewayChip(
                              label: 'Cashfree',
                              isSelected:
                                  selectedGateway.value == 'cashfree',
                              onTap: () =>
                                  selectedGateway.value = 'cashfree',
                              context: context,
                            ),
                            _GatewayChip(
                              label: 'PhonePe',
                              isSelected:
                                  selectedGateway.value == 'phonepe',
                              onTap: () =>
                                  selectedGateway.value = 'phonepe',
                              context: context,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],

              // Shipping Address
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LKey.shippingAddress,
                    style: TextStyleCustom.outFitMedium500(
                        color: textDarkGrey(context), fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () =>
                        _showAddAddressSheet(context, controller),
                    child: Text(
                      '+ ${LKey.addAddress}',
                      style: TextStyleCustom.outFitMedium500(
                          color: themeAccentSolid(context), fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(() {
                if (controller.isLoadingAddresses.value) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: LoaderWidget(),
                  );
                }
                if (controller.addresses.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: ShapeDecoration(
                      color: bgLightGrey(context),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 14, cornerSmoothing: 1),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.location_off_outlined,
                              size: 30, color: textLightGrey(context)),
                          const SizedBox(height: 8),
                          Text(
                            LKey.noAddresses,
                            style: TextStyleCustom.outFitRegular400(
                                color: textLightGrey(context), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: controller.addresses
                      .map((addr) => _AddressCard(
                            address: addr,
                            controller: controller,
                          ))
                      .toList(),
                );
              }),

              const SizedBox(height: 24),

              // Order note
              Text(
                LKey.orderNote,
                style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: ShapeDecoration(
                  color: bgLightGrey(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 12, cornerSmoothing: 1),
                  ),
                ),
                child: TextField(
                  controller: noteController,
                  maxLines: 3,
                  style: TextStyleCustom.outFitRegular400(
                      color: textDarkGrey(context), fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                    hintText: LKey.orderNote,
                    hintStyle: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context), fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            if (controller.isCheckingOut.value) {
              return const LoaderWidget();
            }
            final totalDisplay = isInr
                ? '₹${checkoutSummary.value?.grandTotalRupees?.toStringAsFixed(2) ?? controller.totalRupees.toStringAsFixed(2)}'
                : '${controller.totalCoins.value} ${LKey.coinsText}';

            return GestureDetector(
              onTap: () {
                final note = noteController.text.trim();
                if (isInr) {
                  _placeInrOrder(
                    controller: controller,
                    paymentMethod: selectedPaymentMethod.value,
                    gateway: selectedGateway.value,
                    note: note.isNotEmpty ? note : null,
                  );
                } else {
                  controller.placeOrder(
                      note: note.isNotEmpty ? note : null);
                }
              },
              child: Container(
                height: 50,
                decoration: ShapeDecoration(
                  color: themeAccentSolid(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 14, cornerSmoothing: 1),
                  ),
                ),
                child: Center(
                  child: Text(
                    isInr
                        ? (selectedPaymentMethod.value == 'cod'
                            ? 'Place Order - $totalDisplay'
                            : 'Pay $totalDisplay')
                        : '${LKey.checkout} - $totalDisplay',
                    style: TextStyleCustom.outFitMedium500(
                        color: whitePure(context), fontSize: 16),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartController controller,
      CheckoutSummaryData? summary, bool isInr) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      child: Obx(() => Column(
            children: [
              ...controller.cartItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.product?.name ?? ''} x${item.quantity}',
                                style: TextStyleCustom.outFitRegular400(
                                    color: textDarkGrey(context),
                                    fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.variant != null)
                                Text(
                                  [
                                    if (item.variant!.size != null)
                                      item.variant!.size,
                                    if (item.variant!.color != null)
                                      item.variant!.color,
                                  ].join(' / '),
                                  style: TextStyleCustom.outFitLight300(
                                      color: textLightGrey(context),
                                      fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          isInr
                              ? '₹${item.itemTotalRupees.toStringAsFixed(2)}'
                              : '${item.itemTotal}',
                          style: TextStyleCustom.outFitMedium500(
                              color: textDarkGrey(context), fontSize: 13),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 16),
              if (isInr && summary != null) ...[
                _SummaryRow('Subtotal',
                    '₹${summary.subtotalRupees?.toStringAsFixed(2) ?? '0.00'}',
                    context: context),
                _SummaryRow('Shipping',
                    summary.shippingPaise == 0
                        ? 'FREE'
                        : '₹${summary.shippingRupees?.toStringAsFixed(2) ?? '0.00'}',
                    context: context,
                    valueColor:
                        summary.shippingPaise == 0 ? Colors.green : null),
                _SummaryRow('GST',
                    '₹${summary.gstRupees?.toStringAsFixed(2) ?? '0.00'}',
                    context: context),
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 16),
                    ),
                    Text(
                      '₹${summary.grandTotalRupees?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyleCustom.unboundedSemiBold600(
                          fontSize: 18, color: themeAccentSolid(context)),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LKey.cartTotal,
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 15),
                    ),
                    Text(
                      isInr
                          ? '₹${controller.totalRupees.toStringAsFixed(2)}'
                          : '${controller.totalCoins.value} ${LKey.coinsText}',
                      style: TextStyleCustom.unboundedSemiBold600(
                          fontSize: 18, color: themeAccentSolid(context)),
                    ),
                  ],
                ),
              ],
            ],
          )),
    );
  }

  Future<void> _placeInrOrder({
    required CartController controller,
    required String paymentMethod,
    required String gateway,
    String? note,
  }) async {
    if (controller.selectedAddress.value == null) {
      BaseController.share.showSnackBar('Please select a shipping address');
      return;
    }

    controller.isCheckingOut.value = true;
    try {
      final response = await PaymentService.instance.initiateCheckout(
        addressId: controller.selectedAddress.value!.id!,
        paymentMethod: paymentMethod,
        gateway: paymentMethod == 'prepaid' ? gateway : null,
        note: note,
      );
      controller.isCheckingOut.value = false;

      if (response.status == true && response.data != null) {
        if (paymentMethod == 'cod') {
          // COD — order placed directly
          controller.cartItems.clear();
          controller.totalCoins.value = 0;
          Get.back();
          BaseController.share.showSnackBar(LKey.orderPlaced);
        } else {
          // Prepaid — open payment gateway
          _handlePaymentGateway(response.data!, controller);
        }
      } else {
        BaseController.share
            .showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      controller.isCheckingOut.value = false;
      BaseController.share.showSnackBar(LKey.somethingWentWrong);
    }
  }

  void _handlePaymentGateway(
      InitiateCheckoutData data, CartController controller) {
    // Payment gateway integration point
    // data.payment contains gateway-specific fields:
    // - razorpayKey, razorpayOrderId (for Razorpay)
    // - paymentSessionId (for Cashfree)
    // - redirectUrl (for PhonePe)
    // - transactionId (for all)
    //
    // After payment completion, call:
    // PaymentService.instance.verifyPayment(
    //   transactionId: data.payment!.transactionId!,
    //   gatewayResponse: <gateway response map>,
    // );

    // For now, show a dialog with payment info
    Get.dialog(
      AlertDialog(
        title: const Text('Payment Initiated'),
        content: Text(
          'Transaction ID: ${data.payment?.transactionId ?? 'N/A'}\n'
          'Gateway: ${data.payment?.gateway ?? 'N/A'}\n'
          'Amount: ₹${(data.payment?.amountPaise ?? 0) / 100.0}\n\n'
          'Payment gateway SDK integration will handle the actual payment flow.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              controller.cartItems.clear();
              controller.totalCoins.value = 0;
              Get.back();
              BaseController.share.showSnackBar(LKey.orderPlaced);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddAddressSheet(
      BuildContext context, CartController controller) {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final line1C = TextEditingController();
    final line2C = TextEditingController();
    final cityC = TextEditingController();
    final stateC = TextEditingController();
    final zipC = TextEditingController();
    final countryC = TextEditingController(text: 'India');
    final isDefault = false.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textLightGrey(context).withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LKey.addAddress,
                style: TextStyleCustom.unboundedMedium500(
                    fontSize: 18, color: textDarkGrey(context)),
              ),
              const SizedBox(height: 16),
              _AddressField(
                  controller: nameC,
                  label: LKey.recipientName,
                  context: context),
              _AddressField(
                  controller: phoneC,
                  label: LKey.phoneNumber,
                  context: context),
              _AddressField(
                  controller: line1C,
                  label: LKey.addressLine1,
                  context: context),
              _AddressField(
                  controller: line2C,
                  label: LKey.addressLine2,
                  context: context),
              Row(
                children: [
                  Expanded(
                      child: _AddressField(
                          controller: cityC,
                          label: LKey.city,
                          context: context)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _AddressField(
                          controller: stateC,
                          label: LKey.stateProvince,
                          context: context)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: _AddressField(
                          controller: zipC,
                          label: LKey.zipCode,
                          context: context)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _AddressField(
                          controller: countryC,
                          label: LKey.country,
                          context: context)),
                ],
              ),
              Obx(() => CheckboxListTile(
                    value: isDefault.value,
                    onChanged: (v) => isDefault.value = v ?? false,
                    title: Text(
                      LKey.setAsDefault,
                      style: TextStyleCustom.outFitRegular400(
                          color: textDarkGrey(context), fontSize: 14),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  if (nameC.text.trim().isEmpty ||
                      line1C.text.trim().isEmpty ||
                      cityC.text.trim().isEmpty ||
                      zipC.text.trim().isEmpty) {
                    Get.snackbar(
                        LKey.error, 'Please fill in required fields',
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  controller.addNewAddress(
                    name: nameC.text.trim(),
                    phone: phoneC.text.trim(),
                    addressLine1: line1C.text.trim(),
                    addressLine2: line2C.text.trim(),
                    city: cityC.text.trim(),
                    state: stateC.text.trim(),
                    zipCode: zipC.text.trim(),
                    country: countryC.text.trim(),
                    isDefault: isDefault.value,
                  );
                },
                child: Container(
                  height: 48,
                  decoration: ShapeDecoration(
                    color: themeAccentSolid(context),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 14, cornerSmoothing: 1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      LKey.addAddress,
                      style: TextStyleCustom.outFitMedium500(
                          color: whitePure(context), fontSize: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ─── Helper Widgets ─────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final BuildContext context;

  const _SummaryRow(this.label, this.value,
      {required this.context, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context), fontSize: 13)),
          Text(value,
              style: TextStyleCustom.outFitMedium500(
                  color: valueColor ?? textDarkGrey(context), fontSize: 13)),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final BuildContext context;

  const _PaymentMethodTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color: isSelected
              ? themeAccentSolid(context).withValues(alpha: .08)
              : bgLightGrey(context),
          shape: SmoothRectangleBorder(
            side: isSelected
                ? BorderSide(
                    color: themeAccentSolid(context), width: 1.5)
                : BorderSide.none,
            borderRadius:
                SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? themeAccentSolid(context)
                  : textLightGrey(context),
              size: 20,
            ),
            const SizedBox(width: 12),
            Icon(icon,
                size: 22,
                color: isSelected
                    ? themeAccentSolid(context)
                    : textLightGrey(context)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyleCustom.outFitMedium500(
                        color: textDarkGrey(context), fontSize: 14)),
                Text(subtitle,
                    style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GatewayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final BuildContext context;

  const _GatewayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: ShapeDecoration(
          color: isSelected
              ? themeAccentSolid(context).withValues(alpha: .1)
              : bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
            side: BorderSide(
              color: isSelected
                  ? themeAccentSolid(context)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyleCustom.outFitMedium500(
            color: isSelected
                ? themeAccentSolid(context)
                : textLightGrey(context),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final BuildContext context;

  const _AddressField({
    required this.controller,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
          ),
        ),
        child: TextField(
          controller: controller,
          style: TextStyleCustom.outFitRegular400(
              color: textDarkGrey(context), fontSize: 14),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            hintText: label,
            hintStyle: TextStyleCustom.outFitLight300(
                color: textLightGrey(context), fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final ShippingAddress address;
  final CartController controller;

  const _AddressCard({required this.address, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedAddress.value?.id == address.id;
      return GestureDetector(
        onTap: () => controller.selectedAddress.value = address,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: ShapeDecoration(
            color: isSelected
                ? themeAccentSolid(context).withValues(alpha: .08)
                : bgLightGrey(context),
            shape: SmoothRectangleBorder(
              side: isSelected
                  ? BorderSide(
                      color: themeAccentSolid(context), width: 1.5)
                  : BorderSide.none,
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? themeAccentSolid(context)
                    : textLightGrey(context),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.name ?? '',
                          style: TextStyleCustom.outFitMedium500(
                              color: textDarkGrey(context), fontSize: 14),
                        ),
                        if (address.isDefault == true) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: ShapeDecoration(
                              color: themeAccentSolid(context)
                                  .withValues(alpha: .1),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                    cornerRadius: 4,
                                    cornerSmoothing: 1),
                              ),
                            ),
                            child: Text(
                              LKey.defaultAddress,
                              style: TextStyleCustom.outFitMedium500(
                                  color: themeAccentSolid(context),
                                  fontSize: 9),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.fullAddress,
                      style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      title: Text(LKey.deleteAddressTitle),
                      content: Text(LKey.deleteAddressDesc),
                      actions: [
                        TextButton(
                            onPressed: () => Get.back(),
                            child: Text(LKey.cancel)),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            controller.deleteAddress(address.id!);
                          },
                          child: Text(LKey.delete,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Icon(Icons.delete_outline,
                    size: 18,
                    color: Colors.red.withValues(alpha: .6)),
              ),
            ],
          ),
        ),
      );
    });
  }
}
