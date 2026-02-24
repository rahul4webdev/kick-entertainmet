class InstagramMediaModel {
  bool? status;
  String? message;
  InstagramMediaData? data;

  InstagramMediaModel({this.status, this.message, this.data});

  InstagramMediaModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? InstagramMediaData.fromJson(json['data'])
        : null;
  }
}

class InstagramMediaData {
  List<InstagramMedia>? media;
  String? nextCursor;

  InstagramMediaData({this.media, this.nextCursor});

  InstagramMediaData.fromJson(Map<String, dynamic> json) {
    if (json['media'] != null) {
      media = <InstagramMedia>[];
      json['media'].forEach((v) {
        media!.add(InstagramMedia.fromJson(v));
      });
    }
    nextCursor = json['next_cursor'];
  }
}

class InstagramMedia {
  String? id;
  String? mediaType;
  String? mediaUrl;
  String? thumbnailUrl;
  String? caption;
  String? timestamp;
  String? permalink;
  bool? isImported;
  bool isSelected = false;

  InstagramMedia({
    this.id,
    this.mediaType,
    this.mediaUrl,
    this.thumbnailUrl,
    this.caption,
    this.timestamp,
    this.permalink,
    this.isImported,
  });

  InstagramMedia.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mediaType = json['media_type'];
    mediaUrl = json['media_url'];
    thumbnailUrl = json['thumbnail_url'];
    caption = json['caption'];
    timestamp = json['timestamp'];
    permalink = json['permalink'];
    isImported = json['is_imported'] == true;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media_type': mediaType,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'caption': caption,
      'timestamp': timestamp,
      'permalink': permalink,
    };
  }
}

class InstagramConnectionModel {
  bool? status;
  String? message;
  InstagramConnectionData? data;

  InstagramConnectionModel({this.status, this.message, this.data});

  InstagramConnectionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? InstagramConnectionData.fromJson(json['data'])
        : null;
  }
}

class InstagramConnectionData {
  bool isConnected;
  String? instagramUserId;
  bool autoSyncEnabled;
  String? tokenExpiresAt;
  String? lastSyncAt;
  bool tokenExpired;

  InstagramConnectionData({
    this.isConnected = false,
    this.instagramUserId,
    this.autoSyncEnabled = false,
    this.tokenExpiresAt,
    this.lastSyncAt,
    this.tokenExpired = false,
  });

  InstagramConnectionData.fromJson(Map<String, dynamic> json)
      : isConnected = json['is_connected'] == true,
        instagramUserId = json['instagram_user_id'],
        autoSyncEnabled = json['auto_sync_enabled'] == true,
        tokenExpiresAt = json['token_expires_at'],
        lastSyncAt = json['last_sync_at'],
        tokenExpired = json['token_expired'] == true;
}
