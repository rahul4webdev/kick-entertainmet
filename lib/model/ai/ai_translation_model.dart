class AiTranslateTextModel {
  bool? status;
  String? message;
  AiTranslateTextData? data;

  AiTranslateTextModel({this.status, this.message, this.data});

  AiTranslateTextModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? AiTranslateTextData.fromJson(json['data']) : null;
  }
}

class AiTranslateTextData {
  String? original;
  String? translated;
  String? targetLanguage;

  AiTranslateTextData({this.original, this.translated, this.targetLanguage});

  AiTranslateTextData.fromJson(Map<String, dynamic> json) {
    original = json['original'];
    translated = json['translated'];
    targetLanguage = json['target_language'];
  }
}

class AiTranslateCaptionsModel {
  bool? status;
  String? message;
  AiTranslateCaptionsData? data;

  AiTranslateCaptionsModel({this.status, this.message, this.data});

  AiTranslateCaptionsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? AiTranslateCaptionsData.fromJson(json['data'])
        : null;
  }
}

class AiTranslateCaptionsData {
  List<TranslatedCaption>? captions;
  String? targetLanguage;

  AiTranslateCaptionsData({this.captions, this.targetLanguage});

  AiTranslateCaptionsData.fromJson(Map<String, dynamic> json) {
    targetLanguage = json['target_language'];
    if (json['captions'] != null) {
      captions = (json['captions'] as List)
          .map((e) => TranslatedCaption.fromJson(e))
          .toList();
    }
  }
}

class TranslatedCaption {
  int? startMs;
  int? endMs;
  String? text;

  TranslatedCaption({this.startMs, this.endMs, this.text});

  TranslatedCaption.fromJson(Map<String, dynamic> json) {
    startMs = json['start_ms'];
    endMs = json['end_ms'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() => {
        'start_ms': startMs,
        'end_ms': endMs,
        'text': text,
      };
}
