import 'package:get/get.dart';
import 'package:shortzz/common/controller/firebase_firestore_controller.dart';
import 'package:shortzz/model/livestream/app_user.dart';

class ChatThread {
  int? userId;
  String? id;
  int? msgCount;
  ChatType? chatType;
  String? requestType;
  String? lastMsg;
  String? conversationId;
  int? deletedId;
  bool? isDeleted;
  bool? iAmBlocked;
  bool? iBlocked;
  bool? isMuted;
  int? mutedUntil;
  bool? isArchived;
  String? type; // 'direct' or 'group'
  String? groupId;
  GroupData? groupData;
  bool? encryptionEnabled;

  ChatThread({
    this.userId,
    this.id,
    this.msgCount,
    this.chatType,
    this.requestType,
    this.lastMsg,
    this.conversationId,
    this.deletedId,
    this.isDeleted,
    this.iAmBlocked,
    this.iBlocked,
    this.isMuted,
    this.mutedUntil,
    this.isArchived,
    this.type,
    this.groupId,
    this.groupData,
    this.encryptionEnabled,
  });

  ChatThread.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    id = json['id'];
    msgCount = json['msg_count'];
    chatType = ChatType.fromString(json['chat_type']);
    requestType = json['request_type'];
    lastMsg = json['last_msg'];
    conversationId = json['conversation_id'];
    deletedId = json['deleted_id'];
    isDeleted = json['is_deleted'];
    iAmBlocked = json['i_am_blocked'];
    iBlocked = json['i_blocked'];
    isMuted = json['is_muted'] == true;
    mutedUntil = json['muted_until'];
    isArchived = json['is_archived'] == true;
    type = json['type'] ?? 'direct';
    groupId = json['group_id'];
    if (json['group_data'] != null && json['group_data'] is Map) {
      groupData = GroupData.fromJson(Map<String, dynamic>.from(json['group_data']));
    }
    encryptionEnabled = json['encryption_enabled'] == true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['user_id'] = userId;
    data['id'] = id;
    data['msg_count'] = msgCount;
    data['chat_type'] = chatType?.value;
    data['request_type'] = requestType;
    data['last_msg'] = lastMsg;
    data['conversation_id'] = conversationId;
    data['deleted_id'] = deletedId;
    data['is_deleted'] = isDeleted;
    data['i_am_blocked'] = iAmBlocked;
    data['i_blocked'] = iBlocked;
    data['is_muted'] = isMuted;
    data['muted_until'] = mutedUntil;
    data['is_archived'] = isArchived;
    data['type'] = type;
    data['group_id'] = groupId;
    if (groupData != null) data['group_data'] = groupData!.toJson();
    data['encryption_enabled'] = encryptionEnabled;
    return data;
  }

  bool get isGroup => type == 'group';

  // Reactive variable for chat user
  final Rx<AppUser?> _chatUser = Rx<AppUser?>(null);

  /// Plain getter and setter (same type = AppUser?)
  AppUser? get chatUser => _chatUser.value;

  set chatUser(AppUser? user) {
    if (user == null) return;
    _chatUser.value = user; // update reactive value

    final controller = Get.find<FirebaseFirestoreController>();
    final index = controller.users.indexWhere((element) => element.userId == user.userId);

    if (index != -1) {
      controller.users[index] = user;
    } else {
      controller.users.add(user);
    }
  }

  /// Expose Rx version for reactive UI (`Obx`)
  Rx<AppUser?> get chatUserRx => _chatUser;

  /// Initialize and auto-sync with controller
  void bindChatUser() {
    final controller = Get.find<FirebaseFirestoreController>();

    void updateUser() {
      final appUser = controller.users.firstWhereOrNull((element) => element.userId == userId);

      if (appUser == null) {
        // Fetch from REST and add to controller cache
        controller.fetchUserIfNeeded(userId ?? -1);
      }
      _chatUser.value = appUser;
    }

    // React when users list changes
    ever(controller.users, (_) => updateUser());

    // Initial call
    updateUser();
  }
}

enum ChatType {
  request('request'),
  approved('approved');

  final String value;

  const ChatType(this.value);

  static ChatType fromString(String value) {
    return ChatType.values.firstWhereOrNull((e) => e.value == value) ??
        ChatType.approved;
  }
}

class GroupData {
  String? name;
  String? avatar;
  String? description;
  List<int>? adminIds;
  List<int>? memberIds;
  int? memberCount;
  int? createdBy;

  GroupData({
    this.name,
    this.avatar,
    this.description,
    this.adminIds,
    this.memberIds,
    this.memberCount,
    this.createdBy,
  });

  GroupData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    avatar = json['avatar'];
    description = json['description'];
    adminIds = json['admin_ids'] != null
        ? List<int>.from(json['admin_ids'])
        : null;
    memberIds = json['member_ids'] != null
        ? List<int>.from(json['member_ids'])
        : null;
    memberCount = json['member_count'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatar': avatar,
        'description': description,
        'admin_ids': adminIds,
        'member_ids': memberIds,
        'member_count': memberCount,
        'created_by': createdBy,
      };
}
