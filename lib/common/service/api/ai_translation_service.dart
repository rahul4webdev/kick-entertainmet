import 'dart:convert';

import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/ai/ai_translation_model.dart';

class AiTranslationService {
  static final instance = AiTranslationService._();

  AiTranslationService._();

  Future<AiTranslateTextModel> translateText({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    return await ApiService.instance.call(
      url: WebService.aiTranslation.translateText,
      fromJson: AiTranslateTextModel.fromJson,
      param: {
        'text': text,
        'target_language': targetLanguage,
        if (sourceLanguage != null) 'source_language': sourceLanguage,
      },
    );
  }

  Future<AiTranslateCaptionsModel> translateCaptions({
    required List<Map<String, dynamic>> captions,
    required String targetLanguage,
  }) async {
    return await ApiService.instance.call(
      url: WebService.aiTranslation.translateCaptions,
      fromJson: AiTranslateCaptionsModel.fromJson,
      param: {
        'captions': jsonEncode(captions),
        'target_language': targetLanguage,
      },
    );
  }
}
