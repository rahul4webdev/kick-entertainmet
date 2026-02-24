class FriendsLocationsResponse {
  bool? status;
  String? message;
  List<FriendLocation>? data;

  FriendsLocationsResponse({this.status, this.message, this.data});

  FriendsLocationsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List)
          .map((e) => FriendLocation.fromJson(e))
          .toList();
    }
  }
}

class SharingStatusResponse {
  bool? status;
  String? message;
  SharingStatusData? data;

  SharingStatusResponse({this.status, this.message, this.data});

  SharingStatusResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = SharingStatusData.fromJson(json['data']);
    }
  }
}

class SharingStatusData {
  bool isSharing;
  double? lat;
  double? lon;
  String? locationUpdatedAt;

  SharingStatusData({
    this.isSharing = false,
    this.lat,
    this.lon,
    this.locationUpdatedAt,
  });

  SharingStatusData.fromJson(Map<String, dynamic> json)
      : isSharing = json['is_sharing'] ?? false {
    lat = (json['lat'] as num?)?.toDouble();
    lon = (json['lon'] as num?)?.toDouble();
    locationUpdatedAt = json['location_updated_at'];
  }
}

class ToggleSharingResponse {
  bool? status;
  String? message;
  ToggleSharingData? data;

  ToggleSharingResponse({this.status, this.message, this.data});

  ToggleSharingResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = ToggleSharingData.fromJson(json['data']);
    }
  }
}

class ToggleSharingData {
  bool isSharing;

  ToggleSharingData({this.isSharing = false});

  ToggleSharingData.fromJson(Map<String, dynamic> json)
      : isSharing = json['is_sharing'] ?? false;
}

class FriendLocation {
  int? userId;
  double? lat;
  double? lon;
  String? locationUpdatedAt;
  FriendLocationUser? user;

  FriendLocation({
    this.userId,
    this.lat,
    this.lon,
    this.locationUpdatedAt,
    this.user,
  });

  FriendLocation.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    lat = (json['lat'] as num?)?.toDouble();
    lon = (json['lon'] as num?)?.toDouble();
    locationUpdatedAt = json['location_updated_at'];
    if (json['user'] != null) {
      user = FriendLocationUser.fromJson(json['user']);
    }
  }
}

class FriendLocationUser {
  int? id;
  String? username;
  String? fullname;
  String? profilePhoto;
  int? isVerify;

  FriendLocationUser({
    this.id,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.isVerify,
  });

  FriendLocationUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    fullname = json['fullname'];
    profilePhoto = json['profile_photo'];
    isVerify = json['is_verify'];
  }
}
