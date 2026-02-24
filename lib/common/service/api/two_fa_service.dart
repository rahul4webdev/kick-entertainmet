import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';

class TwoFaSetupResponse {
  final bool status;
  final String message;
  final String? secret;
  final String? otpAuthUri;
  final List<String>? backupCodes;

  TwoFaSetupResponse({
    required this.status,
    required this.message,
    this.secret,
    this.otpAuthUri,
    this.backupCodes,
  });

  factory TwoFaSetupResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return TwoFaSetupResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      secret: data?['secret'],
      otpAuthUri: data?['otp_auth_uri'],
      backupCodes: data?['backup_codes'] != null
          ? List<String>.from(data!['backup_codes'])
          : null,
    );
  }
}

class TwoFaStatusResponse {
  final bool twoFaEnabled;
  final int backupCodesRemaining;

  TwoFaStatusResponse({
    required this.twoFaEnabled,
    required this.backupCodesRemaining,
  });

  factory TwoFaStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return TwoFaStatusResponse(
      twoFaEnabled: data?['two_fa_enabled'] ?? false,
      backupCodesRemaining: data?['backup_codes_remaining'] ?? 0,
    );
  }
}

class TwoFaLoginResponse {
  final bool status;
  final String message;
  final bool requireTotp;
  final String? temp2faToken;
  final User? user;

  TwoFaLoginResponse({
    required this.status,
    required this.message,
    this.requireTotp = false,
    this.temp2faToken,
    this.user,
  });

  factory TwoFaLoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return TwoFaLoginResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      requireTotp: data?['require_totp'] ?? false,
      temp2faToken: data?['temp_2fa_token'],
      user: data != null && data['id'] != null ? User.fromJson(data) : null,
    );
  }
}

class TwoFaService {
  TwoFaService._();
  static final TwoFaService instance = TwoFaService._();

  Future<TwoFaSetupResponse> setup2FA() async {
    return await ApiService.instance.call(
      url: WebService.twoFa.setup,
      fromJson: TwoFaSetupResponse.fromJson,
    );
  }

  Future<StatusModel> confirm2FA({required String code}) async {
    return await ApiService.instance.call(
      url: WebService.twoFa.confirm,
      param: {'code': code},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> disable2FA({required String code}) async {
    return await ApiService.instance.call(
      url: WebService.twoFa.disable,
      param: {'code': code},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<UserModel> verifyTOTP({
    required String tempToken,
    required String code,
  }) async {
    return await ApiService.instance.call(
      url: WebService.twoFa.verifyTOTP,
      param: {'temp_token': tempToken, 'code': code},
      cancelAuthToken: true,
      fromJson: UserModel.fromJson,
    );
  }

  Future<UserModel> verifyBackupCode({
    required String tempToken,
    required String backupCode,
  }) async {
    return await ApiService.instance.call(
      url: WebService.twoFa.verifyBackupCode,
      param: {'temp_token': tempToken, 'backup_code': backupCode},
      cancelAuthToken: true,
      fromJson: UserModel.fromJson,
    );
  }

  Future<TwoFaSetupResponse> regenerateBackupCodes({
    required String code,
  }) async {
    return await ApiService.instance.call(
      url: WebService.twoFa.regenerateBackupCodes,
      param: {'code': code},
      fromJson: TwoFaSetupResponse.fromJson,
    );
  }

  Future<TwoFaStatusResponse> get2FAStatus() async {
    return await ApiService.instance.call(
      url: WebService.twoFa.status,
      fromJson: TwoFaStatusResponse.fromJson,
    );
  }
}
