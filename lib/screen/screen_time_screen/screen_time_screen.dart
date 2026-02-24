import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/screen_time_manager.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_toggle.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/screen_time_screen/screen_time_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ScreenTimeScreen extends StatelessWidget {
  const ScreenTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScreenTimeScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.screenTime.tr),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UsageDashboard(controller: controller),
                  const SizedBox(height: 20),
                  _WeeklyChart(controller: controller),
                  const SizedBox(height: 20),
                  _SectionHeader(title: LKey.screenTimeSettings.tr),
                  const SizedBox(height: 10),
                  _DailyLimitSelector(controller: controller),
                  const SizedBox(height: 12),
                  _BreakIntervalSelector(controller: controller),
                  const SizedBox(height: 12),
                  _BedtimeSection(controller: controller),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyleCustom.outFitMedium500(
          fontSize: 16, color: textDarkGrey(context)),
    );
  }
}

class _UsageDashboard extends StatelessWidget {
  final ScreenTimeScreenController controller;
  const _UsageDashboard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeAccentSolid(context).withValues(alpha: 0.1),
        borderRadius: SmoothBorderRadius(cornerRadius: 16),
      ),
      child: Column(
        children: [
          Text(
            LKey.todayScreenTime.tr,
            style: TextStyleCustom.outFitRegular400(
                fontSize: 14, color: textLightGrey(context)),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final seconds = ScreenTimeManager.instance.todayUsageSeconds.value;
            return Text(
              ScreenTimeManager.formatDuration(Duration(seconds: seconds)),
              style: TextStyleCustom.outFitBold700(
                  fontSize: 36, color: themeAccentSolid(context)),
            );
          }),
          const SizedBox(height: 4),
          Obx(() {
            final limit = controller.dailyLimit.value;
            if (limit <= 0) return const SizedBox();
            return Text(
              '${LKey.dailyLimit.tr}: ${controller.formatLimit(limit)}',
              style: TextStyleCustom.outFitLight300(
                  fontSize: 13, color: textLightGrey(context)),
            );
          }),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final ScreenTimeScreenController controller;
  const _WeeklyChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    final weekly = ScreenTimeManager.instance.weeklyUsage();
    final maxSeconds =
        weekly.fold<int>(0, (prev, e) => e.value > prev ? e.value : prev);
    final maxHeight = 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LKey.weeklyOverview.tr,
          style: TextStyleCustom.outFitMedium500(
              fontSize: 16, color: textDarkGrey(context)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: maxHeight + 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekly.map((entry) {
              final barHeight = maxSeconds > 0
                  ? (entry.value / maxSeconds) * maxHeight
                  : 0.0;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (entry.value > 0)
                      Text(
                        ScreenTimeManager.formatDuration(
                            Duration(seconds: entry.value)),
                        style: TextStyleCustom.outFitLight300(
                            fontSize: 9, color: textLightGrey(context)),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      height: barHeight < 4 && entry.value > 0
                          ? 4
                          : barHeight,
                      width: 24,
                      decoration: BoxDecoration(
                        color: themeAccentSolid(context)
                            .withValues(alpha: entry == weekly.last ? 1.0 : 0.5),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.key,
                      style: TextStyleCustom.outFitLight300(
                          fontSize: 11, color: textLightGrey(context)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DailyLimitSelector extends StatelessWidget {
  final ScreenTimeScreenController controller;
  const _DailyLimitSelector({required this.controller});

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
            LKey.dailyLimit.tr,
            style: TextStyleCustom.outFitMedium500(
                fontSize: 15, color: textDarkGrey(context)),
          ),
          const SizedBox(height: 4),
          Text(
            LKey.dailyLimitDesc.tr,
            style: TextStyleCustom.outFitLight300(
                fontSize: 12, color: textLightGrey(context)),
          ),
          const SizedBox(height: 10),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.dailyLimitOptions.map((minutes) {
                  final isSelected =
                      controller.dailyLimit.value == minutes;
                  return GestureDetector(
                    onTap: () => controller.setDailyLimit(minutes),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeAccentSolid(context)
                            : bgLightGrey(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.formatLimit(minutes),
                        style: TextStyleCustom.outFitMedium500(
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white
                              : textDarkGrey(context),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }
}

class _BreakIntervalSelector extends StatelessWidget {
  final ScreenTimeScreenController controller;
  const _BreakIntervalSelector({required this.controller});

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
            LKey.breakReminder.tr,
            style: TextStyleCustom.outFitMedium500(
                fontSize: 15, color: textDarkGrey(context)),
          ),
          const SizedBox(height: 4),
          Text(
            LKey.breakReminderDesc.tr,
            style: TextStyleCustom.outFitLight300(
                fontSize: 12, color: textLightGrey(context)),
          ),
          const SizedBox(height: 10),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    controller.breakIntervalOptions.map((minutes) {
                  final isSelected =
                      controller.breakInterval.value == minutes;
                  return GestureDetector(
                    onTap: () => controller.setBreakInterval(minutes),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeAccentSolid(context)
                            : bgLightGrey(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.formatLimit(minutes),
                        style: TextStyleCustom.outFitMedium500(
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white
                              : textDarkGrey(context),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }
}

class _BedtimeSection extends StatelessWidget {
  final ScreenTimeScreenController controller;
  const _BedtimeSection({required this.controller});

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LKey.bedtimeReminder.tr,
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 15, color: textDarkGrey(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LKey.bedtimeReminderDesc.tr,
                      style: TextStyleCustom.outFitLight300(
                          fontSize: 12, color: textLightGrey(context)),
                    ),
                  ],
                ),
              ),
              Obx(() => CustomToggle(
                    isOn: controller.bedtimeEnabled,
                    onChanged: controller.toggleBedtime,
                  )),
            ],
          ),
          Obx(() {
            if (!controller.bedtimeEnabled.value) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () => controller.pickBedtime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgLightGrey(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bedtime_outlined,
                          size: 18, color: themeAccentSolid(context)),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                            controller.formatBedtime(controller.bedtime.value),
                            style: TextStyleCustom.outFitMedium500(
                                fontSize: 14,
                                color: textDarkGrey(context)),
                          )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
