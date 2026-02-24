import 'dart:convert';

import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';

class StickerService {
  StickerService._();
  static final StickerService instance = StickerService._();

  Future<Map<String, dynamic>> voteOnPoll({
    required int storyId,
    required int optionIndex,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.voteOnPoll,
      param: {'story_id': storyId, 'option_index': optionIndex},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> fetchPollResults({
    required int storyId,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.fetchPollResults,
      param: {'story_id': storyId},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<StatusModel> submitQuestionResponse({
    required int storyId,
    required String responseText,
  }) async {
    return await ApiService.instance.call(
      url: WebService.sticker.submitQuestionResponse,
      param: {'story_id': storyId, 'response': responseText},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<Map<String, dynamic>> fetchQuestionResponses({
    required int storyId,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.fetchQuestionResponses,
      param: {'story_id': storyId},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> answerQuiz({
    required int storyId,
    required int optionIndex,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.answerQuiz,
      param: {'story_id': storyId, 'option_index': optionIndex},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> fetchQuizResults({
    required int storyId,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.fetchQuizResults,
      param: {'story_id': storyId},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> submitSlider({
    required int storyId,
    required double value,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.submitSlider,
      param: {'story_id': storyId, 'value': value},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> fetchSliderResults({
    required int storyId,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.fetchSliderResults,
      param: {'story_id': storyId},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> subscribeCountdown({
    required int storyId,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.subscribeCountdown,
      param: {'story_id': storyId},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> unsubscribeCountdown({
    required int storyId,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.unsubscribeCountdown,
      param: {'story_id': storyId},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> fetchCountdownInfo({
    required int storyId,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.fetchCountdownInfo,
      param: {'story_id': storyId},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> createAddYoursChain({
    required int storyId,
    required String prompt,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.createAddYoursChain,
      param: {'story_id': storyId, 'prompt': prompt},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> participateInChain({
    required int chainId,
    required int storyId,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.participateInChain,
      param: {'chain_id': chainId, 'story_id': storyId},
      fromJson: (json) => json,
    );
    return response;
  }

  Future<Map<String, dynamic>> fetchChainInfo({
    required int chainId,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.sticker.fetchChainInfo,
      param: {'chain_id': chainId},
      fromJson: (json) => json,
    );
    return response;
  }

  /// Encode sticker data for story creation API call
  static String encodeStickerData(Map<String, dynamic> stickerData) {
    return jsonEncode(stickerData);
  }
}
