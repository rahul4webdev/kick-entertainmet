import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/share_manager.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/share_sheet_widget/share_sheet_widget.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class PostUploadShareSheet {
  static void show({required Post post}) {
    final link = ShareManager.shared.getLink(
      key: post.postType == PostType.reel ? ShareKeys.reel : ShareKeys.post,
      value: post.id ?? -1,
    );

    Get.bottomSheet(
      _PostUploadShareContent(post: post, link: link),
      isScrollControlled: true,
    );
  }
}

class _PostUploadShareContent extends StatelessWidget {
  final Post post;
  final String link;

  const _PostUploadShareContent({required this.post, required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.vertical(
              top: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1)),
        ),
        color: scaffoldBackgroundColor(context),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: bgGrey(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Icon(Icons.check_circle_rounded,
              color: themeAccentSolid(context), size: 48),
          const SizedBox(height: 12),
          Text(
            LKey.postUploadedShareNow.tr,
            style: TextStyleCustom.unboundedSemiBold600(
                color: textDarkGrey(context), fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            LKey.shareToOtherPlatforms.tr,
            style: TextStyleCustom.outFitLight300(
                color: textLightGrey(context), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomAssetWithBgButton(
                  image: AssetRes.icWhatsapp,
                  boxSize: 58,
                  iconSize: 30,
                  onTap: () => _shareTo(ShareOption.whatsapp, context),
                ),
                const SizedBox(width: 12),
                CustomAssetWithBgButton(
                  image: AssetRes.icInstagram,
                  boxSize: 58,
                  iconSize: 30,
                  onTap: () => _shareTo(ShareOption.instagram, context),
                ),
                const SizedBox(width: 12),
                CustomAssetWithBgButton(
                  image: AssetRes.icTelegram,
                  boxSize: 58,
                  iconSize: 30,
                  onTap: () => _shareTo(ShareOption.telegram, context),
                ),
                const SizedBox(width: 12),
                PlatformShareButton(
                  icon: Icons.facebook_rounded,
                  color: const Color(0xFF1877F2),
                  onTap: () => _shareTo(ShareOption.facebook, context),
                ),
                const SizedBox(width: 12),
                PlatformShareButton(
                  icon: Icons.close,
                  label: 'X',
                  color: Colors.black,
                  onTap: () => _shareTo(ShareOption.twitter, context),
                ),
                const SizedBox(width: 12),
                CustomAssetWithBgButton(
                  image: AssetRes.icMore,
                  boxSize: 58,
                  iconSize: 30,
                  onTap: () {
                    Get.back();
                    ShareManager.shared.shareTheContent(
                      key: post.postType == PostType.reel
                          ? ShareKeys.reel
                          : ShareKeys.post,
                      value: post.id ?? -1,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: Get.back,
            child: Text(
              LKey.skipForNow.tr,
              style: TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _shareTo(ShareOption option, BuildContext context) {
    final url = option.value(link);
    if (url.isNotEmpty) {
      url.lunchUrl;
    }
    Get.back();
  }
}
