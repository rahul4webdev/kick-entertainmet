import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/gradient_text.dart';
import 'package:shortzz/common/widget/privacy_policy_text.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/common/widget/text_field_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/auth_screen/auth_screen_controller.dart';
import 'package:shortzz/screen/term_and_privacy_screen/term_and_privacy_screen.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthScreenController>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const CustomBackButton(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
            const SizedBox(height: 10),
            Expanded(
                child: SingleChildScrollView(
              dragStartBehavior: DragStartBehavior.down,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20, top: 40, bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(LKey.signUp.tr.toUpperCase(),
                            style: TextStyleCustom.unboundedBlack900(
                              fontSize: 25,
                              color: textDarkGrey(context),
                            ).copyWith(letterSpacing: -.2)),
                        GradientText(LKey.startJourney.tr.toUpperCase(),
                            gradient: StyleRes.themeGradient,
                            style: TextStyleCustom.unboundedBlack900(
                              fontSize: 25,
                              color: textDarkGrey(context),
                            ).copyWith(letterSpacing: -.2)),
                      ],
                    ),
                  ),
                  TextFieldCustom(
                    controller: controller.fullNameController,
                    title: LKey.fullName.tr,
                  ),
                  TextFieldCustom(
                    controller: controller.emailController,
                    title: LKey.email.tr,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFieldCustom(
                    controller: controller.passwordController,
                    title: LKey.password.tr,
                    isPasswordField: true,
                  ),
                  TextFieldCustom(
                    controller: controller.confirmPassController,
                    title: LKey.reTypePassword.tr,
                    isPasswordField: true,
                  ),
                  // Date of Birth picker
                  _DateOfBirthField(controller: controller),
                  // Terms & Privacy consent checkbox
                  _TermsConsentCheckbox(controller: controller),
                ],
              ),
            )),
            TextButtonCustom(
                onTap: controller.onCreateAccount,
                title: LKey.createAccount.tr,
                backgroundColor: textDarkGrey(context),
                horizontalMargin: 20,
                titleColor: whitePure(context)),
            SizedBox(height: AppBar().preferredSize.height / 1.2),
            const SafeArea(top: false, maintainBottomViewPadding: true, child: PrivacyPolicyText()),
          ],
        ),
      ),
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  final AuthScreenController controller;
  const _DateOfBirthField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Obx(() {
        final dob = controller.selectedDateOfBirth.value;
        return GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dob ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1920),
              lastDate: DateTime.now(),
              helpText: LKey.selectDateOfBirth.tr,
            );
            if (picked != null) {
              controller.selectedDateOfBirth.value = picked;
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: textLightGrey(context).withValues(alpha: .3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dob != null
                        ? DateFormat('dd MMM yyyy').format(dob)
                        : LKey.dateOfBirth.tr,
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 14,
                      color: dob != null
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
      }),
    );
  }
}

class _TermsConsentCheckbox extends StatelessWidget {
  final AuthScreenController controller;
  const _TermsConsentCheckbox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Obx(() => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: controller.termsAccepted.value,
                  onChanged: (v) => controller.termsAccepted.value = v ?? false,
                  activeColor: themeAccentSolid(context),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: LKey.iAgreeToThe.tr,
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 13,
                          color: textLightGrey(context),
                        ),
                      ),
                      TextSpan(
                        text: LKey.termsOfService.tr,
                        style: TextStyleCustom.outFitMedium500(
                          fontSize: 13,
                          color: themeAccentSolid(context),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(() => const TermAndPrivacyScreen(
                                type: TermAndPrivacyType.termAndCondition));
                          },
                      ),
                      TextSpan(
                        text: LKey.andThe.tr,
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 13,
                          color: textLightGrey(context),
                        ),
                      ),
                      TextSpan(
                        text: LKey.privacyPolicy.tr,
                        style: TextStyleCustom.outFitMedium500(
                          fontSize: 13,
                          color: themeAccentSolid(context),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(() => const TermAndPrivacyScreen(
                                type: TermAndPrivacyType.privacyPolicy));
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
