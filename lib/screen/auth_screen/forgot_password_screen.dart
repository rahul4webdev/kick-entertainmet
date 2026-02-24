import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/common/widget/theme_blur_bg.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/auth_screen/login_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final BaseController baseController = BaseController.share;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // 0 = enter email, 1 = enter code, 2 = new password
  int _step = 0;
  Timer? _resendTimer;
  int _resendSeconds = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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

  Future<void> _sendResetCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      baseController.showSnackBar(LKey.enterEmail.tr);
      return;
    }
    if (!GetUtils.isEmail(email)) {
      baseController.showSnackBar(LKey.invalidEmail.tr);
      return;
    }

    baseController.showLoader();
    final result =
        await UserService.instance.forgotPassword(email: email);
    baseController.stopLoader();

    if (result.status == true) {
      baseController.showSnackBar(
          result.message ?? 'Reset code sent to your email.');
      setState(() => _step = 1);
      _startResendTimer();
    } else {
      baseController.showSnackBar(result.message ?? 'Failed to send code.');
    }
  }

  Future<void> _verifyCode() async {
    final code = codeController.text.trim();
    if (code.length != 6) {
      baseController.showSnackBar('Please enter the 6-digit code.');
      return;
    }

    baseController.showLoader();
    final result = await UserService.instance.verifyResetCode(
      email: emailController.text.trim(),
      code: code,
    );
    baseController.stopLoader();

    if (result.status == true) {
      setState(() => _step = 2);
    } else {
      baseController.showSnackBar(result.message ?? 'Invalid code.');
    }
  }

  Future<void> _resetPassword() async {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty) {
      baseController.showSnackBar(LKey.enterAPassword.tr);
      return;
    }
    if (password.length < 6) {
      baseController.showSnackBar('Password must be at least 6 characters.');
      return;
    }
    if (password != confirmPassword) {
      baseController.showSnackBar(LKey.passwordMismatch.tr);
      return;
    }

    baseController.showLoader();
    final result = await UserService.instance.resetPassword(
      email: emailController.text.trim(),
      code: codeController.text.trim(),
      newPassword: password,
    );
    baseController.stopLoader();

    if (result.status == true) {
      baseController.showSnackBar(
          result.message ?? 'Password reset successful!');
      Get.back(); // Back to login
    } else {
      baseController.showSnackBar(result.message ?? 'Reset failed.');
    }
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
                    onTap: () {
                      if (_step > 0) {
                        setState(() => _step--);
                      } else {
                        Get.back();
                      }
                    },
                    child: Icon(Icons.arrow_back_ios,
                        color: whitePure(context), size: 22),
                  ),
                  const SizedBox(height: 40),
                  if (_step == 0) _buildEmailStep(context),
                  if (_step == 1) _buildCodeStep(context),
                  if (_step == 2) _buildPasswordStep(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password',
          style: TextStyleCustom.unboundedBlack900(
            fontSize: 24,
            color: whitePure(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your email address and we\'ll send you a code to reset your password.',
          style: TextStyleCustom.outFitRegular400(
            fontSize: 15,
            color: whitePure(context).withValues(alpha: .7),
          ),
        ),
        const SizedBox(height: 30),
        LoginSheetTextField(
          hintText: LKey.enterYourEmail.tr,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        TextButtonCustom(
          onTap: _sendResetCode,
          title: 'Send Reset Code',
          btnHeight: 50,
          horizontalMargin: 0,
        ),
      ],
    );
  }

  Widget _buildCodeStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Code',
          style: TextStyleCustom.unboundedBlack900(
            fontSize: 24,
            color: whitePure(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a 6-digit code to\n${emailController.text.trim()}',
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
          onTap: _verifyCode,
          title: 'Verify Code',
          btnHeight: 50,
          horizontalMargin: 0,
        ),
        const SizedBox(height: 24),
        Center(
          child: InkWell(
            onTap: _resendSeconds > 0 ? null : _sendResetCode,
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
    );
  }

  Widget _buildPasswordStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set New Password',
          style: TextStyleCustom.unboundedBlack900(
            fontSize: 24,
            color: whitePure(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your new password below.',
          style: TextStyleCustom.outFitRegular400(
            fontSize: 15,
            color: whitePure(context).withValues(alpha: .7),
          ),
        ),
        const SizedBox(height: 30),
        LoginSheetTextField(
          isPasswordField: true,
          hintText: 'New Password',
          controller: passwordController,
        ),
        const SizedBox(height: 14),
        LoginSheetTextField(
          isPasswordField: true,
          hintText: 'Confirm New Password',
          controller: confirmPasswordController,
        ),
        const SizedBox(height: 24),
        TextButtonCustom(
          onTap: _resetPassword,
          title: 'Reset Password',
          btnHeight: 50,
          horizontalMargin: 0,
        ),
      ],
    );
  }
}
