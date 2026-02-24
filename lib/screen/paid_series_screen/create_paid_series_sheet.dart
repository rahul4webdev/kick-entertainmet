import 'dart:io';

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/paid_series_screen/paid_series_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CreatePaidSeriesSheet extends StatelessWidget {
  final PaidSeriesController controller;

  const CreatePaidSeriesSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.6,
      decoration: ShapeDecoration(
        color: scaffoldBackgroundColor(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: bgMediumGrey(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            LKey.createPaidSeries,
            style: TextStyleCustom.unboundedSemiBold600(
                fontSize: 18, color: textDarkGrey(context)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Cover image picker
                  Obx(() {
                    final img = controller.coverImage.value;
                    return InkWell(
                      onTap: controller.pickCoverImage,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: ShapeDecoration(
                          color: bgLightGrey(context),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 12, cornerSmoothing: 1),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: img != null
                            ? Image.file(File(img.path), fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      size: 32, color: textLightGrey(context)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cover Image',
                                    style: TextStyleCustom.outFitLight300(
                                        color: textLightGrey(context),
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  // Title
                  TextField(
                    controller: controller.titleController,
                    style: TextStyleCustom.outFitRegular400(
                        color: textDarkGrey(context), fontSize: 15),
                    decoration: InputDecoration(
                      hintText: LKey.seriesTitle,
                      hintStyle: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 15),
                      filled: true,
                      fillColor: bgLightGrey(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  TextField(
                    controller: controller.descriptionController,
                    style: TextStyleCustom.outFitRegular400(
                        color: textDarkGrey(context), fontSize: 15),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: LKey.seriesDescription,
                      hintStyle: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 15),
                      filled: true,
                      fillColor: bgLightGrey(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price
                  TextField(
                    controller: controller.priceController,
                    style: TextStyleCustom.outFitRegular400(
                        color: textDarkGrey(context), fontSize: 15),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: LKey.priceInCoins,
                      hintStyle: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 15),
                      filled: true,
                      fillColor: bgLightGrey(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      prefixIcon: Icon(Icons.monetization_on_outlined,
                          color: textLightGrey(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Create button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: controller.createSeries,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 12, cornerSmoothing: 1),
                ),
              ),
              child: Text(
                LKey.createPaidSeries,
                style: TextStyleCustom.outFitMedium500(
                    color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
