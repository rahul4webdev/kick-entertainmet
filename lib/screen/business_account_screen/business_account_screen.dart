import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/profile_category_model.dart';
import 'package:shortzz/screen/business_account_screen/business_account_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class BusinessAccountScreen extends StatelessWidget {
  const BusinessAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BusinessAccountScreenController());
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) controller.goBack();
      },
      child: Scaffold(
        body: Column(
          children: [
            Obx(() => CustomAppBar(
                  title: _getTitle(controller.currentStep.value),
                )),
            // Show revert button if already business account
            if (controller.currentAccountType > 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: TextButtonCustom(
                  onTap: controller.revertToPersonal,
                  title: LKey.revertToPersonal.tr,
                  horizontalMargin: 0,
                  btnHeight: 45,
                  fontSize: 15,
                  backgroundColor: bgGrey(context),
                  titleColor: textLightGrey(context),
                ),
              ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AccountTypeStep(controller: controller),
                  _CategoryStep(controller: controller),
                  _SubCategoryStep(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(int step) {
    switch (step) {
      case 0:
        return LKey.chooseAccountType.tr;
      case 1:
        return LKey.chooseCategory.tr;
      case 2:
        return LKey.chooseSubCategory.tr;
      default:
        return LKey.switchToBusinessAccount.tr;
    }
  }
}

class _AccountTypeStep extends StatelessWidget {
  final BusinessAccountScreenController controller;

  const _AccountTypeStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    final accountTypes = [
      _AccountTypeItem(1, LKey.influencerCreator.tr, Icons.person_outline),
      _AccountTypeItem(2, LKey.businessText.tr, Icons.business_outlined),
      _AccountTypeItem(3, LKey.productionHouse.tr, Icons.movie_outlined),
      _AccountTypeItem(4, LKey.newsMedia.tr, Icons.newspaper_outlined),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(15),
      itemCount: accountTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = accountTypes[index];
        return Obx(() {
          bool isSelected = controller.selectedAccountType.value == item.type;
          return InkWell(
            onTap: () => controller.selectAccountType(item.type),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                shape: SmoothRectangleBorder(
                  side: BorderSide(
                    color: isSelected
                        ? themeAccentSolid(context)
                        : bgGrey(context),
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                ),
                color: isSelected
                    ? themeAccentSolid(context).withValues(alpha: 0.08)
                    : bgLightGrey(context),
              ),
              child: Row(
                children: [
                  Icon(item.icon,
                      size: 28,
                      color: isSelected
                          ? themeAccentSolid(context)
                          : textLightGrey(context)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 16,
                        color: isSelected
                            ? themeAccentSolid(context)
                            : textDarkGrey(context),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle,
                        color: themeAccentSolid(context), size: 24),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class _CategoryStep extends StatelessWidget {
  final BusinessAccountScreenController controller;

  const _CategoryStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return const LoaderWidget();
      }
      return ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: controller.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          ProfileCategory cat = controller.categories[index];
          return Obx(() {
            bool isSelected = controller.selectedCategory.value?.id == cat.id;
            return InkWell(
              onTap: () => controller.selectCategory(cat),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(
                    side: BorderSide(
                      color: isSelected
                          ? themeAccentSolid(context)
                          : bgGrey(context),
                    ),
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 10, cornerSmoothing: 1),
                  ),
                  color: isSelected
                      ? themeAccentSolid(context).withValues(alpha: 0.08)
                      : bgLightGrey(context),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        cat.name ?? '',
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 15,
                          color: isSelected
                              ? themeAccentSolid(context)
                              : textDarkGrey(context),
                        ),
                      ),
                    ),
                    if (cat.requiresApproval == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          LKey.pendingApproval.tr,
                          style: TextStyleCustom.outFitLight300(
                              fontSize: 11, color: Colors.orange),
                        ),
                      ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.check_circle,
                            color: themeAccentSolid(context), size: 22),
                      ),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }
}

class _SubCategoryStep extends StatelessWidget {
  final BusinessAccountScreenController controller;

  const _SubCategoryStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<ProfileSubCategory> subs =
          controller.selectedCategory.value?.subCategories ?? [];
      if (subs.isEmpty) {
        return const SizedBox();
      }
      return ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: subs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          ProfileSubCategory sub = subs[index];
          return Obx(() {
            bool isSelected =
                controller.selectedSubCategory.value?.id == sub.id;
            return InkWell(
              onTap: () => controller.selectSubCategory(sub),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(
                    side: BorderSide(
                      color: isSelected
                          ? themeAccentSolid(context)
                          : bgGrey(context),
                    ),
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 10, cornerSmoothing: 1),
                  ),
                  color: isSelected
                      ? themeAccentSolid(context).withValues(alpha: 0.08)
                      : bgLightGrey(context),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        sub.name ?? '',
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 15,
                          color: isSelected
                              ? themeAccentSolid(context)
                              : textDarkGrey(context),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle,
                          color: themeAccentSolid(context), size: 22),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }
}

class _AccountTypeItem {
  final int type;
  final String title;
  final IconData icon;

  _AccountTypeItem(this.type, this.title, this.icon);
}
