import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SetGiftGoalSheet extends StatefulWidget {
  final LivestreamScreenController controller;

  const SetGiftGoalSheet({super.key, required this.controller});

  @override
  State<SetGiftGoalSheet> createState() => _SetGiftGoalSheetState();
}

class _SetGiftGoalSheetState extends State<SetGiftGoalSheet> {
  final targetController = TextEditingController();
  final labelController = TextEditingController();
  bool hasExistingGoal = false;

  @override
  void initState() {
    super.initState();
    final stream = widget.controller.liveData.value;
    if (stream.giftGoalTarget != null && stream.giftGoalTarget! > 0) {
      hasExistingGoal = true;
      targetController.text = stream.giftGoalTarget.toString();
      labelController.text = stream.giftGoalLabel ?? '';
    }
  }

  @override
  void dispose() {
    targetController.dispose();
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: ShapeDecoration(
            color: whitePure(context),
            shape: const SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.vertical(
                top: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  height: .5,
                  color: textLightGrey(context),
                  width: 80,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Set Gift Goal',
                style: TextStyleCustom.unboundedMedium500(
                    fontSize: 16, color: textDarkGrey(context)),
              ),
              const SizedBox(height: 6),
              Text(
                'Set a coin target for your viewers to help you reach.',
                style: TextStyleCustom.outFitLight300(
                    fontSize: 13, color: textLightGrey(context)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Target Coins',
                  hintText: 'e.g. 5000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Goal Label (optional)',
                  hintText: 'e.g. New Equipment Fund',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (hasExistingGoal)
                    Expanded(
                      child: TextButtonCustom(
                        onTap: () {
                          widget.controller.removeGiftGoal();
                          Get.back();
                        },
                        title: 'Remove',
                        backgroundColor: bgMediumGrey(context),
                      ),
                    ),
                  Expanded(
                    child: TextButtonCustom(
                      onTap: () {
                        final target =
                            int.tryParse(targetController.text.trim());
                        if (target == null || target <= 0) return;
                        final label = labelController.text.trim();
                        widget.controller.setGiftGoal(
                          target,
                          label: label.isNotEmpty ? label : null,
                        );
                        Get.back();
                      },
                      title: 'Set Goal',
                      backgroundColor: themeAccentSolid(context),
                      titleColor: whitePure(context),
                      horizontalMargin: hasExistingGoal ? 5 : 0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ],
    );
  }
}
