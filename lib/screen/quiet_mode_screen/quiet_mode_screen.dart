import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/quiet_mode_screen/quiet_mode_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class QuietModeScreen extends StatelessWidget {
  const QuietModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuietModeScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.quietMode.tr),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusCard(controller: controller),
                  const SizedBox(height: 16),
                  Text(
                    LKey.quietModeDesc.tr,
                    style: TextStyleCustom.outFitLight300(
                        fontSize: 13, color: textLightGrey(context)),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    if (controller.isQuietMode.value) {
                      return _ActiveSection(controller: controller);
                    }
                    return _DurationPicker(controller: controller);
                  }),
                  const SizedBox(height: 20),
                  _AutoReplySection(controller: controller),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final QuietModeScreenController controller;
  const _StatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOn = controller.isQuietMode.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isOn
              ? themeAccentSolid(context).withValues(alpha: 0.1)
              : bgGrey(context),
          borderRadius: SmoothBorderRadius(cornerRadius: 16),
        ),
        child: Column(
          children: [
            Icon(
              isOn ? Icons.notifications_off : Icons.notifications_active,
              size: 40,
              color: isOn
                  ? themeAccentSolid(context)
                  : textLightGrey(context),
            ),
            const SizedBox(height: 10),
            Text(
              isOn ? LKey.quietModeOn.tr : LKey.quietModeOff.tr,
              style: TextStyleCustom.outFitMedium500(
                  fontSize: 18,
                  color: isOn
                      ? themeAccentSolid(context)
                      : textDarkGrey(context)),
            ),
            if (isOn) ...[
              const SizedBox(height: 6),
              Obx(() => Text(
                    controller.remainingTime,
                    style: TextStyleCustom.outFitLight300(
                        fontSize: 13, color: textLightGrey(context)),
                  )),
            ],
          ],
        ),
      );
    });
  }
}

class _ActiveSection extends StatelessWidget {
  final QuietModeScreenController controller;
  const _ActiveSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LKey.quietModeActive.tr,
          style: TextStyleCustom.outFitMedium500(
              fontSize: 16, color: textDarkGrey(context)),
        ),
        const SizedBox(height: 6),
        Text(
          LKey.quietModeActiveDesc.tr,
          style: TextStyleCustom.outFitLight300(
              fontSize: 13, color: textLightGrey(context)),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: controller.disableQuietMode,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: SmoothBorderRadius(cornerRadius: 12),
              ),
              alignment: Alignment.center,
              child: Text(
                LKey.turnOffQuietMode.tr,
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 15, color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final QuietModeScreenController controller;
  const _DurationPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LKey.quietModeDuration.tr,
          style: TextStyleCustom.outFitMedium500(
              fontSize: 16, color: textDarkGrey(context)),
        ),
        const SizedBox(height: 10),
        ...controller.durationOptions.map((minutes) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => controller.enableQuietMode(minutes),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgGrey(context),
                  borderRadius: SmoothBorderRadius(cornerRadius: 12),
                ),
                child: Text(
                  controller.formatDuration(minutes),
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 15, color: textDarkGrey(context)),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _AutoReplySection extends StatelessWidget {
  final QuietModeScreenController controller;
  const _AutoReplySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgGrey(context),
        borderRadius: SmoothBorderRadius(cornerRadius: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LKey.autoReply.tr,
            style: TextStyleCustom.outFitMedium500(
                fontSize: 15, color: textDarkGrey(context)),
          ),
          const SizedBox(height: 4),
          Text(
            LKey.autoReplyDesc.tr,
            style: TextStyleCustom.outFitLight300(
                fontSize: 12, color: textLightGrey(context)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller.autoReplyController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: LKey.autoReplyHint.tr,
              hintStyle: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: SmoothBorderRadius(cornerRadius: 10),
                borderSide: BorderSide(color: bgGrey(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: SmoothBorderRadius(cornerRadius: 10),
                borderSide: BorderSide(color: bgLightGrey(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: SmoothBorderRadius(cornerRadius: 10),
                borderSide: BorderSide(color: themeAccentSolid(context)),
              ),
            ),
            style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context)),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: controller.saveAutoReply,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: themeAccentSolid(context),
                borderRadius: SmoothBorderRadius(cornerRadius: 10),
              ),
              child: Text(
                LKey.save.tr,
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
