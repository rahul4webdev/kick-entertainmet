class AiVoiceEnhanceModel {
  bool? status;
  String? message;
  AiVoiceEnhanceData? data;

  AiVoiceEnhanceModel({this.status, this.message, this.data});

  AiVoiceEnhanceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? AiVoiceEnhanceData.fromJson(json['data'])
        : null;
  }
}

class AiVoiceEnhanceData {
  String? enhancedUrl;

  AiVoiceEnhanceData({this.enhancedUrl});

  AiVoiceEnhanceData.fromJson(Map<String, dynamic> json) {
    enhancedUrl = json['enhanced_url'];
  }
}
