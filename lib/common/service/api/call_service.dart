import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/call/call_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class CallService {
  CallService._();
  static final CallService instance = CallService._();

  Future<InitiateCallResponse> initiateCall({
    required int callType,
    required List<int> participantIds,
  }) async {
    final param = <String, dynamic>{
      'call_type': callType,
    };
    for (int i = 0; i < participantIds.length; i++) {
      param['participant_ids[$i]'] = participantIds[i];
    }
    return await ApiService.instance.call(
      url: WebService.call.initiateCall,
      fromJson: InitiateCallResponse.fromJson,
      param: param,
    );
  }

  Future<StatusModel> answerCall({required int callId}) async {
    return await ApiService.instance.call(
      url: WebService.call.answerCall,
      fromJson: StatusModel.fromJson,
      param: {'call_id': callId},
    );
  }

  Future<StatusModel> endCall({required int callId}) async {
    return await ApiService.instance.call(
      url: WebService.call.endCall,
      fromJson: StatusModel.fromJson,
      param: {'call_id': callId},
    );
  }

  Future<StatusModel> rejectCall({required int callId}) async {
    return await ApiService.instance.call(
      url: WebService.call.rejectCall,
      fromJson: StatusModel.fromJson,
      param: {'call_id': callId},
    );
  }

  Future<CallHistoryResponse> fetchCallHistory({int? lastItemId}) async {
    final param = <String, dynamic>{'limit': 20};
    if (lastItemId != null) param['last_item_id'] = lastItemId;
    return await ApiService.instance.call(
      url: WebService.call.fetchCallHistory,
      fromJson: CallHistoryResponse.fromJson,
      param: param,
    );
  }

  Future<LiveKitTokenResponse> generateLiveKitToken({
    required String roomName,
    bool canPublish = true,
  }) async {
    return await ApiService.instance.call(
      url: WebService.call.generateLiveKitToken,
      fromJson: LiveKitTokenResponse.fromJson,
      param: {
        'room_name': roomName,
        'can_publish': canPublish ? 1 : 0,
      },
    );
  }
}
