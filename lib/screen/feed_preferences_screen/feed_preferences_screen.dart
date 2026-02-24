import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/feed_preferences_screen/feed_preferences_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FeedPreferencesScreen extends StatelessWidget {
  const FeedPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedPreferencesScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.feedPreferences.tr),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              LKey.feedPreferencesDesc.tr,
              style: TextStyleCustom.outFitLight300(
                  fontSize: 13, color: textLightGrey(context)),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isDataLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.interests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final interest = controller.interests[index];
                  return _InterestTile(
                    controller: controller,
                    interestId: interest.id ?? 0,
                    name: interest.name ?? '',
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InterestTile extends StatelessWidget {
  final FeedPreferencesScreenController controller;
  final int interestId;
  final String name;

  const _InterestTile({
    required this.controller,
    required this.interestId,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgGrey(context),
        borderRadius: SmoothBorderRadius(cornerRadius: 12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyleCustom.outFitMedium500(
                  fontSize: 15, color: textDarkGrey(context)),
            ),
          ),
          Obx(() {
            final weight = controller.getWeight(interestId);
            return GestureDetector(
              onTap: () => controller.cycleWeight(interestId),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _chipColor(context, weight),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.getWeightLabel(weight).tr,
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 12,
                    color: weight == 0
                        ? textLightGrey(context)
                        : Colors.white,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _chipColor(BuildContext context, int weight) {
    switch (weight) {
      case 1:
        return Colors.green;
      case -1:
        return Colors.redAccent;
      default:
        return bgLightGrey(context);
    }
  }
}
