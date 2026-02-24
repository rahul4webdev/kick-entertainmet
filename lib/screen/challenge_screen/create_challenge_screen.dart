import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/screen/challenge_screen/challenge_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CreateChallengeScreen extends StatelessWidget {
  const CreateChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateChallengeController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: 'Create Challenge'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(context, 'Title'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    context,
                    controller: controller.titleController,
                    hint: 'Challenge title',
                    maxLength: 200,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(context, 'Description'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    context,
                    controller: controller.descriptionController,
                    hint: 'Describe the challenge...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(context, 'Hashtag'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    context,
                    controller: controller.hashtagController,
                    hint: 'e.g. DanceChallenge',
                    maxLength: 100,
                    prefix: '#',
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(context, 'Rules (optional)'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    context,
                    controller: controller.rulesController,
                    hint: 'Challenge rules...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel(context, 'Start Date'),
                  const SizedBox(height: 6),
                  Obx(() => _DatePickerTile(
                        value: controller.startsAt.value,
                        hint: 'Select start date',
                        onTap: () => _pickDate(context, controller.startsAt),
                      )),
                  const SizedBox(height: 16),
                  _buildLabel(context, 'End Date'),
                  const SizedBox(height: 6),
                  Obx(() => _DatePickerTile(
                        value: controller.endsAt.value,
                        hint: 'Select end date',
                        onTap: () => _pickDate(context, controller.endsAt),
                      )),
                  const SizedBox(height: 16),
                  _buildLabel(context, 'Prize Type'),
                  const SizedBox(height: 6),
                  Obx(() => Row(
                        children: [
                          _PrizeTypeChip(
                            label: 'None',
                            isSelected: controller.prizeType.value == 0,
                            onTap: () => controller.prizeType.value = 0,
                          ),
                          const SizedBox(width: 8),
                          _PrizeTypeChip(
                            label: 'Coins',
                            isSelected: controller.prizeType.value == 1,
                            onTap: () => controller.prizeType.value = 1,
                          ),
                          const SizedBox(width: 8),
                          _PrizeTypeChip(
                            label: 'Badge',
                            isSelected: controller.prizeType.value == 2,
                            onTap: () => controller.prizeType.value = 2,
                          ),
                        ],
                      )),
                  Obx(() {
                    if (controller.prizeType.value == 1) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildLabel(context, 'Prize Amount (coins)'),
                          const SizedBox(height: 6),
                          _buildTextField(
                            context,
                            controller: controller.prizeAmountController,
                            hint: 'e.g. 1000',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 32),
                  // Create button
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.isCreating.value
                              ? null
                              : () async {
                                  final success =
                                      await controller.createChallenge();
                                  if (success) {
                                    Get.back();
                                    // Refresh challenge list if exists
                                    if (Get.isRegistered<
                                        ChallengeScreenController>()) {
                                      Get.find<ChallengeScreenController>()
                                          .fetchChallenges();
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeAccentSolid(context),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isCreating.value
                              ? const CupertinoActivityIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Create Challenge',
                                  style: TextStyleCustom.outFitSemiBold600(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      )),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyleCustom.outFitMedium500(
          fontSize: 14, color: textDarkGrey(context)),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    String? prefix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: TextStyleCustom.outFitRegular400(
          fontSize: 14, color: textDarkGrey(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleCustom.outFitRegular400(
            fontSize: 14, color: textLightGrey(context)),
        prefixText: prefix,
        prefixStyle: TextStyleCustom.outFitMedium500(
            fontSize: 14, color: themeAccentSolid(context)),
        filled: true,
        fillColor: bgLightGrey(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        counterText: '',
      ),
    );
  }

  Future<void> _pickDate(
      BuildContext context, Rxn<DateTime> target) async {
    final date = await showDatePicker(
      context: context,
      initialDate: target.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      target.value = date;
    }
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgLightGrey(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null
                    ? '${value!.day}/${value!.month}/${value!.year}'
                    : hint,
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 14,
                  color: value != null
                      ? textDarkGrey(context)
                      : textLightGrey(context),
                ),
              ),
            ),
            Icon(Icons.calendar_today_outlined,
                size: 18, color: textLightGrey(context)),
          ],
        ),
      ),
    );
  }
}

class _PrizeTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PrizeTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? themeAccentSolid(context)
              : themeAccentSolid(context).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyleCustom.outFitMedium500(
            fontSize: 13,
            color: isSelected ? Colors.white : themeAccentSolid(context),
          ),
        ),
      ),
    );
  }
}
