class BroadcastChannelCreator {
  int? id;
  String? username;
  String? fullname;
  String? profilePhoto;
  int? isVerify;

  BroadcastChannelCreator({
    this.id,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.isVerify,
  });

  BroadcastChannelCreator.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    fullname = json['fullname'];
    profilePhoto = json['profile_photo'];
    isVerify = json['is_verify'];
  }
}

class BroadcastChannel {
  int? id;
  String? name;
  String? description;
  String? image;
  int? memberCount;
  int? creatorUserId;
  BroadcastChannelCreator? creator;
  bool isMember;
  bool isMuted;
  bool isCreator;
  String? createdAt;
  String? updatedAt;

  // Local state for UI
  String? lastMsg;
  int? lastMsgTime;
  int unreadCount;

  BroadcastChannel({
    this.id,
    this.name,
    this.description,
    this.image,
    this.memberCount,
    this.creatorUserId,
    this.creator,
    this.isMember = false,
    this.isMuted = false,
    this.isCreator = false,
    this.createdAt,
    this.updatedAt,
    this.lastMsg,
    this.lastMsgTime,
    this.unreadCount = 0,
  });

  BroadcastChannel.fromJson(Map<String, dynamic> json)
      : isMember = json['is_member'] ?? false,
        isMuted = json['is_muted'] ?? false,
        isCreator = json['is_creator'] ?? false,
        unreadCount = 0 {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    memberCount = json['member_count'];
    creatorUserId = json['creator_user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['creator'] != null) {
      creator = BroadcastChannelCreator.fromJson(json['creator']);
    }
  }
}

class BroadcastMember {
  int? userId;
  String? username;
  String? fullname;
  String? profilePhoto;
  int? isVerify;
  String? joinedAt;

  BroadcastMember.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    fullname = json['fullname'];
    profilePhoto = json['profile_photo'];
    isVerify = json['is_verify'];
    joinedAt = json['joined_at'];
  }
}
