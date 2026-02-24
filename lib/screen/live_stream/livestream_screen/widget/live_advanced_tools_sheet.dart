import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

/// Advanced shopping tools sheet for live stream hosts
class LiveAdvancedToolsSheet extends StatefulWidget {
  final LivestreamScreenController controller;

  const LiveAdvancedToolsSheet({super.key, required this.controller});

  @override
  State<LiveAdvancedToolsSheet> createState() => _LiveAdvancedToolsSheetState();
}

class _LiveAdvancedToolsSheetState extends State<LiveAdvancedToolsSheet> {
  int _selectedTool = 0; // 0=flash sale, 1=giveaway, 2=promo banner

  // Flash sale fields
  int _flashDuration = 300; // 5 minutes default
  int _flashDiscount = 20;

  // Giveaway fields
  final _giveawayController = TextEditingController();

  // Promo banner fields
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _giveawayController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.55,
      decoration: ShapeDecoration(
        color: scaffoldBackgroundColor(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.rocket_launch, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Shopping Tools',
                  style: TextStyleCustom.unboundedMedium500(
                      fontSize: 18, color: textDarkGrey(context)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close,
                      color: textLightGrey(context), size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tool selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _ToolTab(
                  icon: Icons.flash_on,
                  label: 'Flash Sale',
                  isSelected: _selectedTool == 0,
                  onTap: () => setState(() => _selectedTool = 0),
                  color: ColorRes.likeRed,
                ),
                const SizedBox(width: 8),
                _ToolTab(
                  icon: Icons.card_giftcard,
                  label: 'Giveaway',
                  isSelected: _selectedTool == 1,
                  onTap: () => setState(() => _selectedTool = 1),
                  color: const Color(0xFF6C3CE0),
                ),
                const SizedBox(width: 8),
                _ToolTab(
                  icon: Icons.campaign,
                  label: 'Banner',
                  isSelected: _selectedTool == 2,
                  onTap: () => setState(() => _selectedTool = 2),
                  color: ColorRes.themeAccentSolid,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: switch (_selectedTool) {
                0 => _buildFlashSale(context),
                1 => _buildGiveaway(context),
                2 => _buildPromoBanner(context),
                _ => const SizedBox(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSale(BuildContext context) {
    final products = widget.controller.liveShoppingProducts;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Product',
              style: TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context), fontSize: 14)),
          const SizedBox(height: 8),
          if (products.isEmpty)
            Text('Add products to live first',
                style: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(context), fontSize: 13))
          else
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final p = products[i];
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: bgLightGrey(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          p.product?.name ?? '',
                          style: TextStyleCustom.outFitRegular400(
                              color: textDarkGrey(context), fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Text('Discount %',
              style: TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context), fontSize: 14)),
          Slider(
            value: _flashDiscount.toDouble(),
            min: 5,
            max: 80,
            divisions: 15,
            label: '$_flashDiscount%',
            onChanged: (v) => setState(() => _flashDiscount = v.round()),
          ),
          Text('Duration',
              style: TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context), fontSize: 14)),
          Wrap(
            spacing: 8,
            children: [60, 180, 300, 600].map((d) {
              final m = d ~/ 60;
              return ChoiceChip(
                label: Text('${m}m'),
                selected: _flashDuration == d,
                onSelected: (_) => setState(() => _flashDuration = d),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (widget.controller.flashSaleProduct.value != null) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.controller.stopFlashSale,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorRes.likeRed),
                  child: const Text('Stop Flash Sale',
                      style: TextStyle(color: Colors.white)),
                ),
              );
            }
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: products.isEmpty
                    ? null
                    : () {
                        widget.controller.startFlashSale(
                          product: products.first,
                          durationSeconds: _flashDuration,
                          discountPercent: _flashDiscount,
                        );
                        Get.back();
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorRes.likeRed),
                child: const Text('Start Flash Sale',
                    style: TextStyle(color: Colors.white)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGiveaway(BuildContext context) {
    return Obx(() {
      final isActive = widget.controller.isGiveawayActive.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prize Description',
              style: TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context), fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _giveawayController,
            enabled: !isActive,
            style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g., Free product, gift card...',
              hintStyle: TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context), fontSize: 14),
              filled: true,
              fillColor: bgLightGrey(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const Spacer(),
          if (isActive) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.controller.pickGiveawayWinner,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C3CE0)),
                child: const Text('Pick Winner',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  widget.controller.endGiveaway();
                  Get.back();
                },
                child: const Text('End Giveaway'),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final prize = _giveawayController.text.trim();
                  if (prize.isEmpty) return;
                  widget.controller.startGiveaway(prize);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C3CE0)),
                child: const Text('Start Giveaway',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          const SizedBox(height: 16),
        ],
      );
    });
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Obx(() {
      final isVisible = widget.controller.isPromoBannerVisible.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Banner Text',
              style: TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context), fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _promoController,
            enabled: !isVisible,
            maxLines: 2,
            maxLength: 100,
            style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g., Use code LIVE20 for 20% off!',
              hintStyle: TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context), fontSize: 14),
              filled: true,
              fillColor: bgLightGrey(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const Spacer(),
          if (isVisible)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.controller.hidePromoBanner();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorRes.likeRed),
                child: const Text('Hide Banner',
                    style: TextStyle(color: Colors.white)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final text = _promoController.text.trim();
                  if (text.isEmpty) return;
                  widget.controller.showPromoBanner(text);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorRes.themeAccentSolid),
                child: const Text('Show Banner',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          const SizedBox(height: 16),
        ],
      );
    });
  }
}

class _ToolTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _ToolTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: .15) : bgLightGrey(context),
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: color, width: 1) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: isSelected ? color : textLightGrey(context)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 11,
                    color: isSelected ? color : textLightGrey(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
