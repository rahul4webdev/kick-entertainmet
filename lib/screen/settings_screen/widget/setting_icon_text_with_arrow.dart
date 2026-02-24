import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SettingIconTextWithArrow extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final String title;
  final VoidCallback? onTap;
  final Widget? widget;
  final Color? iconBgColor;
  final Color? iconColor;
  final bool showDivider;

  const SettingIconTextWithArrow({
    super.key,
    this.icon,
    this.iconData,
    required this.title,
    this.onTap,
    this.widget,
    this.iconBgColor,
    this.iconColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon with colored background
            Container(
              width: 36,
              height: 36,
              decoration: ShapeDecoration(
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 0.8),
                ),
                color: iconBgColor ?? themeAccentSolid(context).withValues(alpha: .08),
              ),
              alignment: Alignment.center,
              child: iconData != null
                  ? Icon(iconData, size: 20, color: iconColor ?? themeAccentSolid(context))
                  : Image.asset(icon!, height: 20, width: 20, color: iconColor ?? themeAccentSolid(context)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title.tr,
                style: TextStyleCustom.outFitRegular400(fontSize: 15, color: textDarkGrey(context)),
              ),
            ),
            const SizedBox(width: 8),
            widget ??
                Icon(Icons.chevron_right_rounded, size: 22, color: textLightGrey(context).withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

// Modern section container with rounded corners
class SettingSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> children;

  const SettingSection({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4, top: 8),
              child: Text(
                title!.tr,
                style: TextStyleCustom.outFitSemiBold600(fontSize: 13, color: textLightGrey(context))
                    .copyWith(letterSpacing: 0.5),
              ),
            ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                subtitle!,
                style: TextStyleCustom.outFitLight300(fontSize: 12, color: textLightGrey(context)),
              ),
            ),
          Container(
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 0.8),
              ),
              color: bgLightGrey(context),
            ),
            child: Column(
              children: _buildChildrenWithDividers(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers(BuildContext context) {
    List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: i == 0 ? const Radius.circular(16) : Radius.zero,
          bottom: i == children.length - 1 ? const Radius.circular(16) : Radius.zero,
        ),
        child: children[i],
      ));
      if (i < children.length - 1) {
        result.add(Padding(
          padding: const EdgeInsets.only(left: 66),
          child: Divider(height: 0.5, thickness: 0.5, color: textLightGrey(context).withValues(alpha: 0.15)),
        ));
      }
    }
    return result;
  }
}
