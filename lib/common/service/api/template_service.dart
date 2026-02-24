import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/template/template_model.dart';

class TemplateService {
  TemplateService._();
  static final TemplateService instance = TemplateService._();

  Future<TemplateResponse> fetchTemplates({
    String? category,
    String? source,
    int? lastItemId,
  }) async {
    final param = <String, dynamic>{'limit': 20};
    if (category != null) param['category'] = category;
    if (source != null) param['source'] = source;
    if (lastItemId != null) param['last_item_id'] = lastItemId;
    return await ApiService.instance.call(
      url: WebService.template.fetchTemplates,
      fromJson: TemplateResponse.fromJson,
      param: param,
    );
  }

  Future<SingleTemplateResponse> fetchTemplateById({
    required int templateId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.template.fetchTemplateById,
      fromJson: SingleTemplateResponse.fromJson,
      param: {'template_id': templateId},
    );
  }

  Future<StatusModel> incrementTemplateUse({
    required int templateId,
    int? postId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.template.incrementTemplateUse,
      fromJson: StatusModel.fromJson,
      param: {
        'template_id': templateId,
        if (postId != null) 'post_id': postId,
      },
    );
  }

  Future<SingleTemplateResponse> createUserTemplate({
    required String name,
    required int clipCount,
    required int durationSec,
    String? description,
    int? sourcePostId,
    String? category,
    String? thumbnail,
    String? previewVideo,
    String? clipsJson,
    String? transitionData,
  }) async {
    return await ApiService.instance.call(
      url: WebService.template.createUserTemplate,
      fromJson: SingleTemplateResponse.fromJson,
      param: {
        'name': name,
        'clip_count': clipCount,
        'duration_sec': durationSec,
        if (description != null) 'description': description,
        if (sourcePostId != null) 'source_post_id': sourcePostId,
        if (category != null) 'category': category,
        if (thumbnail != null) 'thumbnail': thumbnail,
        if (previewVideo != null) 'preview_video': previewVideo,
        if (clipsJson != null) 'clips_json': clipsJson,
        if (transitionData != null) 'transition_data': transitionData,
      },
    );
  }

  Future<TemplateResponse> fetchTrendingTemplates({
    int? lastItemId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.template.fetchTrendingTemplates,
      fromJson: TemplateResponse.fromJson,
      param: {
        'limit': 20,
        if (lastItemId != null) 'last_item_id': lastItemId,
      },
    );
  }

  Future<StatusModel> likeTemplate({required int templateId}) async {
    return await ApiService.instance.call(
      url: WebService.template.likeTemplate,
      fromJson: StatusModel.fromJson,
      param: {'template_id': templateId},
    );
  }
}
