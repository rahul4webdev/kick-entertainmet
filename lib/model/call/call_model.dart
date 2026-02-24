class CallHistoryResponse {
  bool? status;
  String? message;
  List<CallRecord>? data;

  CallHistoryResponse({this.status, this.message, this.data});

  factory CallHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CallHistoryResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => CallRecord.fromJson(e)).toList()
          : null,
    );
  }
}

class InitiateCallResponse {
  bool? status;
  String? message;
  InitiateCallData? data;

  InitiateCallResponse({this.status, this.message, this.data});

  factory InitiateCallResponse.fromJson(Map<String, dynamic> json) {
    return InitiateCallResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? InitiateCallData.fromJson(json['data'])
          : null,
    );
  }
}

class InitiateCallData {
  int? callId;
  String? roomId;

  InitiateCallData({this.callId, this.roomId});

  factory InitiateCallData.fromJson(Map<String, dynamic> json) {
    return InitiateCallData(
      callId: json['call_id'],
      roomId: json['room_id'],
    );
  }
}

class CallRecord {
  int? id;
  String? roomId;
  int? callerId;
  int? callType; // 1=voice, 2=video
  int? status; // 0=ringing, 1=answered, 2=ended, 3=missed, 4=rejected
  bool? isGroup;
  String? startedAt;
  String? endedAt;
  int? durationSec;
  String? createdAt;
  CallUser? caller;
  List<CallParticipantRecord>? participants;

  CallRecord({
    this.id,
    this.roomId,
    this.callerId,
    this.callType,
    this.status,
    this.isGroup,
    this.startedAt,
    this.endedAt,
    this.durationSec,
    this.createdAt,
    this.caller,
    this.participants,
  });

  factory CallRecord.fromJson(Map<String, dynamic> json) {
    return CallRecord(
      id: json['id'],
      roomId: json['room_id'],
      callerId: json['caller_id'],
      callType: json['call_type'],
      status: json['status'],
      isGroup: json['is_group'] == true || json['is_group'] == 1,
      startedAt: json['started_at'],
      endedAt: json['ended_at'],
      durationSec: json['duration_sec'],
      createdAt: json['created_at'],
      caller: json['caller'] != null ? CallUser.fromJson(json['caller']) : null,
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((e) => CallParticipantRecord.fromJson(e))
              .toList()
          : null,
    );
  }

  bool get isVideoCall => callType == 2;
  bool get isVoiceCall => callType == 1;
  bool get isMissed => status == 3;
  bool get isRejected => status == 4;

  String get durationFormatted {
    if (durationSec == null || durationSec == 0) return '';
    final minutes = durationSec! ~/ 60;
    final seconds = durationSec! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class CallParticipantRecord {
  int? id;
  int? callId;
  int? userId;
  int? status;
  String? joinedAt;
  String? leftAt;
  CallUser? user;

  CallParticipantRecord({
    this.id,
    this.callId,
    this.userId,
    this.status,
    this.joinedAt,
    this.leftAt,
    this.user,
  });

  factory CallParticipantRecord.fromJson(Map<String, dynamic> json) {
    return CallParticipantRecord(
      id: json['id'],
      callId: json['call_id'],
      userId: json['user_id'],
      status: json['status'],
      joinedAt: json['joined_at'],
      leftAt: json['left_at'],
      user: json['user'] != null ? CallUser.fromJson(json['user']) : null,
    );
  }
}

class CallUser {
  int? id;
  String? username;
  String? fullname;
  String? profilePhoto;
  int? isVerify;

  CallUser({
    this.id,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.isVerify,
  });

  factory CallUser.fromJson(Map<String, dynamic> json) {
    return CallUser(
      id: json['id'],
      username: json['username'],
      fullname: json['fullname'],
      profilePhoto: json['profile_photo'],
      isVerify: json['is_verify'],
    );
  }
}

/// Data passed for incoming call notification / Firestore signaling
class IncomingCallData {
  int callId;
  String roomId;
  int callerId;
  String callerName;
  String? callerUsername;
  String? callerProfile;
  int callType; // 1=voice, 2=video
  bool isGroup;

  IncomingCallData({
    required this.callId,
    required this.roomId,
    required this.callerId,
    required this.callerName,
    this.callerUsername,
    this.callerProfile,
    required this.callType,
    this.isGroup = false,
  });

  factory IncomingCallData.fromJson(Map<String, dynamic> json) {
    return IncomingCallData(
      callId: json['call_id'] is String ? int.parse(json['call_id']) : json['call_id'],
      roomId: json['room_id'] ?? '',
      callerId: json['caller_id'] is String ? int.parse(json['caller_id']) : json['caller_id'],
      callerName: json['caller_name'] ?? '',
      callerUsername: json['caller_username'],
      callerProfile: json['caller_profile'],
      callType: json['call_type'] is String ? int.parse(json['call_type']) : (json['call_type'] ?? 1),
      isGroup: json['is_group'] == true || json['is_group'] == '1' || json['is_group'] == 1,
    );
  }

  bool get isVideoCall => callType == 2;
}

class LiveKitTokenResponse {
  bool? status;
  String? message;
  LiveKitTokenData? data;

  LiveKitTokenResponse({this.status, this.message, this.data});

  factory LiveKitTokenResponse.fromJson(Map<String, dynamic> json) {
    return LiveKitTokenResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? LiveKitTokenData.fromJson(json['data'])
          : null,
    );
  }
}

class LiveKitTokenData {
  String? token;
  String? wsUrl;

  LiveKitTokenData({this.token, this.wsUrl});

  factory LiveKitTokenData.fromJson(Map<String, dynamic> json) {
    return LiveKitTokenData(
      token: json['token'],
      wsUrl: json['ws_url'],
    );
  }
}
