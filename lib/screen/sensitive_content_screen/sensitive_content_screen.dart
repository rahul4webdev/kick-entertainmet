import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/sensitive_content_screen/sensitive_content_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SensitiveContentScreen extends StatelessWidget {
  const SensitiveContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SensitiveContentScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.sensitiveContent.tr),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              LKey.sensitiveContentDesc.tr,
              style: TextStyleCustom.outFitLight300(
                  fontSize: 13, color: textLightGrey(context)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _LevelOption(
                  controller: controller,
                  level: 0,
                  title: LKey.allowSensitive,
                  description: LKey.allowSensitiveDesc,
                ),
                const SizedBox(height: 10),
                _LevelOption(
                  controller: controller,
                  level: 1,
                  title: LKey.limitSensitive,
                  description: LKey.limitSensitiveDesc,
                ),
                const SizedBox(height: 10),
                _LevelOption(
                  controller: controller,
                  level: 2,
                  title: LKey.limitMoreSensitive,
                  description: LKey.limitMoreSensitiveDesc,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelOption extends StatelessWidget {
  final SensitiveContentScreenController controller;
  final int level;
  final String title;
  final String description;

  const _LevelOption({
    required this.controller,
    required this.level,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedLevel.value == level;
      return GestureDetector(
        onTap: () => controller.setLevel(level),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgGrey(context),
            borderRadius: SmoothBorderRadius(cornerRadius: 12),
            border: Border.all(
              color: isSelected
                  ? themeAccentSolid(context)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr,
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 15, color: textDarkGrey(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description.tr,
                      style: TextStyleCustom.outFitLight300(
                          fontSize: 12, color: textLightGrey(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? themeAccentSolid(context)
                        : textLightGrey(context),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: themeAccentSolid(context),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }
}
