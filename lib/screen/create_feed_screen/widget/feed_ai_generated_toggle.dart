import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_toggle.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FeedAiGeneratedToggle extends StatelessWidget {
  const FeedAiGeneratedToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateFeedScreenController>();
    return Container(
      height: 47,
      color: bgLightGrey(context),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Icon(Icons.smart_toy_outlined, size: 22, color: textDarkGrey(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              LKey.aiGenerated.tr,
              style: TextStyleCustom.outFitLight300(fontSize: 15, color: textDarkGrey(context)),
            ),
          ),
          CustomToggle(
              isOn: controller.isAiGenerated,
              onChanged: (value) {
                controller.commentHelper.detectableTextFocusNode.unfocus();
                controller.isAiGenerated.value = value;
              })
        ],
      ),
    );
  }
}
