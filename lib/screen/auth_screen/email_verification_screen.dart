import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/functions/debounce_action.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/notification_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/location/location_service.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/common/widget/theme_blur_bg.dart';
import 'package:shortzz/languages/dynamic_translations.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/user_model/user_model.dart' as user;
import 'package:shortzz/screen/dashboard_screen/dashboard_screen.dart';
import 'package:shortzz/screen/interest_selection_screen/interest_selection_screen.dart';
import 'package:shortzz/screen/auth_screen/login_screen.dart';
import 'package:shortzz/screen/two_fa_screen/two_fa_verify_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class EmailVerificationScreen extends StatefulWidget {
  final int userId;
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController codeController = TextEditingController();
  final BaseController baseController = BaseController.share;
  Timer? _resendTimer;
  int _resendSeconds = 0;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    codeController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyCode() async {
    final code = codeController.text.trim();
    if (code.length != 6) {
      baseController.showSnackBar('Please enter the 6-digit code.');
      return;
    }

    setState(() => _isVerifying = true);
    baseController.showLoader();

    try {
      String? deviceToken =
          await FirebaseNotificationManager.instance.getNotificationToken();

      final result = await UserService.instance.verifyEmail(
        userId: widget.userId,
        code: code,
        deviceToken: deviceToken,
      );

      baseController.stopLoader();
      setState(() => _isVerifying = false);

      if (result.containsKey('error')) {
        baseController.showSnackBar(result['error']);
        return;
      }

      if (result['requireTotp'] == true) {
        Get.off(() => TwoFaVerifyScreen(tempToken: result['temp2faToken']));
        return;
      }

      final userData = result['user'] as user.User?;
      if (userData != null) {
        _navigateScreen(userData);
      }
    } catch (e) {
      baseController.stopLoader();
      setState(() => _isVerifying = false);
      Loggers.error(e);
      baseController.showSnackBar('Verification failed. Please try again.');
    }
  }

  Future<void> _resendCode() async {
    if (_resendSeconds > 0) return;

    baseController.showLoader();
    try {
      final result = await UserService.instance
          .resendVerificationCode(userId: widget.userId);
      baseController.stopLoader();

      if (result.status == true) {
        baseController.showSnackBar(result.message ?? 'Code sent!');
        _startResendTimer();
      } else {
        baseController.showSnackBar(result.message ?? 'Failed to send code.');
      }
    } catch (e) {
      baseController.stopLoader();
      baseController.showSnackBar('Failed to resend code.');
    }
  }

  void _navigateScreen(user.User? data) {
    DebounceAction.shared.call(() async {
      SessionManager.instance.setLogin(true);
      SessionManager.instance.setUser(data);

      Setting? setting = SessionManager.instance.getSettings();
      if (data?.isDummy == 0 &&
          data?.newRegister == true &&
          setting?.registrationBonusStatus == 1) {
        final translations = Get.find<DynamicTranslations>();
        final languageData = translations.keys[data?.appLanguage] ?? {};

        NotificationService.instance.pushNotification(
            title: languageData[LKey.registrationBonusTitle] ??
                LKey.registrationBonusTitle.tr,
            body: languageData[LKey.registrationBonusDescription] ??
                LKey.registrationBonusDescription.tr,
            type: NotificationType.other,
            deviceType: data?.device,
            token: data?.deviceToken,
            authorizationToken: data?.token?.authToken);
      }
      SubscriptionManager.shared.login('${data?.id}');

      if (data?.newRegister == true) {
        try {
          await LocationService.instance.getCurrentLocation();
        } catch (_) {}
        Get.offAll(() => DashboardScreen(myUser: data));
        Get.to(() => const InterestSelectionScreen());
      } else {
        Get.offAll(() => DashboardScreen(myUser: data));
      }
    }, milliseconds: 250);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const ThemeBlurBg(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_ios,
                        color: whitePure(context), size: 22),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Verify Your Email',
                    style: TextStyleCustom.unboundedBlack900(
                      fontSize: 24,
                      color: whitePure(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We sent a 6-digit code to\n${widget.email}',
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 15,
                      color: whitePure(context).withValues(alpha: .7),
                    ),
                  ),
                  const SizedBox(height: 30),
                  LoginSheetTextField(
                    hintText: 'Enter 6-digit code',
                    controller: codeController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  TextButtonCustom(
                    onTap: _isVerifying ? () {} : _verifyCode,
                    title: 'Verify',
                    btnHeight: 50,
                    horizontalMargin: 0,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: InkWell(
                      onTap: _resendSeconds > 0 ? null : _resendCode,
                      child: Text(
                        _resendSeconds > 0
                            ? 'Resend code in ${_resendSeconds}s'
                            : 'Resend Code',
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 15,
                          color: _resendSeconds > 0
                              ? whitePure(context).withValues(alpha: .4)
                              : whitePure(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
