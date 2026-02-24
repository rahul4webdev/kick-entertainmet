class AiChatMessageListModel {
  bool? status;
  String? message;
  List<AiChatMessage>? data;

  AiChatMessageListModel({this.status, this.message, this.data});

  AiChatMessageListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(AiChatMessage.fromJson(v));
      });
    }
  }
}

class AiChatSendModel {
  bool? status;
  String? message;
  AiChatMessage? data;

  AiChatSendModel({this.status, this.message, this.data});

  AiChatSendModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? AiChatMessage.fromJson(json['data']) : null;
  }
}

class AiChatMessage {
  int? id;
  String? sessionId;
  String? userMessage;
  String? aiResponse;
  String? createdAt;

  AiChatMessage({
    this.id,
    this.sessionId,
    this.userMessage,
    this.aiResponse,
    this.createdAt,
  });

  AiChatMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sessionId = json['session_id'];
    userMessage = json['user_message'];
    aiResponse = json['ai_response'];
    createdAt = json['created_at'];
  }
}

class AiBotInfoModel {
  bool? status;
  String? message;
  AiBotInfo? data;

  AiBotInfoModel({this.status, this.message, this.data});

  AiBotInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? AiBotInfo.fromJson(json['data']) : null;
  }
}

class AiBotInfo {
  bool? enabled;
  String? botName;
  String? botAvatar;

  AiBotInfo({this.enabled, this.botName, this.botAvatar});

  AiBotInfo.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
    botName = json['bot_name'];
    botAvatar = json['bot_avatar'];
  }
}

class AiChatSessionListModel {
  bool? status;
  String? message;
  List<AiChatSession>? data;

  AiChatSessionListModel({this.status, this.message, this.data});

  AiChatSessionListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(AiChatSession.fromJson(v));
      });
    }
  }
}

class AiChatSession {
  String? sessionId;
  String? firstMessage;
  String? lastActive;
  int? messageCount;

  AiChatSession({
    this.sessionId,
    this.firstMessage,
    this.lastActive,
    this.messageCount,
  });

  AiChatSession.fromJson(Map<String, dynamic> json) {
    sessionId = json['session_id'];
    firstMessage = json['first_message'];
    lastActive = json['last_active'];
    messageCount = json['message_count'];
  }
}
