import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/story_highlight/story_highlight_model.dart';

class HighlightService {
  HighlightService._();
  static final HighlightService instance = HighlightService._();

  Future<StoryHighlightModel> createHighlight({
    required String name,
    String? coverImage,
    List<int>? storyIds,
  }) async {
    final params = <String, dynamic>{'name': name};
    if (coverImage != null) params['cover_image'] = coverImage;
    if (storyIds != null && storyIds.isNotEmpty) {
      params['story_ids'] = storyIds.join(',');
    }

    return await ApiService.instance.call(
      url: WebService.highlight.createHighlight,
      param: params,
      fromJson: StoryHighlightModel.fromJson,
    );
  }

  Future<List<StoryHighlight>> fetchHighlights({int? userId}) async {
    final params = <String, dynamic>{};
    if (userId != null) params['user_id'] = userId;

    StoryHighlightsModel response = await ApiService.instance.call(
      url: WebService.highlight.fetchHighlights,
      param: params,
      fromJson: StoryHighlightsModel.fromJson,
    );
    return response.data ?? [];
  }

  Future<StoryHighlight?> fetchHighlightById({required int highlightId}) async {
    StoryHighlightModel response = await ApiService.instance.call(
      url: WebService.highlight.fetchHighlightById,
      param: {'highlight_id': highlightId},
      fromJson: StoryHighlightModel.fromJson,
    );
    return response.data;
  }

  Future<StatusModel> updateHighlight({
    required int highlightId,
    String? name,
    String? coverImage,
  }) async {
    final params = <String, dynamic>{'highlight_id': highlightId};
    if (name != null) params['name'] = name;
    if (coverImage != null) params['cover_image'] = coverImage;

    return await ApiService.instance.call(
      url: WebService.highlight.updateHighlight,
      param: params,
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> deleteHighlight({required int highlightId}) async {
    return await ApiService.instance.call(
      url: WebService.highlight.deleteHighlight,
      param: {'highlight_id': highlightId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StoryHighlightModel> addStoryToHighlight({
    required int highlightId,
    required int storyId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.highlight.addStoryToHighlight,
      param: {'highlight_id': highlightId, 'story_id': storyId},
      fromJson: StoryHighlightModel.fromJson,
    );
  }

  Future<StatusModel> removeHighlightItem({required int itemId}) async {
    return await ApiService.instance.call(
      url: WebService.highlight.removeHighlightItem,
      param: {'item_id': itemId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> reorderHighlights({required List<int> highlightIds}) async {
    return await ApiService.instance.call(
      url: WebService.highlight.reorderHighlights,
      param: {'highlight_ids': highlightIds.join(',')},
      fromJson: StatusModel.fromJson,
    );
  }
}
