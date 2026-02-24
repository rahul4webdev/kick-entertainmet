class SharedAccessListModel {
  bool? status;
  String? message;
  List<SharedAccess>? data;

  SharedAccessListModel({this.status, this.message, this.data});

  SharedAccessListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List).map((e) => SharedAccess.fromJson(e)).toList();
    }
  }
}

class SharedAccessModel {
  bool? status;
  String? message;
  SharedAccess? data;

  SharedAccessModel({this.status, this.message, this.data});

  SharedAccessModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = SharedAccess.fromJson(json['data']);
    }
  }
}

class SharedAccess {
  int? id;
  int? accountUserId;
  int? memberUserId;
  int role;
  int status;
  Map<String, dynamic>? permissions;
  int? invitedBy;
  String? createdAt;
  TeamMemberUser? member;
  TeamMemberUser? accountOwner;

  SharedAccess({
    this.id,
    this.accountUserId,
    this.memberUserId,
    this.role = 3,
    this.status = 0,
    this.permissions,
    this.invitedBy,
    this.createdAt,
    this.member,
    this.accountOwner,
  });

  SharedAccess.fromJson(Map<String, dynamic> json)
      : role = json['role'] ?? 3,
        status = json['status'] ?? 0 {
    id = json['id'];
    accountUserId = json['account_user_id'];
    memberUserId = json['member_user_id'];
    permissions = json['permissions'] != null
        ? Map<String, dynamic>.from(json['permissions'])
        : null;
    invitedBy = json['invited_by'];
    createdAt = json['created_at'];
    if (json['member'] != null) {
      member = TeamMemberUser.fromJson(json['member']);
    }
    if (json['account_owner'] != null) {
      accountOwner = TeamMemberUser.fromJson(json['account_owner']);
    }
  }

  String get roleLabel {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'Editor';
      case 3:
        return 'Viewer';
      default:
        return 'Unknown';
    }
  }

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Accepted';
      case 2:
        return 'Declined';
      default:
        return 'Unknown';
    }
  }

  bool get isPending => status == 0;
  bool get isAccepted => status == 1;

  bool hasPermission(String key) => permissions?[key] == true;
}

class TeamMemberUser {
  int? id;
  String? username;
  String? fullname;
  String? profilePhoto;
  int? isVerify;

  TeamMemberUser({
    this.id,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.isVerify,
  });

  TeamMemberUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    fullname = json['fullname'];
    profilePhoto = json['profile_photo'];
    isVerify = json['is_verify'];
  }
}
