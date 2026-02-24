import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/common/widget/text_field_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/appeal_screen/appeal_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class AppealScreen extends StatelessWidget {
  const AppealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppealScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: LKey.appealDecision.tr,
            titleStyle: TextStyleCustom.unboundedSemiBold600(
                fontSize: 15, color: textDarkGrey(context)),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isAppealLoading.value && controller.appeals.isEmpty) {
                return const LoaderWidget();
              }
              return RefreshIndicator(
                onRefresh: controller.fetchAppeals,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    TextButtonCustom(
                      onTap: () => _showSubmitSheet(context, controller),
                      title: LKey.submitAppeal.tr,
                      backgroundColor: themeAccentSolid(context),
                      titleColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      LKey.myAppeals.tr,
                      style: TextStyleCustom.unboundedSemiBold600(
                          fontSize: 14, color: textDarkGrey(context)),
                    ),
                    const SizedBox(height: 10),
                    if (controller.appeals.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: NoDataView(title: LKey.noData.tr),
                      ),
                    ...controller.appeals.map((a) => _AppealCard(
                          data: a,
                          controller: controller,
                        )),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showSubmitSheet(BuildContext context, AppealScreenController controller) {
    controller.reasonController.clear();
    controller.contextController.clear();
    controller.selectedAppealType.value = '';

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 15),
              Text(
                LKey.submitAppeal.tr,
                style: TextStyleCustom.unboundedSemiBold600(
                    fontSize: 16, color: textDarkGrey(context)),
              ),
              const SizedBox(height: 15),
              Text(LKey.grievanceCategory.tr,
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 13, color: textLightGrey(context))),
              const SizedBox(height: 6),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppealScreenController.appealTypes.map((type) {
                      final isSelected = controller.selectedAppealType.value == type['key'];
                      return GestureDetector(
                        onTap: () => controller.selectedAppealType.value = type['key']!,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? themeAccentSolid(context)
                                : textLightGrey(context).withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type['label']!,
                            style: TextStyleCustom.outFitMedium500(
                              fontSize: 12,
                              color: isSelected ? Colors.white : textDarkGrey(context),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 12),
              TextFieldCustom(
                controller: controller.reasonController,
                title: LKey.appealReason.tr,
              ),
              TextFieldCustom(
                controller: controller.contextController,
                title: LKey.additionalContext,
              ),
              const SizedBox(height: 15),
              TextButtonCustom(
                onTap: controller.submitAppeal,
                title: LKey.submitAppeal.tr,
                backgroundColor: themeAccentSolid(context),
                titleColor: Colors.white,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _AppealCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final AppealScreenController controller;
  const _AppealCard({required this.data, required this.controller});

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as int? ?? 0;
    final createdAt = data['created_at'] as String?;
    String dateStr = '';
    if (createdAt != null) {
      try {
        dateStr = DateFormat('dd MMM yyyy').format(DateTime.parse(createdAt));
      } catch (_) {}
    }

    final appealType = data['appeal_type'] as String? ?? '';
    final typeLabel = AppealScreenController.appealTypes
        .firstWhereOrNull((t) => t['key'] == appealType)?['label'] ?? appealType;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: textLightGrey(context).withValues(alpha: .2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  typeLabel,
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: textDarkGrey(context)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: controller.statusColor(status).withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  controller.statusLabel(status),
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 11, color: controller.statusColor(status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data['reason'] ?? '',
            style: TextStyleCustom.outFitRegular400(
                fontSize: 12, color: textLightGrey(context)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (data['decision_notes'] != null) ...[
            const SizedBox(height: 6),
            Text(
              'Decision: ${data['decision_notes']}',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 12, color: textDarkGrey(context)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              dateStr,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 11, color: textLightGrey(context)),
            ),
          ),
        ],
      ),
    );
  }
}
