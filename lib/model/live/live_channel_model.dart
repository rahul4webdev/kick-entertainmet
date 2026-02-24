class LiveChannelsModel {
  LiveChannelsModel({bool? status, String? message, List<LiveChannel>? data}) {
    _status = status;
    _message = message;
    _data = data;
  }

  LiveChannelsModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(LiveChannel.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<LiveChannel>? _data;

  bool? get status => _status;
  String? get message => _message;
  List<LiveChannel>? get data => _data;
}

class LiveChannel {
  LiveChannel({
    this.id,
    this.userId,
    this.channelName,
    this.channelLogo,
    this.streamUrl,
    this.streamType,
    this.category,
    this.language,
    this.isLive,
    this.isActive,
    this.viewerCount,
    this.sortOrder,
  });

  LiveChannel.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    channelName = json['channel_name'];
    channelLogo = json['channel_logo'];
    streamUrl = json['stream_url'];
    streamType = json['stream_type'];
    category = json['category'];
    language = json['language'];
    isLive = json['is_live'];
    isActive = json['is_active'];
    viewerCount = json['viewer_count'];
    sortOrder = json['sort_order'];
  }

  int? id;
  int? userId;
  String? channelName;
  String? channelLogo;
  String? streamUrl;
  String? streamType;
  String? category;
  String? language;
  bool? isLive;
  bool? isActive;
  int? viewerCount;
  int? sortOrder;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'channel_name': channelName,
      'channel_logo': channelLogo,
      'stream_url': streamUrl,
      'stream_type': streamType,
      'category': category,
      'language': language,
      'is_live': isLive,
      'is_active': isActive,
      'viewer_count': viewerCount,
      'sort_order': sortOrder,
    };
  }
}
