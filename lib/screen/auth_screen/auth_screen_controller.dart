import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/functions/debounce_action.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/common_service.dart';
import 'package:shortzz/common/service/api/notification_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/languages/dynamic_translations.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/user_model/user_model.dart' as user;
import 'package:shortzz/screen/auth_screen/email_verification_screen.dart';
import 'package:shortzz/screen/auth_screen/forgot_password_screen.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen.dart';
import 'package:shortzz/screen/interest_selection_screen/interest_selection_screen.dart';
import 'package:shortzz/common/service/location/location_service.dart';
import 'package:shortzz/screen/two_fa_screen/two_fa_verify_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthScreenController extends BaseController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController forgetEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  // Compliance
  Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);
  RxBool termsAccepted = false.obs;

  @override
  void onInit() {
    CommonService.instance.fetchGlobalSettings();
    FirebaseNotificationManager.instance;
    super.onInit();
  }

  /// Login with email and password (custom backend auth).
  Future<void> onLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      return showSnackBar(LKey.enterEmail.tr);
    }
    if (password.isEmpty) {
      return showSnackBar(LKey.enterAPassword.tr);
    }

    showLoader();

    String? deviceToken =
        await FirebaseNotificationManager.instance.getNotificationToken();

    if (deviceToken == null) {
      stopLoader();
      return showSnackBar('Unable to get device token. Please try again.');
    }

    // Check if it's a dummy user login (non-email identity)
    if (!GetUtils.isEmail(email)) {
      // Legacy dummy user login
      LoginResult loginResult = await UserService.instance.logInFakeUser(
        identity: email,
        loginMethod: LoginMethod.email,
        deviceToken: deviceToken,
        password: password,
      );
      stopLoader();
      if (loginResult.requireTotp && loginResult.temp2faToken != null) {
        Get.to(() => TwoFaVerifyScreen(tempToken: loginResult.temp2faToken!));
        return;
      }
      if (loginResult.user != null) {
        _navigateScreen(loginResult.user);
      }
      return;
    }

    // Custom auth: email + password login
    try {
      final result = await UserService.instance.loginWithEmail(
        email: email,
        password: password,
        deviceToken: deviceToken,
      );
      stopLoader();

      if (result.containsKey('error')) {
        showSnackBar(result['error']);
        return;
      }

      if (result['requireEmailVerification'] == true) {
        Get.to(() => EmailVerificationScreen(
              userId: result['userId'],
              email: result['email'],
            ));
        return;
      }

      if (result['requireTotp'] == true) {
        Get.to(() => TwoFaVerifyScreen(tempToken: result['temp2faToken']));
        return;
      }

      final userData = result['user'] as user.User?;
      if (userData != null) {
        _navigateScreen(userData);
      }
    } catch (e) {
      stopLoader();
      Loggers.error(e);
      showSnackBar('Login failed. Please try again.');
    }
  }

  /// Create account with email and password.
  Future<void> onCreateAccount() async {
    if (fullNameController.text.trim().isEmpty) {
      return showSnackBar(LKey.fullNameEmpty.tr);
    }
    if (emailController.text.trim().isEmpty) {
      return showSnackBar(LKey.enterEmail.tr);
    }
    if (passwordController.text.trim().isEmpty) {
      return showSnackBar(LKey.enterAPassword.tr);
    }
    if (confirmPassController.text.trim().isEmpty) {
      return showSnackBar(LKey.confirmPasswordEmpty.tr);
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      return showSnackBar(LKey.invalidEmail.tr);
    }
    if (passwordController.text.trim() != confirmPassController.text.trim()) {
      return showSnackBar(LKey.passwordMismatch.tr);
    }
    if (selectedDateOfBirth.value == null) {
      return showSnackBar(LKey.dobRequired.tr);
    }
    if (!termsAccepted.value) {
      return showSnackBar(LKey.termsRequired.tr);
    }

    showLoader();

    String? deviceToken;
    try {
      deviceToken =
          await FirebaseNotificationManager.instance.getNotificationToken();
    } catch (e) {
      debugPrint('[REGISTER] Failed to get device token: $e');
    }
    deviceToken ??= 'no_token';

    try {
      debugPrint('[REGISTER] Calling registerWithEmail...');
      final dob = selectedDateOfBirth.value!;
      final dobStr = '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';
      final result = await UserService.instance.registerWithEmail(
        fullname: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        dateOfBirth: dobStr,
        deviceToken: deviceToken,
      );
      stopLoader();
      debugPrint('[REGISTER] Result: $result');

      if (result.containsKey('error')) {
        showSnackBar(result['error']);
        return;
      }

      if (result['requireEmailVerification'] == true) {
        Get.back(); // Close registration screen
        Get.to(() => EmailVerificationScreen(
              userId: result['userId'],
              email: result['email'],
            ));
        return;
      }

      if (result['requireTotp'] == true) {
        Get.to(() => TwoFaVerifyScreen(tempToken: result['temp2faToken']));
        return;
      }

      final userData = result['user'] as user.User?;
      if (userData != null) {
        Get.back(); // Close registration screen
        _navigateScreen(userData);
      }
    } catch (e, stack) {
      stopLoader();
      debugPrint('[REGISTER] Exception: $e');
      debugPrint('[REGISTER] Stack: $stack');
      Loggers.error(e);
      showSnackBar('Registration failed. Please try again.');
    }
  }

  /// Google Sign-In (direct — no Firebase Auth).
  void onGoogleTap() async {
    showLoader();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      googleSignIn.initialize();
      GoogleSignInAccount account = await googleSignIn.authenticate();

      String? idToken = account.authentication.idToken;
      if (idToken == null) {
        stopLoader();
        showSnackBar('Google sign-in failed. Please try again.');
        return;
      }

      String? deviceToken =
          await FirebaseNotificationManager.instance.getNotificationToken();

      if (deviceToken == null) {
        stopLoader();
        return showSnackBar('Unable to get device token. Please try again.');
      }

      final result = await UserService.instance.loginWithGoogle(
        idToken: idToken,
        deviceToken: deviceToken,
      );
      stopLoader();

      if (result.containsKey('error')) {
        showSnackBar(result['error']);
        return;
      }

      if (result['requireTotp'] == true) {
        Get.to(() => TwoFaVerifyScreen(tempToken: result['temp2faToken']));
        return;
      }

      final userData = result['user'] as user.User?;
      if (userData != null) {
        _navigateScreen(userData);
      }
    } catch (e) {
      stopLoader();
      Loggers.error(e);
    }
  }

  /// Apple Sign-In (direct — no Firebase Auth).
  void onAppleTap() async {
    showLoader();

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        stopLoader();
        showSnackBar('Apple sign-in failed. Please try again.');
        return;
      }

      String? fullname;
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        fullname =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
      }

      String? deviceToken =
          await FirebaseNotificationManager.instance.getNotificationToken();

      if (deviceToken == null) {
        stopLoader();
        return showSnackBar('Unable to get device token. Please try again.');
      }

      final result = await UserService.instance.loginWithApple(
        identityToken: appleCredential.identityToken!,
        authorizationCode: appleCredential.authorizationCode,
        fullname: fullname,
        deviceToken: deviceToken,
      );
      stopLoader();

      if (result.containsKey('error')) {
        showSnackBar(result['error']);
        return;
      }

      if (result['requireTotp'] == true) {
        Get.to(() => TwoFaVerifyScreen(tempToken: result['temp2faToken']));
        return;
      }

      final userData = result['user'] as user.User?;
      if (userData != null) {
        _navigateScreen(userData);
      }
    } catch (e) {
      stopLoader();
      Loggers.error(e);
    }
  }

  /// Navigate to forgot password screen.
  void forgetPassword() {
    Get.to(() => const ForgotPasswordScreen());
  }

  void _navigateScreen(user.User? data) {
    DebounceAction.shared.call(() async {
      SessionManager.instance.setLogin(true);
      SessionManager.instance.setUser(data);

      // Store multi-account session locally
      if (data != null && data.id != null && data.token?.authToken != null) {
        SessionManager.instance.addAccountSession(
          userId: data.id!.toInt(),
          authToken: data.token!.authToken!,
          fullname: data.fullname ?? '',
          username: data.username ?? '',
          profilePhoto: data.profilePhoto,
        );
      }

      // Send registration bonus notification
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

      // Request location on new registration
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
}
