import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FeedPollView extends StatelessWidget {
  final CreateFeedScreenController controller;

  const FeedPollView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                children: [
                  Icon(Icons.poll_outlined,
                      size: 20, color: themeAccentSolid(context)),
                  const SizedBox(width: 8),
                  Text(
                    'Create Poll',
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 15, color: textDarkGrey(context)),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: controller.resetPoll,
                    child: Icon(Icons.close,
                        size: 20, color: textLightGrey(context)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Question input
              TextField(
                controller: controller.pollQuestionController,
                maxLength: 500,
                maxLines: 2,
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 15, color: textDarkGrey(context)),
                decoration: InputDecoration(
                  hintText: 'Ask a question...',
                  hintStyle: TextStyleCustom.outFitRegular400(
                      fontSize: 15, color: textLightGrey(context)),
                  filled: true,
                  fillColor: bgMediumGrey(context),
                  counterStyle: TextStyleCustom.outFitRegular400(
                      fontSize: 11, color: textLightGrey(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 8),

              // Option inputs
              ...controller.pollOptionControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final optController = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: optController,
                          maxLength: 200,
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 14, color: textDarkGrey(context)),
                          decoration: InputDecoration(
                            hintText: 'Option ${index + 1}',
                            hintStyle: TextStyleCustom.outFitRegular400(
                                fontSize: 14, color: textLightGrey(context)),
                            filled: true,
                            fillColor: bgMediumGrey(context),
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      if (controller.pollOptionControllers.length > 2)
                        InkWell(
                          onTap: () => controller.removePollOption(index),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(Icons.remove_circle_outline,
                                size: 20, color: textLightGrey(context)),
                          ),
                        ),
                    ],
                  ),
                );
              }),

              // Add option button
              if (controller.pollOptionControllers.length < 6)
                InkWell(
                  onTap: controller.addPollOption,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline,
                            size: 18, color: themeAccentSolid(context)),
                        const SizedBox(width: 6),
                        Text(
                          'Add option',
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 13, color: themeAccentSolid(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Settings row
              Row(
                children: [
                  // Allow multiple votes
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.pollAllowMultiple.toggle(),
                      child: Row(
                        children: [
                          Obx(() => Icon(
                                controller.pollAllowMultiple.value
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 20,
                                color: controller.pollAllowMultiple.value
                                    ? themeAccentSolid(context)
                                    : textLightGrey(context),
                              )),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Multiple answers',
                              style: TextStyleCustom.outFitRegular400(
                                  fontSize: 13, color: textDarkGrey(context)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // End time
                  InkWell(
                    onTap: controller.onPollEndTimeTap,
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 18, color: textLightGrey(context)),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                              controller.pollEndsAt.value != null
                                  ? DateFormat('MMM d, h:mm a')
                                      .format(controller.pollEndsAt.value!)
                                  : 'Set end time',
                              style: TextStyleCustom.outFitRegular400(
                                  fontSize: 13,
                                  color: controller.pollEndsAt.value != null
                                      ? themeAccentSolid(context)
                                      : textLightGrey(context)),
                            )),
                        if (controller.pollEndsAt.value != null) ...[
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: controller.clearPollEndTime,
                            child: Icon(Icons.close,
                                size: 16, color: textLightGrey(context)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
