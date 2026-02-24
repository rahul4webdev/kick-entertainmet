import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CreatePollSheet extends StatefulWidget {
  final LivestreamScreenController controller;

  const CreatePollSheet({super.key, required this.controller});

  @override
  State<CreatePollSheet> createState() => _CreatePollSheetState();
}

class _CreatePollSheetState extends State<CreatePollSheet> {
  final questionController = TextEditingController();
  final List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    questionController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void addOption() {
    if (optionControllers.length >= 6) return;
    setState(() {
      optionControllers.add(TextEditingController());
    });
  }

  void removeOption(int index) {
    if (optionControllers.length <= 2) return;
    setState(() {
      optionControllers[index].dispose();
      optionControllers.removeAt(index);
    });
  }

  void onCreatePoll() {
    final question = questionController.text.trim();
    if (question.isEmpty) return;

    final options = optionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (options.length < 2) {
      widget.controller.showSnackBar(LKey.minTwoOptions);
      return;
    }

    widget.controller.createPoll(question, options);
    widget.controller.showSnackBar(LKey.pollCreated);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: scaffoldBackgroundColor(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: bgMediumGrey(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LKey.createPoll,
              style: TextStyleCustom.unboundedMedium500(
                  fontSize: 18, color: textDarkGrey(context)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: LKey.pollQuestion,
                hintStyle: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context), fontSize: 15),
                filled: true,
                fillColor: bgLightGrey(context),
                border: OutlineInputBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 12, cornerSmoothing: 1),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyleCustom.outFitRegular400(
                  color: textDarkGrey(context), fontSize: 15),
            ),
            const SizedBox(height: 12),
            ...List.generate(optionControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: optionControllers[index],
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: InputDecoration(
                          hintText: '${LKey.option} ${index + 1}',
                          hintStyle: TextStyleCustom.outFitLight300(
                              color: textLightGrey(context), fontSize: 14),
                          filled: true,
                          fillColor: bgLightGrey(context),
                          border: OutlineInputBorder(
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 10, cornerSmoothing: 1),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        style: TextStyleCustom.outFitRegular400(
                            color: textDarkGrey(context), fontSize: 14),
                      ),
                    ),
                    if (optionControllers.length > 2)
                      IconButton(
                        onPressed: () => removeOption(index),
                        icon: Icon(Icons.remove_circle_outline,
                            color: Colors.red, size: 20),
                      ),
                  ],
                ),
              );
            }),
            if (optionControllers.length < 6)
              TextButton.icon(
                onPressed: addOption,
                icon: Icon(Icons.add, size: 18, color: themeAccentSolid(context)),
                label: Text(
                  LKey.addOption,
                  style: TextStyleCustom.outFitMedium500(
                      color: themeAccentSolid(context), fontSize: 13),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onCreatePoll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeAccentSolid(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 12, cornerSmoothing: 1),
                  ),
                ),
                child: Text(
                  LKey.startPoll,
                  style: TextStyleCustom.unboundedMedium500(
                      fontSize: 15, color: whitePure(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
