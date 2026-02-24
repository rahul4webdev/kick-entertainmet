import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/monetization_screen/monetization_screen_controller.dart';
import 'package:shortzz/screen/monetization_screen/widget/kyc_upload_section.dart';
import 'package:shortzz/screen/monetization_screen/widget/requirement_checklist.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class MonetizationScreen extends StatelessWidget {
  const MonetizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MonetizationScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.monetization.tr),
          Expanded(
            child: Obx(() {
              if (controller.isDataLoading.value) {
                return const LoaderWidget();
              }
              final data = controller.statusData.value;
              if (data == null) {
                return Center(
                  child: Text(LKey.somethingWentWrong.tr,
                      style: TextStyleCustom.outFitRegular400(
                          color: textLightGrey(context))),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBanner(
                      isMonetized: data.isMonetized == 1,
                      monetizationStatus: data.monetizationStatus ?? 0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      LKey.requirements.tr,
                      style: TextStyleCustom.unboundedMedium500(
                          color: textDarkGrey(context), fontSize: 17),
                    ),
                    const SizedBox(height: 10),
                    RequirementChecklist(
                      requirements: data.requirements,
                      followerCount: data.followerCount ?? 0,
                      minFollowersRequired: data.minFollowersRequired ?? 0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      LKey.kycDocuments.tr,
                      style: TextStyleCustom.unboundedMedium500(
                          color: textDarkGrey(context), fontSize: 17),
                    ),
                    const SizedBox(height: 10),
                    KycUploadSection(
                      documents: data.verificationDocuments ?? [],
                      isUploading: controller.isUploading.value,
                      onUpload: controller.uploadKycDocument,
                    ),
                    const SizedBox(height: 30),
                    if (data.isMonetized != 1 &&
                        data.monetizationStatus != 1) ...[
                      TextButtonCustom(
                        onTap: controller.applyForMonetization,
                        title: LKey.applyForMonetization.tr,
                        horizontalMargin: 0,
                        backgroundColor: textDarkGrey(context),
                        titleColor: whitePure(context),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool isMonetized;
  final int monetizationStatus;

  const _StatusBanner({
    required this.isMonetized,
    required this.monetizationStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color bannerColor;
    String statusText;
    IconData icon;

    if (isMonetized) {
      bannerColor = Colors.green;
      statusText = LKey.monetizationActive.tr;
      icon = Icons.verified;
    } else if (monetizationStatus == 1) {
      bannerColor = Colors.orange;
      statusText = LKey.monetizationPending.tr;
      icon = Icons.hourglass_top;
    } else if (monetizationStatus == 3) {
      bannerColor = Colors.red;
      statusText = LKey.monetizationRejected.tr;
      icon = Icons.cancel;
    } else {
      bannerColor = Colors.grey;
      statusText = LKey.notMonetized.tr;
      icon = Icons.monetization_on_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
        ),
        color: bannerColor.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          Icon(icon, color: bannerColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyleCustom.outFitMedium500(
                  color: bannerColor, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
