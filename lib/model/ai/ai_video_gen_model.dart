class AiVideoGenModel {
  bool? status;
  String? message;
  AiVideoGenData? data;

  AiVideoGenModel({this.status, this.message, this.data});

  AiVideoGenModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? AiVideoGenData.fromJson(json['data']) : null;
  }
}

class AiVideoGenData {
  String? videoUrl;
  int? duration;

  AiVideoGenData({this.videoUrl, this.duration});

  AiVideoGenData.fromJson(Map<String, dynamic> json) {
    videoUrl = json['video_url'];
    duration = json['duration'];
  }
}
