import 'dart:convert';

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/common/service/api/payment_service.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/model/payment/payment_model.dart';
import 'package:shortzz/model/product/product_model.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

// ─── Controller ─────────────────────────────────────────────

class OrderTrackingController extends GetxController {
  final int orderId;
  OrderTrackingController({required this.orderId});

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  Rx<OrderTrackingData?> trackingData = Rx<OrderTrackingData?>(null);

  @override
  void onInit() {
    super.onInit();
    _fetchTracking();
  }

  Future<void> _fetchTracking() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final result =
          await PaymentService.instance.trackOrder(orderId: orderId);
      if (result.status == true && result.data != null) {
        trackingData.value = result.data;
      } else {
        hasError.value = true;
        errorMessage.value = result.message ?? 'Failed to load order tracking';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => _fetchTracking();
}

// ─── Screen ─────────────────────────────────────────────────

class OrderTrackingScreen extends StatelessWidget {
  final int orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(OrderTrackingController(orderId: orderId), tag: '$orderId');

    return Scaffold(
      backgroundColor: bgLightGrey(context),
      appBar: AppBar(
        backgroundColor: whitePure(context),
        elevation: 0.5,
        leading: CustomBackButton(
          image: AssetRes.icBackArrow_1,
          onTap: () => Get.back(),
        ),
        title: Obx(() {
          final oid = controller.trackingData.value?.order?.id ?? orderId;
          return Text(
            'Order #$oid',
            style: TextStyleCustom.unboundedSemiBold600(
              color: textDarkGrey(context),
              fontSize: 18,
            ),
          );
        }),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoaderWidget();
        }
        if (controller.hasError.value) {
          return _ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }
        final data = controller.trackingData.value;
        if (data == null) {
          return _ErrorView(
            message: 'No tracking data available',
            onRetry: controller.refresh,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: themeAccentSolid(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _StatusCard(order: data.order),
                const SizedBox(height: 16),
                _ItemsList(items: data.order?.items ?? []),
                const SizedBox(height: 16),
                _TimelineCard(
                  statusHistory: data.statusHistory ?? [],
                  currentStatus: data.order?.status ?? 0,
                ),
                const SizedBox(height: 16),
                if (_hasShippingInfo(data.order))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ShippingDetailsCard(order: data.order!),
                  ),
                _AddressCard(order: data.order),
                const SizedBox(height: 16),
                _PriceBreakdownCard(order: data.order),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  bool _hasShippingInfo(ProductOrder? order) {
    if (order == null) return false;
    return (order.courierName != null && order.courierName!.isNotEmpty) ||
        (order.awbCode != null && order.awbCode!.isNotEmpty) ||
        (order.estimatedDeliveryDate != null &&
            order.estimatedDeliveryDate!.isNotEmpty);
  }
}

// ─── Error View ─────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: textLightGrey(context)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: ShapeDecoration(
                  color: themeAccentSolid(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextStyleCustom.outFitMedium500(
                    color: whitePure(context),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status Card ────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final ProductOrder? order;

  const _StatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order?.status ?? 0;
    final label = order?.statusLabel ?? 'Unknown';
    final color = _statusColor(status);
    final icon = _statusIcon(status);
    final date = order?.createdAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: whitePure(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: ShapeDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: TextStyleCustom.outFitRegular400(
                        color: textLightGrey(context),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyleCustom.unboundedSemiBold600(
                        color: color,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 8,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyleCustom.outFitMedium500(
                    color: color,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (date != null && date.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: bgLightGrey(context), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: textLightGrey(context)),
                const SizedBox(width: 6),
                Text(
                  'Ordered on ${_formatDate(date)}',
                  style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (order?.paymentMethod != null)
                  Row(
                    children: [
                      Icon(Icons.payment_outlined,
                          size: 14, color: textLightGrey(context)),
                      const SizedBox(width: 4),
                      Text(
                        (order!.paymentMethod ?? '').toUpperCase(),
                        style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
          if (order?.invoiceNumber != null &&
              order!.invoiceNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 14, color: textLightGrey(context)),
                const SizedBox(width: 6),
                Text(
                  'Invoice: ${order!.invoiceNumber}',
                  style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.indigo;
      case 3:
        return const Color(0xFF2E7D32);
      case 4:
        return Colors.red;
      case 5:
        return Colors.deepOrange;
      case 6:
      case 7:
        return Colors.amber.shade800;
      case 8:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.hourglass_empty;
      case 1:
        return Icons.check_circle_outline;
      case 2:
        return Icons.local_shipping_outlined;
      case 3:
        return Icons.inventory_2_outlined;
      case 4:
        return Icons.cancel_outlined;
      case 5:
        return Icons.currency_exchange;
      case 6:
        return Icons.assignment_return_outlined;
      case 7:
        return Icons.local_shipping_outlined;
      case 8:
        return Icons.assignment_turned_in_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

// ─── Items List ─────────────────────────────────────────────

class _ItemsList extends StatelessWidget {
  final List<OrderItem> items;

  const _ItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: whitePure(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items (${items.length})',
            style: TextStyleCustom.unboundedMedium500(
              color: textDarkGrey(context),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: bgLightGrey(context), height: 1),
            ),
            itemBuilder: (context, index) =>
                _OrderItemTile(item: items[index]),
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final imageUrl =
        (product?.imageUrls != null && product!.imageUrls!.isNotEmpty)
            ? product.imageUrls!.first
            : null;
    final price = (item.pricePaise ?? 0) / 100.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        Container(
          width: 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: bgLightGrey(context),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_outlined,
                    color: textLightGrey(context),
                    size: 24,
                  ),
                )
              : Icon(
                  Icons.image_outlined,
                  color: textLightGrey(context),
                  size: 24,
                ),
        ),
        const SizedBox(width: 12),
        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product?.name ?? 'Product',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context),
                  fontSize: 14,
                ),
              ),
              if (item.variantLabel != null &&
                  item.variantLabel!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  item.variantLabel!,
                  style: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(context),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Qty: ${item.quantity ?? 1}',
                    style: TextStyleCustom.outFitRegular400(
                      color: textLightGrey(context),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatRupees(price),
                    style: TextStyleCustom.unboundedMedium500(
                      color: textDarkGrey(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Timeline Card ──────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  final List<OrderStatusEntry> statusHistory;
  final int currentStatus;

  const _TimelineCard({
    required this.statusHistory,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (statusHistory.isEmpty) return const SizedBox.shrink();

    // Default milestone statuses for a normal order flow
    final milestones = <_TimelineMilestone>[
      _TimelineMilestone(status: 0, label: 'Order Placed'),
      _TimelineMilestone(status: 1, label: 'Confirmed'),
      _TimelineMilestone(status: 2, label: 'Shipped'),
      _TimelineMilestone(status: 3, label: 'Delivered'),
    ];

    // Build timeline entries from actual status history
    final historyMap = <int, OrderStatusEntry>{};
    for (final entry in statusHistory) {
      if (entry.status != null) {
        historyMap[entry.status!] = entry;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: whitePure(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Timeline',
            style: TextStyleCustom.unboundedMedium500(
              color: textDarkGrey(context),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          // If order is cancelled/refunded/returned, show actual history
          if (currentStatus >= 4)
            _buildActualHistory(context, statusHistory)
          else
            _buildMilestoneTimeline(context, milestones, historyMap),
        ],
      ),
    );
  }

  Widget _buildMilestoneTimeline(
    BuildContext context,
    List<_TimelineMilestone> milestones,
    Map<int, OrderStatusEntry> historyMap,
  ) {
    return Column(
      children: List.generate(milestones.length, (index) {
        final milestone = milestones[index];
        final entry = historyMap[milestone.status];
        final isCompleted = milestone.status <= currentStatus;
        final isCurrent = milestone.status == currentStatus;
        final isLast = index == milestones.length - 1;

        return _TimelineEntryWidget(
          title: entry?.title ?? milestone.label,
          subtitle: entry?.description,
          timestamp: entry?.createdAt,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLast: isLast,
        );
      }),
    );
  }

  Widget _buildActualHistory(
    BuildContext context,
    List<OrderStatusEntry> history,
  ) {
    return Column(
      children: List.generate(history.length, (index) {
        final entry = history[index];
        final isLast = index == history.length - 1;
        final isFirst = index == 0;

        return _TimelineEntryWidget(
          title: entry.title ?? _statusLabel(entry.status ?? 0),
          subtitle: entry.description,
          timestamp: entry.createdAt,
          isCompleted: !isFirst,
          isCurrent: isFirst,
          isLast: isLast,
          overrideColor:
              _isNegativeStatus(entry.status ?? 0) ? Colors.red : null,
        );
      }),
    );
  }

  bool _isNegativeStatus(int status) {
    return status == 4 || status == 5 || status == 6;
  }

  String _statusLabel(int status) {
    switch (status) {
      case 0:
        return 'Order Placed';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Shipped';
      case 3:
        return 'Delivered';
      case 4:
        return 'Cancelled';
      case 5:
        return 'Refunded';
      case 6:
        return 'Return Requested';
      case 7:
        return 'Return In Progress';
      case 8:
        return 'Return Completed';
      default:
        return 'Unknown';
    }
  }
}

class _TimelineMilestone {
  final int status;
  final String label;
  _TimelineMilestone({required this.status, required this.label});
}

class _TimelineEntryWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? timestamp;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final Color? overrideColor;

  const _TimelineEntryWidget({
    required this.title,
    this.subtitle,
    this.timestamp,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor =
        overrideColor ?? const Color(0xFF2E7D32); // Green for completed
    final inactiveColor = textLightGrey(context).withValues(alpha: 0.4);
    final dotColor =
        isCurrent ? activeColor : (isCompleted ? activeColor : inactiveColor);
    final lineColor = isCompleted ? activeColor : inactiveColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dots and line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 2),
                // Dot
                Container(
                  width: isCurrent ? 16 : 12,
                  height: isCurrent ? 16 : 12,
                  decoration: BoxDecoration(
                    color: (isCompleted || isCurrent)
                        ? dotColor
                        : Colors.transparent,
                    border: Border.all(
                      color: dotColor,
                      width: isCurrent ? 3 : 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted && !isCurrent
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: isCurrent
                        ? TextStyleCustom.outFitMedium500(
                            color: overrideColor ?? textDarkGrey(context),
                            fontSize: 14,
                          )
                        : TextStyleCustom.outFitRegular400(
                            color: isCompleted
                                ? textDarkGrey(context)
                                : textLightGrey(context),
                            fontSize: 14,
                          ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (timestamp != null && timestamp!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      _formatDateTime(timestamp!),
                      style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}

// ─── Shipping Details Card ──────────────────────────────────

class _ShippingDetailsCard extends StatelessWidget {
  final ProductOrder order;

  const _ShippingDetailsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: whitePure(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_outlined,
                  size: 18, color: themeAccentSolid(context)),
              const SizedBox(width: 8),
              Text(
                'Shipping Details',
                style: TextStyleCustom.unboundedMedium500(
                  color: textDarkGrey(context),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (order.courierName != null && order.courierName!.isNotEmpty)
            _infoRow(context, 'Courier', order.courierName!),
          if (order.awbCode != null && order.awbCode!.isNotEmpty)
            _infoRow(context, 'AWB Code', order.awbCode!),
          if (order.trackingNumber != null && order.trackingNumber!.isNotEmpty)
            _infoRow(context, 'Tracking No.', order.trackingNumber!),
          if (order.estimatedDeliveryDate != null &&
              order.estimatedDeliveryDate!.isNotEmpty)
            _infoRow(context, 'Est. Delivery',
                _formatDate(order.estimatedDeliveryDate!)),
          if (order.deliveredAt != null && order.deliveredAt!.isNotEmpty)
            _infoRow(
                context, 'Delivered On', _formatDate(order.deliveredAt!)),
          if (order.shippingMethod != null && order.shippingMethod!.isNotEmpty)
            _infoRow(
                context, 'Method', order.shippingMethod!.capitalizeFirst ?? ''),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyleCustom.outFitRegular400(
                color: textLightGrey(context),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Address Card ───────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final ProductOrder? order;

  const _AddressCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final addrStr = order?.shippingAddress;
    if (addrStr == null || addrStr.isEmpty) return const SizedBox.shrink();

    // Try to parse JSON address, otherwise show as plain text
    String displayAddress;
    try {
      final parsed = json.decode(addrStr);
      if (parsed is Map<String, dynamic>) {
        final parts = <String>[];
        if (parsed['name'] != null) {
          parts.add(parsed['name'].toString());
        }
        if (parsed['address_line_1'] != null) {
          parts.add(parsed['address_line_1'].toString());
        }
        if (parsed['address_line_2'] != null &&
            parsed['address_line_2'].toString().isNotEmpty) {
          parts.add(parsed['address_line_2'].toString());
        }
        if (parsed['city'] != null) {
          parts.add(parsed['city'].toString());
        }
        if (parsed['state'] != null) {
          parts.add(parsed['state'].toString());
        }
        if (parsed['zip_code'] != null) {
          parts.add(parsed['zip_code'].toString());
        }
        if (parsed['phone'] != null) {
          parts.add('Phone: ${parsed['phone']}');
        }
        displayAddress = parts.join('\n');
      } else {
        displayAddress = addrStr;
      }
    } catch (_) {
      displayAddress = addrStr;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: whitePure(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 18, color: themeAccentSolid(context)),
              const SizedBox(width: 8),
              Text(
                'Delivery Address',
                style: TextStyleCustom.unboundedMedium500(
                  color: textDarkGrey(context),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayAddress,
            style: TextStyleCustom.outFitRegular400(
              color: textDarkGrey(context),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Price Breakdown Card ───────────────────────────────────

class _PriceBreakdownCard extends StatelessWidget {
  final ProductOrder? order;

  const _PriceBreakdownCard({required this.order});

  @override
  Widget build(BuildContext context) {
    if (order == null) return const SizedBox.shrink();

    final totalPaise = order!.totalAmountPaise ?? 0;
    final shippingPaise = order!.shippingChargePaise ?? 0;
    final gstPaise = order!.gstAmountPaise ?? 0;

    // Calculate subtotal = total - shipping - gst
    final subtotalPaise = totalPaise - shippingPaise - gstPaise;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: whitePure(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: TextStyleCustom.unboundedMedium500(
              color: textDarkGrey(context),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          _priceRow(
              context, 'Subtotal', _formatRupees(subtotalPaise / 100.0)),
          if (shippingPaise > 0)
            _priceRow(
                context, 'Shipping', _formatRupees(shippingPaise / 100.0)),
          if (shippingPaise == 0)
            _priceRow(context, 'Shipping', 'FREE',
                valueColor: const Color(0xFF2E7D32)),
          if (gstPaise > 0)
            _priceRow(context, 'GST', _formatRupees(gstPaise / 100.0)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: bgLightGrey(context), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyleCustom.unboundedSemiBold600(
                  color: textDarkGrey(context),
                  fontSize: 16,
                ),
              ),
              Text(
                _formatRupees(totalPaise / 100.0),
                style: TextStyleCustom.unboundedSemiBold600(
                  color: textDarkGrey(context),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyleCustom.outFitRegular400(
              color: textLightGrey(context),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyleCustom.outFitMedium500(
              color: valueColor ?? textDarkGrey(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────

String _formatRupees(double amount) {
  if (amount == amount.truncateToDouble()) {
    return '\u20B9${amount.toInt()}';
  }
  return '\u20B9${amount.toStringAsFixed(2)}';
}

String _formatDate(String dateStr) {
  try {
    final dt = DateTime.parse(dateStr);
    return DateFormat('dd MMM yyyy').format(dt);
  } catch (_) {
    return dateStr;
  }
}
