import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/user_model/user_model.dart';

class AccountService {
  AccountService._();
  static final AccountService instance = AccountService._();

  Future<AccountSwitchResult> switchAccount({
    required int targetUserId,
  }) async {
    final rawJson = await ApiService.instance.call(
      url: WebService.account.switchAccount,
      fromJson: (json) => json,
      param: {
        Params.deviceId: SessionManager.instance.getDeviceId(),
        Params.targetUserId: targetUserId,
      },
    );

    if (rawJson['status'] == true && rawJson['data'] != null) {
      final data = rawJson['data'] as Map<String, dynamic>;
      final authToken = data['auth_token'] as String?;
      final userData = data['user'] != null
          ? User.fromJson(data['user'] as Map<String, dynamic>)
          : null;
      return AccountSwitchResult(
        status: true,
        authToken: authToken,
        user: userData,
      );
    }
    return AccountSwitchResult(
      status: false,
      message: rawJson['message'] ?? 'Switch failed',
    );
  }

  Future<void> removeAccountFromDevice({
    required int targetUserId,
  }) async {
    await ApiService.instance.call(
      url: WebService.account.removeAccountFromDevice,
      fromJson: (json) => json,
      param: {
        Params.deviceId: SessionManager.instance.getDeviceId(),
        Params.targetUserId: targetUserId,
      },
    );
  }
}

class AccountSwitchResult {
  final bool status;
  final String? authToken;
  final User? user;
  final String? message;

  AccountSwitchResult({
    required this.status,
    this.authToken,
    this.user,
    this.message,
  });
}
