import 'dart:io';

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/payment_service.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/model/payment/payment_model.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

// ─── Controller ──────────────────────────────────────────────

class _ReturnRequestController extends GetxController {
  final int orderId;
  final int orderItemId;

  _ReturnRequestController({required this.orderId, required this.orderItemId});

  final baseController = BaseController.share;

  // ─── Tab
  final selectedTab = 0.obs;

  // ─── New Request Form
  final selectedReason = ''.obs;
  final descriptionController = TextEditingController();
  final photos = <XFile>[].obs;
  final isSubmitting = false.obs;

  // ─── My Returns
  final returns = <ProductReturnItem>[].obs;
  final isLoadingReturns = false.obs;

  static const List<Map<String, String>> reasons = [
    {'key': 'defective', 'label': 'Defective Product'},
    {'key': 'wrong_item', 'label': 'Wrong Item Received'},
    {'key': 'not_as_described', 'label': 'Not As Described'},
    {'key': 'size_issue', 'label': 'Size Issue'},
    {'key': 'change_of_mind', 'label': 'Change of Mind'},
    {'key': 'damaged_in_transit', 'label': 'Damaged in Transit'},
    {'key': 'other', 'label': 'Other'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchReturns();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchReturns() async {
    try {
      isLoadingReturns.value = true;
      final result = await PaymentService.instance.fetchReturns();
      if (result.status == true && result.data != null) {
        returns.assignAll(result.data!);
      }
    } catch (e) {
      debugPrint('fetchReturns error: $e');
    } finally {
      isLoadingReturns.value = false;
    }
  }

  Future<void> pickPhotos() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(imageQuality: 75);
      if (picked.isNotEmpty) {
        photos.addAll(picked);
      }
    } catch (e) {
      debugPrint('pickPhotos error: $e');
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < photos.length) {
      photos.removeAt(index);
    }
  }

  Future<void> submitReturn() async {
    if (selectedReason.value.isEmpty) {
      baseController.showSnackBar('Please select a reason');
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      baseController.showSnackBar('Please provide a description');
      return;
    }

    try {
      isSubmitting.value = true;
      baseController.showLoader();

      final result = await PaymentService.instance.requestReturn(
        orderId: orderId,
        orderItemId: orderItemId,
        reason: selectedReason.value,
        description: descriptionController.text.trim(),
        photos: photos.isNotEmpty ? photos.toList() : null,
      );

      baseController.stopLoader();

      if (result.status == true) {
        baseController.showSnackBar('Return request submitted successfully');
        // Reset form
        selectedReason.value = '';
        descriptionController.clear();
        photos.clear();
        // Switch to My Returns tab and refresh
        selectedTab.value = 1;
        fetchReturns();
      } else {
        baseController.showSnackBar(result.message ?? 'Failed to submit return');
      }
    } catch (e) {
      baseController.stopLoader();
      baseController.showSnackBar('Something went wrong');
      debugPrint('submitReturn error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Color statusColor(int? status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.indigo;
      case 5:
        return Colors.teal;
      case 6:
        return Colors.green.shade700;
      case 7:
        return Colors.red.shade700;
      case 8:
        return Colors.purple;
      case 9:
        return Colors.green.shade800;
      default:
        return Colors.grey;
    }
  }
}

// ─── Screen ──────────────────────────────────────────────────

class ReturnRequestScreen extends StatelessWidget {
  final int orderId;
  final int orderItemId;

  const ReturnRequestScreen({
    super.key,
    required this.orderId,
    required this.orderItemId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      _ReturnRequestController(orderId: orderId, orderItemId: orderItemId),
    );

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(
          image: AssetRes.icBackArrow_1,
          height: 25,
          width: 25,
          padding: EdgeInsets.zero,
        ),
        title: Text(
          'Return Request',
          style: TextStyleCustom.unboundedMedium500(
              fontSize: 18, color: textDarkGrey(context)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─── Tab Bar
          Obx(() => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: ShapeDecoration(
                  color: bgLightGrey(context),
                  shape: SmoothRectangleBorder(
                    borderRadius:
                        SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
                  ),
                ),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'New Request',
                      isSelected: controller.selectedTab.value == 0,
                      onTap: () => controller.selectedTab.value = 0,
                    ),
                    _TabButton(
                      label: 'My Returns',
                      isSelected: controller.selectedTab.value == 1,
                      onTap: () => controller.selectedTab.value = 1,
                    ),
                  ],
                ),
              )),

          // ─── Tab Content
          Expanded(
            child: Obx(() => controller.selectedTab.value == 0
                ? _NewRequestTab(controller: controller)
                : _MyReturnsTab(controller: controller)),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Button ──────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: ShapeDecoration(
            color: isSelected ? themeAccentSolid(context) : Colors.transparent,
            shape: SmoothRectangleBorder(
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 11, cornerSmoothing: 1),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyleCustom.outFitMedium500(
              fontSize: 13,
              color: isSelected ? Colors.white : textLightGrey(context),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── New Request Tab ─────────────────────────────────────────

class _NewRequestTab extends StatelessWidget {
  final _ReturnRequestController controller;
  const _NewRequestTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: ShapeDecoration(
              color: Colors.blue.withValues(alpha: .06),
              shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                side: BorderSide(
                    color: Colors.blue.withValues(alpha: .2), width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Please select a reason and describe the issue with your order to submit a return request.',
                    style: TextStyleCustom.outFitRegular400(
                        color: Colors.blue.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Reason Selector
          Text(
            'Reason for Return *',
            style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _ReturnRequestController.reasons.map((reason) {
                  final isSelected =
                      controller.selectedReason.value == reason['key'];
                  return GestureDetector(
                    onTap: () =>
                        controller.selectedReason.value = reason['key']!,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: ShapeDecoration(
                        color: isSelected
                            ? themeAccentSolid(context).withValues(alpha: .1)
                            : bgLightGrey(context),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 10, cornerSmoothing: 1),
                          side: BorderSide(
                            color: isSelected
                                ? themeAccentSolid(context)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        reason['label']!,
                        style: TextStyleCustom.outFitMedium500(
                          color: isSelected
                              ? themeAccentSolid(context)
                              : textLightGrey(context),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

          const SizedBox(height: 20),

          // ─── Description
          Text(
            'Description *',
            style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: ShapeDecoration(
              color: bgLightGrey(context),
              shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
              ),
            ),
            child: TextField(
              controller: controller.descriptionController,
              maxLines: 4,
              style: TextStyleCustom.outFitRegular400(
                  color: textDarkGrey(context), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Describe the issue in detail...',
                hintStyle: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context), fontSize: 13),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ─── Photos
          Text(
            'Upload Photos',
            style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Add photos of the product to support your return request',
            style: TextStyleCustom.outFitLight300(
                color: textLightGrey(context), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Obx(() => Column(
                children: [
                  if (controller.photos.isNotEmpty)
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipSmoothRect(
                                radius: SmoothBorderRadius(
                                    cornerRadius: 10, cornerSmoothing: 1),
                                child: Image.file(
                                  File(controller.photos[index].path),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => controller.removePhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  if (controller.photos.isNotEmpty)
                    const SizedBox(height: 10),
                  GestureDetector(
                    onTap: controller.pickPhotos,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: ShapeDecoration(
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 10, cornerSmoothing: 1),
                          side: BorderSide(
                            color:
                                textLightGrey(context).withValues(alpha: .4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 20, color: textLightGrey(context)),
                          const SizedBox(width: 8),
                          Text(
                            'Add Photos',
                            style: TextStyleCustom.outFitMedium500(
                                color: textLightGrey(context), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),

          const SizedBox(height: 30),

          // ─── Submit Button
          GestureDetector(
            onTap: controller.submitReturn,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: ShapeDecoration(
                color: themeAccentSolid(context),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                ),
              ),
              child: Text(
                'Submit Return Request',
                textAlign: TextAlign.center,
                style: TextStyleCustom.outFitMedium500(
                    color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── My Returns Tab ──────────────────────────────────────────

class _MyReturnsTab extends StatelessWidget {
  final _ReturnRequestController controller;
  const _MyReturnsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingReturns.value && controller.returns.isEmpty) {
        return const LoaderWidget();
      }

      if (controller.returns.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.assignment_return_outlined,
                  size: 48, color: textLightGrey(context).withValues(alpha: .4)),
              const SizedBox(height: 12),
              Text(
                'No return requests yet',
                style: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(context), fontSize: 14),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchReturns,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.returns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _ReturnCard(
              item: controller.returns[index],
              controller: controller,
            );
          },
        ),
      );
    });
  }
}

// ─── Return Card ─────────────────────────────────────────────

class _ReturnCard extends StatelessWidget {
  final ProductReturnItem item;
  final _ReturnRequestController controller;

  const _ReturnCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    if (item.createdAt != null) {
      try {
        dateStr =
            DateFormat('dd MMM yyyy').format(DateTime.parse(item.createdAt!));
      } catch (_) {}
    }

    final sColor = controller.statusColor(item.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order ID + Status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${item.orderId ?? '-'}',
                  style: TextStyleCustom.unboundedMedium500(
                      fontSize: 13, color: textDarkGrey(context)),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: ShapeDecoration(
                  color: sColor.withValues(alpha: .12),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 8, cornerSmoothing: 1),
                  ),
                ),
                child: Text(
                  item.statusLabel,
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 11, color: sColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Reason
          Row(
            children: [
              Icon(Icons.label_outline,
                  size: 16, color: textLightGrey(context)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.reasonLabel,
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 12, color: textDarkGrey(context)),
                ),
              ),
            ],
          ),

          // Description
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.description!,
              style: TextStyleCustom.outFitLight300(
                  fontSize: 12, color: textLightGrey(context)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Seller response (for rejected)
          if (item.sellerResponse != null &&
              item.sellerResponse!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: item.status == 2
                    ? Colors.red.withValues(alpha: .05)
                    : Colors.green.withValues(alpha: .05),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 8, cornerSmoothing: 1),
                ),
              ),
              child: Text(
                'Seller: ${item.sellerResponse}',
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 11,
                  color: item.status == 2
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Footer: Refund amount + date
          Row(
            children: [
              if (item.refundAmountPaise != null &&
                  item.refundAmountPaise! > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: ShapeDecoration(
                    color: Colors.green.withValues(alpha: .08),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 6, cornerSmoothing: 1),
                    ),
                  ),
                  child: Text(
                    '₹${item.refundAmountRupees.toStringAsFixed(item.refundAmountRupees.truncateToDouble() == item.refundAmountRupees ? 0 : 2)}',
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 12, color: Colors.green.shade700),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                dateStr,
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 11, color: textLightGrey(context)),
              ),
            ],
          ),

          // Pickup / Tracking info
          if (item.returnAwb != null && item.returnAwb!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 14, color: textLightGrey(context)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'AWB: ${item.returnAwb} ${item.returnCourier != null ? '(${item.returnCourier})' : ''}',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 11, color: textLightGrey(context)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
