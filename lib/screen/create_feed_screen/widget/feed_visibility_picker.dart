import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FeedVisibilityPicker extends StatelessWidget {
  const FeedVisibilityPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateFeedScreenController>();
    return Container(
      height: 47,
      color: bgLightGrey(context),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Image.asset(AssetRes.icEye, height: 22, width: 22, color: textDarkGrey(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              LKey.postVisibility.tr,
              style: TextStyleCustom.outFitLight300(fontSize: 15, color: textDarkGrey(context)),
            ),
          ),
          Obx(() => PopupMenuButton<int>(
                onSelected: (value) {
                  controller.commentHelper.detectableTextFocusNode.unfocus();
                  controller.visibility.value = value;
                },
                itemBuilder: (context) => [
                  _buildMenuItem(context, 0, AssetRes.icEye, LKey.public.tr),
                  _buildMenuItem(context, 1, AssetRes.icFollow, LKey.followersOnly.tr),
                  _buildMenuItem(context, 2, AssetRes.icHideEye, LKey.onlyMe.tr),
                  if (SessionManager.instance.getUser()?.subscriptionsEnabled == true)
                    _buildMenuItem(context, 3, AssetRes.icStar, LKey.subscribersOnly.tr),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getVisibilityLabel(controller.visibility.value),
                      style: TextStyleCustom.outFitLight300(
                        fontSize: 14,
                        color: textLightGrey(context),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset(AssetRes.icDownArrow, height: 12, width: 12, color: textLightGrey(context)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _getVisibilityLabel(int value) {
    switch (value) {
      case 1:
        return LKey.followersOnly.tr;
      case 2:
        return LKey.onlyMe.tr;
      case 3:
        return LKey.subscribersOnly.tr;
      default:
        return LKey.public.tr;
    }
  }

  PopupMenuItem<int> _buildMenuItem(BuildContext context, int value, String icon, String label) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Image.asset(icon, height: 18, width: 18, color: textDarkGrey(context)),
          const SizedBox(width: 10),
          Text(label, style: TextStyleCustom.outFitLight300(fontSize: 14, color: textDarkGrey(context))),
        ],
      ),
    );
  }
}
