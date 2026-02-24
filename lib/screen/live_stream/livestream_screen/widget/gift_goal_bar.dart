import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class GiftGoalBar extends StatelessWidget {
  final LivestreamScreenController controller;

  const GiftGoalBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Livestream stream = controller.liveData.value;
      int? target = stream.giftGoalTarget;
      if (target == null || target <= 0) return const SizedBox();

      int current = stream.giftGoalCurrent ?? 0;
      double progress = (current / target).clamp(0.0, 1.0);
      bool isGoalReached = current >= target;
      String label = stream.giftGoalLabel ?? 'Gift Goal';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: ShapeDecoration(
            color: blackPure(context).withValues(alpha: .3),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(cornerRadius: 10),
              side: BorderSide(
                color: isGoalReached
                    ? Colors.amber.withValues(alpha: .6)
                    : whitePure(context).withValues(alpha: .2),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Image.asset(AssetRes.icCoin, height: 14, width: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 11, color: whitePure(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${current.numberFormat} / ${target.numberFormat}',
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 11,
                      color: isGoalReached
                          ? Colors.amber
                          : whitePure(context).withValues(alpha: .8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 6,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor:
                            whitePure(context).withValues(alpha: .15),
                        valueColor: AlwaysStoppedAnimation(
                          isGoalReached
                              ? Colors.amber
                              : const Color(0xFF8B5CF6),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (isGoalReached)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    'Goal Reached!',
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 10, color: Colors.amber),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
