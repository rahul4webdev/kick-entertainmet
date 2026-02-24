import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/ai/ai_content_idea_model.dart';

class AiContentIdeasService {
  static final instance = AiContentIdeasService._();

  AiContentIdeasService._();

  Future<AiContentIdeasModel> generateIdeas({
    String? niche,
    int count = 5,
  }) async {
    return await ApiService.instance.call(
      url: WebService.aiContentIdeas.generateIdeas,
      fromJson: AiContentIdeasModel.fromJson,
      param: {
        if (niche != null) 'niche': niche,
        'count': count.toString(),
      },
    );
  }

  Future<TrendingTopicsModel> fetchTrendingTopics() async {
    return await ApiService.instance.call(
      url: WebService.aiContentIdeas.fetchTrendingTopics,
      fromJson: TrendingTopicsModel.fromJson,
      param: {},
    );
  }
}
