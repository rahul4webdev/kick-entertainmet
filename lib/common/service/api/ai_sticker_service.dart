import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/ai/ai_sticker_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class AiStickerService {
  AiStickerService._();

  static final AiStickerService instance = AiStickerService._();

  Future<AiStickerSingleModel> generateSticker({
    required String prompt,
    bool isPublic = false,
  }) async {
    AiStickerSingleModel response = await ApiService.instance.call(
      url: WebService.aiSticker.generate,
      fromJson: AiStickerSingleModel.fromJson,
      param: {
        'prompt': prompt,
        'is_public': isPublic,
      },
    );
    return response;
  }

  Future<AiStickerListModel> fetchMyStickers({int? limit}) async {
    AiStickerListModel response = await ApiService.instance.call(
      url: WebService.aiSticker.fetchMine,
      fromJson: AiStickerListModel.fromJson,
      param: {'limit': limit ?? 30},
    );
    return response;
  }

  Future<AiStickerListModel> fetchPublicStickers({int? limit}) async {
    AiStickerListModel response = await ApiService.instance.call(
      url: WebService.aiSticker.fetchPublic,
      fromJson: AiStickerListModel.fromJson,
      param: {'limit': limit ?? 30},
    );
    return response;
  }

  Future<StatusModel> incrementUseCount({required int stickerId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.aiSticker.incrementUse,
      fromJson: StatusModel.fromJson,
      param: {'sticker_id': stickerId},
    );
    return response;
  }

  Future<StatusModel> deleteSticker({required int stickerId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.aiSticker.deleteSticker,
      fromJson: StatusModel.fromJson,
      param: {'sticker_id': stickerId},
    );
    return response;
  }
}
