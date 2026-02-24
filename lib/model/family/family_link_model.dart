class FamilyLinkedAccountsModel {
  bool? status;
  String? message;
  FamilyLinkedData? data;

  FamilyLinkedAccountsModel({this.status, this.message, this.data});

  FamilyLinkedAccountsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = FamilyLinkedData.fromJson(json['data']);
    }
  }
}

class FamilyLinkedData {
  List<FamilyLink>? linkedTeens;
  List<FamilyLink>? linkedParents;

  FamilyLinkedData({this.linkedTeens, this.linkedParents});

  FamilyLinkedData.fromJson(Map<String, dynamic> json) {
    if (json['linked_teens'] != null) {
      linkedTeens =
          (json['linked_teens'] as List).map((e) => FamilyLink.fromJson(e)).toList();
    }
    if (json['linked_parents'] != null) {
      linkedParents =
          (json['linked_parents'] as List).map((e) => FamilyLink.fromJson(e)).toList();
    }
  }
}

class FamilyLinkModel {
  bool? status;
  String? message;
  FamilyLink? data;

  FamilyLinkModel({this.status, this.message, this.data});

  FamilyLinkModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = FamilyLink.fromJson(json['data']);
    }
  }
}

class PairingCodeModel {
  bool? status;
  String? message;
  PairingCodeData? data;

  PairingCodeModel({this.status, this.message, this.data});

  PairingCodeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = PairingCodeData.fromJson(json['data']);
    }
  }
}

class PairingCodeData {
  String? pairingCode;
  int? id;

  PairingCodeData({this.pairingCode, this.id});

  PairingCodeData.fromJson(Map<String, dynamic> json) {
    pairingCode = json['pairing_code'];
    id = json['id'];
  }
}

class MyControlsModel {
  bool? status;
  String? message;
  MyControlsData? data;

  MyControlsModel({this.status, this.message, this.data});

  MyControlsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = MyControlsData.fromJson(json['data']);
    }
  }
}

class MyControlsData {
  Map<String, dynamic>? controls;
  List<FamilyLink>? linkedParents;
  bool isSupervised;

  MyControlsData({
    this.controls,
    this.linkedParents,
    this.isSupervised = false,
  });

  MyControlsData.fromJson(Map<String, dynamic> json)
      : isSupervised = json['is_supervised'] ?? false {
    if (json['controls'] != null) {
      controls = Map<String, dynamic>.from(json['controls']);
    }
    if (json['linked_parents'] != null) {
      linkedParents =
          (json['linked_parents'] as List).map((e) => FamilyLink.fromJson(e)).toList();
    }
  }
}

class ActivityReportModel {
  bool? status;
  String? message;
  ActivityReportData? data;

  ActivityReportModel({this.status, this.message, this.data});

  ActivityReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = ActivityReportData.fromJson(json['data']);
    }
  }
}

class ActivityReportData {
  FamilyUser? teen;
  int totalPosts;
  int followerCount;
  int followingCount;
  Map<String, dynamic>? controls;

  ActivityReportData({
    this.teen,
    this.totalPosts = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.controls,
  });

  ActivityReportData.fromJson(Map<String, dynamic> json)
      : totalPosts = json['total_posts'] ?? 0,
        followerCount = json['follower_count'] ?? 0,
        followingCount = json['following_count'] ?? 0 {
    if (json['teen'] != null) {
      teen = FamilyUser.fromJson(json['teen']);
    }
    if (json['controls'] != null) {
      controls = Map<String, dynamic>.from(json['controls']);
    }
  }
}

class FamilyLink {
  int? id;
  int? parentUserId;
  int? teenUserId;
  String? pairingCode;
  int status;
  Map<String, dynamic>? controls;
  String? createdAt;
  FamilyUser? parent;
  FamilyUser? teen;

  FamilyLink({
    this.id,
    this.parentUserId,
    this.teenUserId,
    this.pairingCode,
    this.status = 0,
    this.controls,
    this.createdAt,
    this.parent,
    this.teen,
  });

  FamilyLink.fromJson(Map<String, dynamic> json) : status = json['status'] ?? 0 {
    id = json['id'];
    parentUserId = json['parent_user_id'];
    teenUserId = json['teen_user_id'];
    pairingCode = json['pairing_code'];
    if (json['controls'] != null) {
      controls = Map<String, dynamic>.from(json['controls']);
    }
    createdAt = json['created_at'];
    if (json['parent'] != null) {
      parent = FamilyUser.fromJson(json['parent']);
    }
    if (json['teen'] != null) {
      teen = FamilyUser.fromJson(json['teen']);
    }
  }

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Linked';
      case 2:
        return 'Unlinked';
      default:
        return 'Unknown';
    }
  }

  bool get isLinked => status == 1;

  int get dailyScreenTimeMin => (controls?['daily_screen_time_min'] as num?)?.toInt() ?? 60;
  bool get dmRestricted => controls?['dm_restricted'] == true;
  bool get liveRestricted => controls?['live_restricted'] == true;
  bool get discoverRestricted => controls?['discover_restricted'] == true;
  bool get purchaseRestricted => controls?['purchase_restricted'] == true;
  bool get liveStreamRestricted => controls?['live_stream_restricted'] == true;
  bool get activityReports => controls?['activity_reports'] == true;
}

class FamilyUser {
  int? id;
  String? username;
  String? fullname;
  String? profilePhoto;
  int? isVerify;

  FamilyUser({
    this.id,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.isVerify,
  });

  FamilyUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    fullname = json['fullname'];
    profilePhoto = json['profile_photo'];
    isVerify = json['is_verify'];
  }
}
