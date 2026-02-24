import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';

class AddPostStoryService {
  AddPostStoryService._();

  static final AddPostStoryService instance = AddPostStoryService._();

  Future<PostModel> addPostFeedText({required Map<String, dynamic> param}) async {
    PostModel model = await ApiService.instance.call(
        url: WebService.addPostStory.addPostFeedText, param: param, fromJson: PostModel.fromJson);
    return model;
  }

  Future<PostModel> addPostFeedImage({required Map<String, dynamic> param}) async {
    PostModel model = await ApiService.instance.call(
        url: WebService.addPostStory.addPostFeedImage, param: param, fromJson: PostModel.fromJson);
    return model;
  }

  Future<PostModel> addPostFeedVideo({required Map<String, dynamic> param}) async {
    PostModel model = await ApiService.instance.call(
        url: WebService.addPostStory.addPostFeedVideo, param: param, fromJson: PostModel.fromJson);
    return model;
  }

  Future<PostModel> addPostReel({required Map<String, dynamic> param}) async {
    PostModel model = await ApiService.instance.call(url: WebService.addPostStory.addPostReel, param: param, fromJson: PostModel.fromJson);
    return model;
  }

  // Content type uploads
  Future<PostModel> addPostMusicVideo({required Map<String, dynamic> param}) async {
    return await ApiService.instance.call(
        url: WebService.content.addPostMusicVideo, param: param, fromJson: PostModel.fromJson);
  }

  Future<PostModel> addPostTrailer({required Map<String, dynamic> param}) async {
    return await ApiService.instance.call(
        url: WebService.content.addPostTrailer, param: param, fromJson: PostModel.fromJson);
  }

  Future<PostModel> addPostNews({required Map<String, dynamic> param}) async {
    return await ApiService.instance.call(
        url: WebService.content.addPostNews, param: param, fromJson: PostModel.fromJson);
  }
}
