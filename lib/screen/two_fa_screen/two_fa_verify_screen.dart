import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/two_fa_service.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class TwoFaVerifyScreen extends StatefulWidget {
  final String tempToken;

  const TwoFaVerifyScreen({super.key, required this.tempToken});

  @override
  State<TwoFaVerifyScreen> createState() => _TwoFaVerifyScreenState();
}

class _TwoFaVerifyScreenState extends State<TwoFaVerifyScreen> {
  final _codeController = TextEditingController();
  final _backupController = TextEditingController();
  bool _isLoading = false;
  bool _showBackupMode = false;
  String? _errorMessage;

  Future<void> _verifyTOTP() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await TwoFaService.instance.verifyTOTP(
        tempToken: widget.tempToken,
        code: code,
      );

      if (result.status == true && result.data != null) {
        _onVerified(result.data!);
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Invalid code';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyBackup() async {
    final code = _backupController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a backup code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await TwoFaService.instance.verifyBackupCode(
        tempToken: widget.tempToken,
        backupCode: code,
      );

      if (result.status == true && result.data != null) {
        _onVerified(result.data!);
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Invalid backup code';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again';
        _isLoading = false;
      });
    }
  }

  void _onVerified(User user) {
    SessionManager.instance.setUser(user);
    SessionManager.instance.setAuthToken(user.token);
    SessionManager.instance.setLogin(true);
    SubscriptionManager.shared.login('${user.id}');
    Get.offAll(() => const DashboardScreen());
  }

  @override
  void dispose() {
    _codeController.dispose();
    _backupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Two-Factor Authentication',
          style: TextStyleCustom.outFitMedium500(
            color: blackPure(context),
            fontSize: 18,
          ),
        ),
        backgroundColor: scaffoldBackgroundColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: blackPure(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _showBackupMode ? _buildBackupView() : _buildTotpView(),
        ),
      ),
    );
  }

  Widget _buildTotpView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(Icons.security, size: 64, color: themeAccentSolid(context)),
        const SizedBox(height: 24),
        Text(
          'Enter Verification Code',
          style: TextStyleCustom.outFitMedium500(
            color: blackPure(context),
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Open your authenticator app and enter the 6-digit code',
          textAlign: TextAlign.center,
          style: TextStyleCustom.outFitRegular400(
            color: textLightGrey(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: TextStyleCustom.outFitMedium500(
            color: blackPure(context),
            fontSize: 24,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            hintText: '000000',
            hintStyle: TextStyleCustom.outFitRegular400(
              color: textLightGrey(context),
              fontSize: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textLightGrey(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeAccentSolid(context)),
            ),
          ),
          onSubmitted: (_) => _verifyTOTP(),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyleCustom.outFitRegular400(
              color: Colors.red,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyTOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeAccentSolid(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Verify',
                    style: TextStyleCustom.outFitMedium500(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _showBackupMode = true;
              _errorMessage = null;
            });
          },
          child: Text(
            'Use a backup code instead',
            style: TextStyleCustom.outFitRegular400(
              color: themeAccentSolid(context),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackupView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(Icons.vpn_key, size: 64, color: themeAccentSolid(context)),
        const SizedBox(height: 24),
        Text(
          'Enter Backup Code',
          style: TextStyleCustom.outFitMedium500(
            color: blackPure(context),
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter one of your backup codes to sign in',
          textAlign: TextAlign.center,
          style: TextStyleCustom.outFitRegular400(
            color: textLightGrey(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _backupController,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          style: TextStyleCustom.outFitMedium500(
            color: blackPure(context),
            fontSize: 20,
          ),
          decoration: InputDecoration(
            hintText: 'XXXX-XXXX',
            hintStyle: TextStyleCustom.outFitRegular400(
              color: textLightGrey(context),
              fontSize: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textLightGrey(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeAccentSolid(context)),
            ),
          ),
          onSubmitted: (_) => _verifyBackup(),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyleCustom.outFitRegular400(
              color: Colors.red,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyBackup,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeAccentSolid(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Verify',
                    style: TextStyleCustom.outFitMedium500(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _showBackupMode = false;
              _errorMessage = null;
            });
          },
          child: Text(
            'Use authenticator code instead',
            style: TextStyleCustom.outFitRegular400(
              color: themeAccentSolid(context),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
