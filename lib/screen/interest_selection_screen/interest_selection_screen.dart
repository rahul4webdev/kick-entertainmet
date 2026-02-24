import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/interest_model.dart';
import 'package:shortzz/screen/interest_selection_screen/interest_selection_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class InterestSelectionScreen extends StatelessWidget {
  const InterestSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterestSelectionScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.myInterests.tr),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              LKey.selectInterests.tr,
              style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 15),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingInterests.value) {
                return const LoaderWidget();
              }
              return GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.8,
                ),
                itemCount: controller.allInterests.length,
                itemBuilder: (context, index) {
                  Interest interest = controller.allInterests[index];
                  return Obx(() {
                    bool isSelected =
                        controller.selectedIds.contains(interest.id);
                    return GestureDetector(
                      onTap: () => controller.toggleInterest(interest.id!),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          shape: SmoothRectangleBorder(
                            side: BorderSide(
                              color: isSelected
                                  ? themeAccentSolid(context)
                                  : bgGrey(context),
                              width: isSelected ? 1.5 : 1,
                            ),
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 12, cornerSmoothing: 1),
                          ),
                          color: isSelected
                              ? themeAccentSolid(context)
                                  .withValues(alpha: 0.08)
                              : bgLightGrey(context),
                        ),
                        child: Text(
                          interest.name ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyleCustom.outFitMedium500(
                            fontSize: 14,
                            color: isSelected
                                ? themeAccentSolid(context)
                                : textDarkGrey(context),
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
          Obx(() => Padding(
                padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: MediaQuery.of(context).padding.bottom + 10,
                    top: 10),
                child: TextButtonCustom(
                  onTap: controller.isSaving.value
                      ? () {}
                      : controller.saveInterests,
                  title: LKey.save.tr,
                  horizontalMargin: 0,
                  btnHeight: 50,
                  fontSize: 16,
                  backgroundColor: controller.selectedIds.isEmpty
                      ? bgGrey(context)
                      : themeAccentSolid(context),
                  titleColor: controller.selectedIds.isEmpty
                      ? textLightGrey(context)
                      : whitePure(context),
                  child: controller.isSaving.value
                      ? CupertinoActivityIndicator(
                          radius: 10, color: whitePure(context))
                      : null,
                ),
              )),
        ],
      ),
    );
  }
}
