import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/cart/cart_model.dart';
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
      body: SingleChildScrollView(
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
            Obx(() => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    color: bgLightGrey(context),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 14, cornerSmoothing: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      ...controller.cartItems.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product?.name ?? ''} x${item.quantity}',
                                    style: TextStyleCustom.outFitRegular400(
                                        color: textDarkGrey(context),
                                        fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${item.itemTotal}',
                                  style: TextStyleCustom.outFitMedium500(
                                      color: textDarkGrey(context),
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LKey.cartTotal,
                            style: TextStyleCustom.outFitMedium500(
                                color: textDarkGrey(context), fontSize: 15),
                          ),
                          Row(
                            children: [
                              Icon(Icons.monetization_on_outlined,
                                  size: 18, color: themeAccentSolid(context)),
                              const SizedBox(width: 4),
                              Text(
                                '${controller.totalCoins.value}',
                                style: TextStyleCustom.unboundedSemiBold600(
                                    fontSize: 18,
                                    color: themeAccentSolid(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 24),

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
                  onTap: () => _showAddAddressSheet(context, controller),
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() => controller.isCheckingOut.value
              ? const LoaderWidget()
              : GestureDetector(
                  onTap: () {
                    final note = noteController.text.trim();
                    controller.placeOrder(note: note.isNotEmpty ? note : null);
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
                      child: Obx(() => Text(
                            '${LKey.checkout} - ${controller.totalCoins.value} ${LKey.coinsText}',
                            style: TextStyleCustom.outFitMedium500(
                                color: whitePure(context), fontSize: 16),
                          )),
                    ),
                  ),
                )),
        ),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    Get.snackbar(LKey.error, 'Please fill in required fields',
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
                                    cornerRadius: 4, cornerSmoothing: 1),
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
