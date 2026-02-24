import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/common/widget/text_field_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/grievance_screen/grievance_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class GrievanceScreen extends StatelessWidget {
  const GrievanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GrievanceScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: LKey.grievanceRedressal.tr,
            titleStyle: TextStyleCustom.unboundedSemiBold600(
                fontSize: 15, color: textDarkGrey(context)),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isGrievanceLoading.value && controller.grievances.isEmpty) {
                return const LoaderWidget();
              }
              return RefreshIndicator(
                onRefresh: controller.fetchGrievances,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    // GRO Info Card
                    if (controller.groInfo.isNotEmpty) _GROInfoCard(controller: controller),
                    const SizedBox(height: 12),
                    // Submit button
                    TextButtonCustom(
                      onTap: () => _showSubmitSheet(context, controller),
                      title: LKey.submitGrievance.tr,
                      backgroundColor: themeAccentSolid(context),
                      titleColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    // My Grievances header
                    Text(
                      LKey.myGrievances.tr,
                      style: TextStyleCustom.unboundedSemiBold600(
                          fontSize: 14, color: textDarkGrey(context)),
                    ),
                    const SizedBox(height: 10),
                    if (controller.grievances.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: NoDataView(title: LKey.noData.tr),
                      ),
                    ...controller.grievances.map((g) => _GrievanceCard(
                          data: g,
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

  void _showSubmitSheet(BuildContext context, GrievanceScreenController controller) {
    controller.subjectController.clear();
    controller.descriptionController.clear();
    controller.selectedCategory.value = '';

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
                LKey.submitGrievance.tr,
                style: TextStyleCustom.unboundedSemiBold600(
                    fontSize: 16, color: textDarkGrey(context)),
              ),
              const SizedBox(height: 15),
              // Category dropdown
              Text(LKey.grievanceCategory.tr,
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 13, color: textLightGrey(context))),
              const SizedBox(height: 6),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GrievanceScreenController.categories.map((cat) {
                      final isSelected = controller.selectedCategory.value == cat['key'];
                      return GestureDetector(
                        onTap: () => controller.selectedCategory.value = cat['key']!,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? themeAccentSolid(context)
                                : textLightGrey(context).withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat['label']!,
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
                controller: controller.subjectController,
                title: LKey.grievanceSubject.tr,
              ),
              TextFieldCustom(
                controller: controller.descriptionController,
                title: LKey.grievanceDescription.tr,
              ),
              const SizedBox(height: 15),
              TextButtonCustom(
                onTap: controller.submitGrievance,
                title: LKey.submitGrievance.tr,
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

class _GROInfoCard extends StatelessWidget {
  final GrievanceScreenController controller;
  const _GROInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final info = controller.groInfo;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: themeAccentSolid(context).withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LKey.grievanceOfficer.tr,
            style: TextStyleCustom.outFitSemiBold600(
                fontSize: 14, color: textDarkGrey(context)),
          ),
          const SizedBox(height: 8),
          if (info['name'] != null && (info['name'] as String).isNotEmpty)
            _infoRow(Icons.person_outline, info['name'], context),
          if (info['email'] != null && (info['email'] as String).isNotEmpty)
            _infoRow(Icons.email_outlined, info['email'], context),
          if (info['phone'] != null && (info['phone'] as String).isNotEmpty)
            _infoRow(Icons.phone_outlined, info['phone'], context),
          if (info['response_time'] != null)
            _infoRow(Icons.timer_outlined, '${LKey.responseTime.tr}: ${info['response_time']}', context),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textLightGrey(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 13, color: textDarkGrey(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrievanceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final GrievanceScreenController controller;
  const _GrievanceCard({required this.data, required this.controller});

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
                  data['subject'] ?? '',
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: textDarkGrey(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            data['description'] ?? '',
            style: TextStyleCustom.outFitRegular400(
                fontSize: 12, color: textLightGrey(context)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '#${data['ticket_number'] ?? ''}',
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 11, color: themeAccentSolid(context)),
              ),
              const Spacer(),
              Text(
                dateStr,
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 11, color: textLightGrey(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
