import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/ai/ai_chat_message.dart';
import 'package:shortzz/model/general/status_model.dart';

class AiChatService {
  AiChatService._();

  static final AiChatService instance = AiChatService._();

  Future<AiChatSendModel> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    AiChatSendModel response = await ApiService.instance.call(
      url: WebService.aiChat.sendMessage,
      fromJson: AiChatSendModel.fromJson,
      param: {
        'message': message,
        'session_id': sessionId,
      },
    );
    return response;
  }

  Future<AiChatMessageListModel> fetchHistory({
    String? sessionId,
    int? beforeId,
    int? limit,
  }) async {
    AiChatMessageListModel response = await ApiService.instance.call(
      url: WebService.aiChat.fetchHistory,
      fromJson: AiChatMessageListModel.fromJson,
      param: {
        'session_id': sessionId,
        'before_id': beforeId,
        'limit': limit ?? 20,
      },
    );
    return response;
  }

  Future<AiChatSessionListModel> fetchSessions() async {
    AiChatSessionListModel response = await ApiService.instance.call(
      url: WebService.aiChat.fetchSessions,
      fromJson: AiChatSessionListModel.fromJson,
    );
    return response;
  }

  Future<StatusModel> clearHistory({String? sessionId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.aiChat.clearHistory,
      fromJson: StatusModel.fromJson,
      param: {'session_id': sessionId},
    );
    return response;
  }

  Future<AiBotInfoModel> fetchBotInfo() async {
    AiBotInfoModel response = await ApiService.instance.call(
      url: WebService.aiChat.botInfo,
      fromJson: AiBotInfoModel.fromJson,
    );
    return response;
  }
}
