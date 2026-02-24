import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LivePollOverlay extends StatelessWidget {
  final LivestreamScreenController controller;

  const LivePollOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final poll = controller.activePoll.value;
      if (poll == null) return const SizedBox.shrink();

      final totalVotes = poll.totalVotes;
      final hasVoted = poll.hasVoted(controller.myUserId);
      final isActive = poll.isActive ?? true;
      final isMyPoll = poll.hostId == controller.myUserId;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: blackPure(context).withValues(alpha: .7),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.poll, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    poll.question ?? '',
                    style: TextStyleCustom.outFitMedium500(
                        color: whitePure(context), fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: .3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(LKey.pollEnded,
                        style: TextStyleCustom.outFitLight300(
                            color: Colors.red, fontSize: 10)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(poll.options?.length ?? 0, (index) {
              final option = poll.options![index];
              final votes = option.voterIds?.length ?? 0;
              final pct = totalVotes > 0 ? votes / totalVotes : 0.0;
              final isSelected =
                  poll.votedOptionIndex(controller.myUserId) == index;

              return GestureDetector(
                onTap: (hasVoted || !isActive)
                    ? null
                    : () => controller.votePoll(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  height: 36,
                  decoration: ShapeDecoration(
                    color: whitePure(context).withValues(alpha: .1),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 8, cornerSmoothing: 1),
                      side: isSelected
                          ? const BorderSide(color: Colors.amber, width: 1.5)
                          : BorderSide.none,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (hasVoted || !isActive)
                        FractionallySizedBox(
                          widthFactor: pct,
                          child: Container(
                            decoration: ShapeDecoration(
                              color: Colors.amber.withValues(alpha: .25),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                    cornerRadius: 8, cornerSmoothing: 1),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.text ?? '',
                                style: TextStyleCustom.outFitRegular400(
                                    color: whitePure(context), fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasVoted || !isActive)
                              Text(
                                '${(pct * 100).round()}%',
                                style: TextStyleCustom.outFitMedium500(
                                    color: Colors.amber, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalVotes ${LKey.votes}',
                  style: TextStyleCustom.outFitLight300(
                      color: whitePure(context).withValues(alpha: .6),
                      fontSize: 11),
                ),
                if (isMyPoll && isActive)
                  GestureDetector(
                    onTap: controller.endPoll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: .3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(LKey.endPoll,
                          style: TextStyleCustom.outFitMedium500(
                              color: Colors.red, fontSize: 11)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
