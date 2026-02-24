import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/ai/ai_video_gen_model.dart';

class AiVideoService {
  static final instance = AiVideoService._();

  AiVideoService._();

  Future<AiVideoGenModel> generateFromText({
    required String prompt,
    int duration = 5,
    String style = 'gradient',
  }) async {
    return await ApiService.instance.call(
      url: WebService.aiVideo.generateFromText,
      fromJson: AiVideoGenModel.fromJson,
      param: {
        'prompt': prompt,
        'duration': duration,
        'style': style,
      },
    );
  }

  Future<AiVideoGenModel> generateFromImage({
    required String imagePath,
    int duration = 5,
    String effect = 'zoom_in',
  }) async {
    return await ApiService.instance.multiPartCallApi(
      url: WebService.aiVideo.generateFromImage,
      fromJson: AiVideoGenModel.fromJson,
      param: {
        'duration': '$duration',
        'effect': effect,
      },
      filesMap: {
        'image': [XFile(imagePath)],
      },
    );
  }
}
