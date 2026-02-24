class ScheduledMessageData {
  String? id;
  String? conversationId;
  int? recipientId;
  String? messageType;
  String? textMessage;
  String? imageMessage;
  String? videoMessage;
  String? audioMessage;
  int? scheduledAt;
  int? createdAt;
  String? status;

  ScheduledMessageData({
    this.id,
    this.conversationId,
    this.recipientId,
    this.messageType,
    this.textMessage,
    this.imageMessage,
    this.videoMessage,
    this.audioMessage,
    this.scheduledAt,
    this.createdAt,
    this.status,
  });

  ScheduledMessageData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    conversationId = json['conversation_id'];
    recipientId = json['recipient_id'];
    messageType = json['message_type'];
    textMessage = json['text_message'];
    imageMessage = json['image_message'];
    videoMessage = json['video_message'];
    audioMessage = json['audio_message'];
    scheduledAt = json['scheduled_at'];
    createdAt = json['created_at'];
    status = json['status'];
  }

  DateTime? get scheduledDateTime =>
      scheduledAt != null ? DateTime.fromMillisecondsSinceEpoch(scheduledAt!) : null;

  String get preview {
    switch (messageType) {
      case 'text':
        return textMessage ?? '';
      case 'image':
        return '📷 Photo';
      case 'video':
        return '🎬 Video';
      case 'audio':
        return '🎵 Audio';
      default:
        return textMessage ?? '';
    }
  }
}
