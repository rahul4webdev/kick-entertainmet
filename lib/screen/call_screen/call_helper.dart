import 'package:get/get.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/call_service.dart';
import 'package:shortzz/model/call/call_model.dart';
import 'package:shortzz/screen/call_screen/call_screen.dart';

class CallHelper {
  CallHelper._();

  /// Initiate a 1-on-1 call
  static Future<void> startCall({
    required int userId,
    required String fullname,
    String? username,
    String? profilePhoto,
    required int callType, // 1=voice, 2=video
  }) async {
    final response = await CallService.instance.initiateCall(
      callType: callType,
      participantIds: [userId],
    );

    if (response.status != true || response.data == null) {
      Loggers.error('Failed to initiate call');
      return;
    }

    final callData = IncomingCallData(
      callId: response.data!.callId ?? 0,
      roomId: response.data!.roomId ?? '',
      callerId: SessionManager.instance.getUserID(),
      callerName: fullname,
      callerUsername: username,
      callerProfile: profilePhoto,
      callType: callType,
    );

    Get.to(() => CallScreen(callData: callData, isOutgoing: true));
  }

  /// Handle incoming call from push notification
  static void handleIncomingCall(IncomingCallData callData) {
    Get.to(() => CallScreen(callData: callData, isOutgoing: false));
  }
}
