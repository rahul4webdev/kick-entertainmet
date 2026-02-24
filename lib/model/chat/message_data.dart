import 'package:get/get.dart';
import 'package:shortzz/common/controller/firebase_firestore_controller.dart';
import 'package:shortzz/model/livestream/app_user.dart';

class MessageReaction {
  int? userId;
  String? emoji;
  int? createdAt;

  MessageReaction({this.userId, this.emoji, this.createdAt});

  MessageReaction.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    emoji = json['emoji'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'emoji': emoji,
        'created_at': createdAt,
      };
}

class ReplyTo {
  int? messageId;
  int? userId;
  String? textPreview;
  String? messageType;

  ReplyTo({this.messageId, this.userId, this.textPreview, this.messageType});

  ReplyTo.fromJson(Map<String, dynamic> json) {
    messageId = json['message_id'];
    userId = json['user_id'];
    textPreview = json['text_preview'];
    messageType = json['message_type'];
  }

  Map<String, dynamic> toJson() => {
        'message_id': messageId,
        'user_id': userId,
        'text_preview': textPreview,
        'message_type': messageType,
      };
}

class LinkPreview {
  String? url;
  String? title;
  String? description;
  String? image;
  String? domain;

  LinkPreview(
      {this.url, this.title, this.description, this.image, this.domain});

  LinkPreview.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    domain = json['domain'];
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'description': description,
        'image': image,
        'domain': domain,
      };
}

class DocumentMessage {
  String? url;
  String? filename;
  int? size;
  String? mimeType;

  DocumentMessage({this.url, this.filename, this.size, this.mimeType});

  DocumentMessage.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    filename = json['filename'];
    size = json['size'];
    mimeType = json['mime_type'];
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'filename': filename,
        'size': size,
        'mime_type': mimeType,
      };
}

class MessageData {
  int? id;
  int? userId;
  MessageType? messageType;
  String? textMessage;
  String? imageMessage;
  String? videoMessage;
  String? audioMessage;
  String? postMessage;
  String? storyReplyMessage;
  String? conversationId;
  bool? iBlocked;
  bool? iAmBlocked;
  List<int>? noDeleteIds;
  String? waveData;
  List<MessageReaction>? reactions;
  int? editedAt;
  bool? isVanish;

  // W1a: Read receipts + delivery
  String? status; // 'sent', 'delivered', 'read'
  int? deliveredAt;
  int? readAt;

  // W1b: Reply to specific message
  ReplyTo? replyTo;

  // W1c: Link preview
  LinkPreview? linkPreview;

  // W2a: Forwarded
  bool? forwarded;

  // W3a: Document message
  DocumentMessage? documentMessage;

  // W4a: Group chat sender name
  String? senderName;

  // W5: E2E encryption
  bool? isEncrypted;
  int? encryptionVersion;

  MessageData(
      {this.userId,
      this.id,
      this.messageType,
      this.textMessage,
      this.imageMessage,
      this.videoMessage,
      this.audioMessage,
      this.postMessage,
      this.storyReplyMessage,
      this.conversationId,
      this.iBlocked,
      this.iAmBlocked,
      this.noDeleteIds,
      this.waveData,
      this.reactions,
      this.editedAt,
      this.isVanish,
      this.status,
      this.deliveredAt,
      this.readAt,
      this.replyTo,
      this.linkPreview,
      this.forwarded,
      this.documentMessage,
      this.senderName,
      this.isEncrypted,
      this.encryptionVersion});

  MessageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    messageType = MessageType.fromString(json['message_type']);
    textMessage = json['text_message'];
    imageMessage = json['image_message'];
    videoMessage = json['video_message'];
    audioMessage = json['audio_message'];
    postMessage = json['post_message'];
    storyReplyMessage = json['story_reply_message'];
    conversationId = json['conversation_id'];
    iBlocked = json['i_blocked'];
    iAmBlocked = json['i_am_blocked'];
    waveData = json['wave_data'];
    if (json['no_delete_ids'] != null) {
      noDeleteIds = [];
      json['no_delete_ids'].forEach((v) {
        noDeleteIds?.add(v);
      });
    }
    editedAt = json['edited_at'];
    isVanish = json['is_vanish'] == true;
    if (json['reactions'] != null) {
      reactions = [];
      json['reactions'].forEach((v) {
        reactions?.add(MessageReaction.fromJson(Map<String, dynamic>.from(v)));
      });
    }

    // W1a: Read receipts + delivery
    status = json['status'];
    deliveredAt = json['delivered_at'];
    readAt = json['read_at'];

    // W1b: Reply
    if (json['reply_to'] != null && json['reply_to'] is Map) {
      final replyMap = Map<String, dynamic>.from(json['reply_to']);
      if (replyMap['message_id'] != null) {
        replyTo = ReplyTo.fromJson(replyMap);
      }
    }

    // W1c: Link preview
    if (json['link_preview'] != null && json['link_preview'] is Map) {
      final previewMap = Map<String, dynamic>.from(json['link_preview']);
      if (previewMap['url'] != null) {
        linkPreview = LinkPreview.fromJson(previewMap);
      }
    }

    // W2a: Forwarded
    forwarded = json['forwarded'] == true;

    // W3a: Document
    if (json['document_message'] != null && json['document_message'] is Map) {
      documentMessage = DocumentMessage.fromJson(
          Map<String, dynamic>.from(json['document_message']));
    }

    // W4a: Group sender name
    senderName = json['sender_name'];

    // W5: E2E encryption
    isEncrypted = json['is_encrypted'] == true;
    encryptionVersion = json['encryption_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['message_type'] = messageType?.value;
    data['text_message'] = textMessage;
    data['image_message'] = imageMessage;
    data['video_message'] = videoMessage;
    data['audio_message'] = audioMessage;
    data['post_message'] = postMessage;
    data['story_reply_message'] = storyReplyMessage;
    data['conversation_id'] = conversationId;
    data['i_blocked'] = iBlocked;
    data['i_am_blocked'] = iAmBlocked;
    data['wave_data'] = waveData;
    data['no_delete_ids'] = noDeleteIds?.map((e) => e).toList();
    data['reactions'] = reactions?.map((e) => e.toJson()).toList();
    data['edited_at'] = editedAt;
    data['is_vanish'] = isVanish;
    data['status'] = status;
    data['delivered_at'] = deliveredAt;
    data['read_at'] = readAt;
    if (replyTo != null) data['reply_to'] = replyTo!.toJson();
    if (linkPreview != null) data['link_preview'] = linkPreview!.toJson();
    data['forwarded'] = forwarded;
    if (documentMessage != null) {
      data['document_message'] = documentMessage!.toJson();
    }
    data['sender_name'] = senderName;
    data['is_encrypted'] = isEncrypted;
    data['encryption_version'] = encryptionVersion;
    return data;
  }

  AppUser? get chatUser {
    final controller = Get.find<FirebaseFirestoreController>();
    return controller.users
        .firstWhereOrNull((element) => element.userId == userId);
  }
}

enum MessageType {
  text('text'),
  image('image'),
  video('video'),
  post('post'),
  gift('gift'),
  audio('audio'),
  gif('gif'),
  storyReply('story_reply'),
  document('document');

  final String value;

  const MessageType(this.value);

  static MessageType fromString(String value) {
    return MessageType.values.firstWhereOrNull(
          (e) => e.value == value,
        ) ??
        MessageType.text;
  }
}

enum StoryReplyType {
  text('text'),
  gift('gift');

  final String value;

  const StoryReplyType(this.value);

  static StoryReplyType fromString(String value) {
    return StoryReplyType.values.firstWhereOrNull(
          (e) => e.value == value,
        ) ??
        StoryReplyType.text;
  }
}
