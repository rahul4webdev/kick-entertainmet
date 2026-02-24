import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/two_fa_service.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class TwoFaSetupScreen extends StatefulWidget {
  const TwoFaSetupScreen({super.key});

  @override
  State<TwoFaSetupScreen> createState() => _TwoFaSetupScreenState();
}

class _TwoFaSetupScreenState extends State<TwoFaSetupScreen> {
  String? _secret;
  List<String>? _backupCodes;
  bool _isLoading = true;
  bool _isConfirming = false;
  bool _isSetupComplete = false;
  String? _errorMessage;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final result = await TwoFaService.instance.setup2FA();
      if (result.status) {
        setState(() {
          _secret = result.secret;
          _backupCodes = result.backupCodes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Failed to set up 2FA. Please try again';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmSetup() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit code');
      return;
    }

    setState(() {
      _isConfirming = true;
      _errorMessage = null;
    });

    try {
      final result = await TwoFaService.instance.confirm2FA(code: code);
      if (result.status == true) {
        setState(() {
          _isSetupComplete = true;
          _isConfirming = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Invalid code';
          _isConfirming = false;
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Confirmation failed. Please try again';
        _isConfirming = false;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Set Up 2FA',
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isSetupComplete
                ? _buildSuccessView()
                : _buildSetupView(),
      ),
    );
  }

  Widget _buildSetupView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 1: Add to Authenticator',
            style: TextStyleCustom.outFitMedium500(
              color: blackPure(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open your authenticator app (Google Authenticator, Authy, etc.) and add a new account using this key:',
            style: TextStyleCustom.outFitRegular400(
              color: textLightGrey(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgGrey(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SelectableText(
                  _secret ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyleCustom.outFitMedium500(
                    color: blackPure(context),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    if (_secret != null) {
                      Clipboard.setData(ClipboardData(text: _secret!));
                      BaseController.share.showSnackBar('Secret key copied');
                    }
                  },
                  icon: Icon(Icons.copy, size: 16, color: themeAccentSolid(context)),
                  label: Text(
                    'Copy Key',
                    style: TextStyleCustom.outFitRegular400(
                      color: themeAccentSolid(context),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Step 2: Verify Code',
            style: TextStyleCustom.outFitMedium500(
              color: blackPure(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit code from your authenticator app to confirm setup:',
            style: TextStyleCustom.outFitRegular400(
              color: textLightGrey(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
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
            onSubmitted: (_) => _confirmSetup(),
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
              onPressed: _isConfirming ? null : _confirmSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isConfirming
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Enable 2FA',
                      style: TextStyleCustom.outFitMedium500(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.check_circle, size: 64, color: Colors.green[600]),
          const SizedBox(height: 16),
          Text(
            '2FA Enabled Successfully!',
            style: TextStyleCustom.outFitMedium500(
              color: blackPure(context),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save these backup codes in a safe place. You can use them to sign in if you lose access to your authenticator app.',
            textAlign: TextAlign.center,
            style: TextStyleCustom.outFitRegular400(
              color: textLightGrey(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgGrey(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'Backup Codes',
                  style: TextStyleCustom.outFitMedium500(
                    color: blackPure(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                if (_backupCodes != null)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: _backupCodes!.map((code) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scaffoldBackgroundColor(context),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          code,
                          style: TextStyleCustom.outFitMedium500(
                            color: blackPure(context),
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    if (_backupCodes != null) {
                      Clipboard.setData(
                        ClipboardData(text: _backupCodes!.join('\n')),
                      );
                      BaseController.share.showSnackBar('Backup codes copied');
                    }
                  },
                  icon: Icon(Icons.copy, size: 16, color: themeAccentSolid(context)),
                  label: Text(
                    'Copy All Codes',
                    style: TextStyleCustom.outFitRegular400(
                      color: themeAccentSolid(context),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyleCustom.outFitMedium500(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
