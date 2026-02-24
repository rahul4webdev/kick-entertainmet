import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/ai/ai_voice_enhance_model.dart';

class AiVoiceService {
  static final instance = AiVoiceService._();

  AiVoiceService._();

  Future<AiVoiceEnhanceModel> enhanceAudio({
    required String audioFilePath,
  }) async {
    return await ApiService.instance.multiPartCallApi(
      url: WebService.aiVoice.enhanceAudio,
      fromJson: AiVoiceEnhanceModel.fromJson,
      filesMap: {
        'audio': [XFile(audioFilePath)],
      },
    );
  }

  Future<AiVoiceEnhanceModel> enhanceVideo({
    required String videoFilePath,
  }) async {
    return await ApiService.instance.multiPartCallApi(
      url: WebService.aiVoice.enhanceVideo,
      fromJson: AiVoiceEnhanceModel.fromJson,
      filesMap: {
        'video': [XFile(videoFilePath)],
      },
    );
  }

  Future<AiTranscriptionModel> transcribeAudio({
    required String audioUrl,
  }) async {
    return await ApiService.instance.call(
      url: WebService.aiVoice.transcribeAudio,
      fromJson: AiTranscriptionModel.fromJson,
      param: {
        'audio_url': audioUrl,
      },
    );
  }
}

class AiTranscriptionModel {
  bool? status;
  String? message;
  AiTranscriptionData? data;

  AiTranscriptionModel({this.status, this.message, this.data});

  AiTranscriptionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? AiTranscriptionData.fromJson(json['data'])
        : null;
  }
}

class AiTranscriptionData {
  String? transcription;

  AiTranscriptionData({this.transcription});

  AiTranscriptionData.fromJson(Map<String, dynamic> json) {
    transcription = json['transcription'];
  }
}
