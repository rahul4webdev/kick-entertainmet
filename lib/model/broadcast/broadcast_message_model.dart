class BroadcastMessage {
  int? id;
  int? channelId;
  int? userId;
  String? messageType;
  String? textMessage;
  String? imageMessage;
  String? videoMessage;
  String? audioMessage;
  String? postMessage;
  String? waveData;

  BroadcastMessage({
    this.id,
    this.channelId,
    this.userId,
    this.messageType,
    this.textMessage,
    this.imageMessage,
    this.videoMessage,
    this.audioMessage,
    this.postMessage,
    this.waveData,
  });

  BroadcastMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    channelId = json['channel_id'];
    userId = json['user_id'];
    messageType = json['message_type'] ?? 'text';
    textMessage = json['text_message'];
    imageMessage = json['image_message'];
    videoMessage = json['video_message'];
    audioMessage = json['audio_message'];
    postMessage = json['post_message'];
    waveData = json['wave_data'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'user_id': userId,
      'message_type': messageType,
      'text_message': textMessage,
      'image_message': imageMessage,
      'video_message': videoMessage,
      'audio_message': audioMessage,
      'post_message': postMessage,
      'wave_data': waveData,
    };
  }
}
