import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_bg_circle_button.dart';
import 'package:shortzz/common/widget/custom_page_indicator.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/color_filter_screen/color_filter_screen.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen_controller.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FeedImageView extends StatelessWidget {
  final RxList<ImageWithFilter> files;
  final CreateFeedScreenController controller;

  const FeedImageView(
      {super.key, required this.files, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return files.isEmpty
            ? const SizedBox()
            : SizedBox(
                height: Get.width,
                width: Get.width,
                child: Stack(
                  children: [
                    PageView.builder(
                        itemCount: files.length,
                        onPageChanged: (value) {
                          controller.selectedImageIndex.value = value;
                        },
                        itemBuilder: (context, index) {
                          ImageWithFilter file = files[index];
                          return file.colorFilter.isNotEmpty
                              ? ColorFiltered(
                                  colorFilter:
                                      ColorFilter.matrix(file.colorFilter),
                                  child: _file(file.media.path))
                              : _file(file.media.path);
                        }),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (files.length <
                                  (controller.setting.value?.maxImagesPerPost ??
                                      AppRes.imageLimit))
                                CustomBgCircleButton(
                                    image: AssetRes.icPlus,
                                    onTap: controller.selectImages),
                              const SizedBox(width: 5),
                              CustomBgCircleButton(
                                image: AssetRes.icDelete,
                                onTap: controller.onDeleteSelectedImages,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: _altTextButton(context),
                              ),
                              CustomPageIndicator(
                                  length: files.length,
                                  selectedIndex: controller.selectedImageIndex),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: CustomBgCircleButton(
                                  image: AssetRes.icFilter,
                                  onTap: () {
                                    Get.bottomSheet(
                                        ColorFilterScreen(
                                          images: files,
                                          onChanged: (items) {
                                            files.value = items;
                                            files.refresh();
                                          },
                                          mediaType: MediaType.image,
                                        ),
                                        isScrollControlled: true,
                                        ignoreSafeArea: false);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget _altTextButton(BuildContext context) {
    return Obx(() {
      final index = controller.selectedImageIndex.value;
      final hasAlt = index < files.length &&
          files[index].altText != null &&
          files[index].altText!.isNotEmpty;
      return GestureDetector(
        onTap: () => _showAltTextDialog(context, index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: hasAlt
                ? themeAccentSolid(context).withValues(alpha: 0.9)
                : Colors.black54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'ALT',
            style: TextStyleCustom.outFitMedium500(
                fontSize: 12, color: Colors.white),
          ),
        ),
      );
    });
  }

  void _showAltTextDialog(BuildContext context, int index) {
    if (index >= files.length) return;
    final textController =
        TextEditingController(text: files[index].altText ?? '');
    Get.dialog(
      AlertDialog(
        backgroundColor: scaffoldBackgroundColor(context),
        title: Text(
          LKey.altText.tr,
          style: TextStyleCustom.outFitMedium500(
              fontSize: 16, color: whitePure(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LKey.altTextDesc.tr,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 13, color: textLightGrey(context)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLength: 500,
              maxLines: 3,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 14, color: whitePure(context)),
              decoration: InputDecoration(
                hintText: LKey.addAltText.tr,
                hintStyle: TextStyleCustom.outFitRegular400(
                    fontSize: 14, color: textLightGrey(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LKey.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              files[index].altText = textController.text.trim().isEmpty
                  ? null
                  : textController.text.trim();
              files.refresh();
              Get.back();
            },
            child: Text(LKey.save.tr),
          ),
        ],
      ),
    );
  }

  Widget _file(String path) {
    return Image.file(File(path),
        height: Get.width, width: Get.width, fit: BoxFit.cover);
  }
}
