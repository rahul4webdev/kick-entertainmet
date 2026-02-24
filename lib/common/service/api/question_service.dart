import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/qna/question_model.dart';

class QuestionService {
  static final QuestionService instance = QuestionService._();
  QuestionService._();

  Future<List<QuestionItem>> fetchQuestions({
    required int userId,
    int? lastItemId,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      Params.userId: userId,
      Params.limit: limit,
    };
    if (lastItemId != null) params[Params.lastItemId] = lastItemId;

    final result = await ApiService.instance.call(
      url: WebService.post.fetchQuestions,
      param: params,
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data']?['questions'] != null) {
      return (result['data']['questions'] as List)
          .map((q) => QuestionItem.fromJson(q))
          .toList();
    }
    return [];
  }

  Future<QuestionItem?> askQuestion({
    required int userId,
    required String question,
  }) async {
    final result = await ApiService.instance.call(
      url: WebService.post.askQuestion,
      param: {Params.userId: userId, 'question': question},
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data']?['question'] != null) {
      return QuestionItem.fromJson(result['data']['question']);
    }
    return null;
  }

  Future<QuestionItem?> answerQuestion({
    required int questionId,
    required String answer,
  }) async {
    final result = await ApiService.instance.call(
      url: WebService.post.answerQuestion,
      param: {'question_id': questionId, 'answer': answer},
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data']?['question'] != null) {
      return QuestionItem.fromJson(result['data']['question']);
    }
    return null;
  }

  Future<bool> deleteQuestion({required int questionId}) async {
    final result = await ApiService.instance.call(
      url: WebService.post.deleteQuestion,
      param: {'question_id': questionId},
      fromJson: (json) => json,
    );
    return result['status'] == true;
  }

  Future<bool> toggleHideQuestion({required int questionId}) async {
    final result = await ApiService.instance.call(
      url: WebService.post.toggleHideQuestion,
      param: {'question_id': questionId},
      fromJson: (json) => json,
    );
    return result['status'] == true;
  }

  Future<bool> togglePinQuestion({required int questionId}) async {
    final result = await ApiService.instance.call(
      url: WebService.post.togglePinQuestion,
      param: {'question_id': questionId},
      fromJson: (json) => json,
    );
    return result['status'] == true;
  }

  Future<bool> likeQuestion({required int questionId}) async {
    final result = await ApiService.instance.call(
      url: WebService.post.likeQuestion,
      param: {'question_id': questionId},
      fromJson: (json) => json,
    );
    return result['status'] == true;
  }
}
