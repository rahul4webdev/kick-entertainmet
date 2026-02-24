import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/gift_wallet/monetization_status_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class RequirementChecklist extends StatelessWidget {
  final MonetizationRequirements? requirements;
  final int followerCount;
  final int minFollowersRequired;

  const RequirementChecklist({
    super.key,
    required this.requirements,
    required this.followerCount,
    required this.minFollowersRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          side: BorderSide(color: bgGrey(context)),
          borderRadius:
              SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
        ),
        color: bgLightGrey(context),
      ),
      child: Column(
        children: [
          _RequirementRow(
            title: LKey.minFollowersRequired
                .trParams({'count': '$minFollowersRequired'}),
            subtitle: '$followerCount / $minFollowersRequired',
            isMet: requirements?.hasMinFollowers ?? false,
          ),
          Divider(height: 1, color: bgGrey(context)),
          _RequirementRow(
            title: LKey.approvedBusinessAccount.tr,
            isMet: requirements?.hasApprovedBusiness ?? false,
          ),
          Divider(height: 1, color: bgGrey(context)),
          _RequirementRow(
            title: LKey.kycUploaded.tr,
            isMet: requirements?.hasKycUploaded ?? false,
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isMet;

  const _RequirementRow({
    required this.title,
    this.subtitle,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : textLightGrey(context),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 15,
                    color: textDarkGrey(context),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyleCustom.outFitLight300(
                      fontSize: 13,
                      color: textLightGrey(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
