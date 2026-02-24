import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/live_stream/scheduled_live_screen/scheduled_live_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CreateScheduledLiveSheet extends StatelessWidget {
  final ScheduledLiveController controller;

  const CreateScheduledLiveSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: scaffoldBackgroundColor(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            LKey.scheduleLive,
            style: TextStyleCustom.unboundedMedium500(
                fontSize: 18, color: textDarkGrey(context)),
          ),
          const SizedBox(height: 20),
          // Title field
          TextField(
            controller: controller.titleController,
            onTapOutside: (_) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintText: LKey.liveTitle,
              hintStyle: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 15),
              filled: true,
              fillColor: bgLightGrey(context),
              border: OutlineInputBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context), fontSize: 15),
          ),
          const SizedBox(height: 12),
          // Description field
          TextField(
            controller: controller.descriptionController,
            onTapOutside: (_) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: LKey.description.tr,
              hintStyle: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 15),
              filled: true,
              fillColor: bgLightGrey(context),
              border: OutlineInputBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context), fontSize: 15),
          ),
          const SizedBox(height: 12),
          // Date/Time picker
          Obx(() {
            final dt = controller.selectedDateTime.value;
            return InkWell(
              onTap: () => controller.pickDateTime(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: ShapeDecoration(
                  color: bgLightGrey(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 12, cornerSmoothing: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18, color: textLightGrey(context)),
                    const SizedBox(width: 10),
                    Text(
                      dt != null
                          ? DateFormat('MMM d, yyyy – h:mm a').format(dt)
                          : LKey.selectDateTime,
                      style: TextStyleCustom.outFitRegular400(
                        color: dt != null
                            ? textDarkGrey(context)
                            : textLightGrey(context),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          // Schedule button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.createScheduledLive,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 12, cornerSmoothing: 1),
                ),
              ),
              child: Text(
                LKey.scheduleLive,
                style: TextStyleCustom.unboundedMedium500(
                    fontSize: 15, color: whitePure(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
