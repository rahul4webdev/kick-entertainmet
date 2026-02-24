import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/gift_wallet/earnings_summary_model.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class TopSupportersList extends StatelessWidget {
  final List<TopSupporter> supporters;

  const TopSupportersList({super.key, required this.supporters});

  @override
  Widget build(BuildContext context) {
    if (supporters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(LKey.noSupporters.tr,
              style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 14)),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: supporters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final supporter = supporters[index];
          return _SupporterItem(supporter: supporter);
        },
      ),
    );
  }
}

class _SupporterItem extends StatelessWidget {
  final TopSupporter supporter;

  const _SupporterItem({required this.supporter});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomImage(
          image: supporter.profilePhoto,
          size: const Size(56, 56),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            supporter.username ?? '',
            style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context), fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AssetRes.icCoin, width: 14, height: 14),
            const SizedBox(width: 3),
            Text(
              (supporter.totalCoins ?? 0).numberFormat,
              style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
