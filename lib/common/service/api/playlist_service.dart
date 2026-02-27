import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/playlist/playlist_model.dart';
import 'package:shortzz/model/post_story/post/posts_model.dart';

class PlaylistService {
  PlaylistService._();
  static final PlaylistService instance = PlaylistService._();

  Future<List<PlaylistItem>> fetchUserPlaylists({required int userId}) async {
    PlaylistListModel response = await ApiService.instance.call(
      url: WebService.playlist.fetchUserPlaylists,
      fromJson: PlaylistListModel.fromJson,
      param: {'user_id': userId},
    );
    return response.data ?? [];
  }

  Future<PlaylistItem?> createPlaylist({
    required String name,
    String? description,
    bool isPublic = true,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.playlist.createPlaylist,
      fromJson: (json) => json,
      param: {
        'name': name,
        if (description != null) 'description': description,
        'is_public': isPublic ? 1 : 0,
      },
    );
    if (response['status'] == true && response['data'] != null) {
      return PlaylistItem.fromJson(response['data']);
    }
    return null;
  }

  Future<StatusModel> updatePlaylist({
    required int playlistId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.playlist.updatePlaylist,
      fromJson: StatusModel.fromJson,
      param: {
        'playlist_id': playlistId,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (isPublic != null) 'is_public': isPublic ? 1 : 0,
      },
    );
    return response;
  }

  Future<StatusModel> deletePlaylist({required int playlistId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.playlist.deletePlaylist,
      fromJson: StatusModel.fromJson,
      param: {'playlist_id': playlistId},
    );
    return response;
  }

  Future<StatusModel> addPostToPlaylist({
    required int playlistId,
    required int postId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.playlist.addPostToPlaylist,
      fromJson: StatusModel.fromJson,
      param: {'playlist_id': playlistId, 'post_id': postId},
    );
    return response;
  }

  Future<StatusModel> removePostFromPlaylist({
    required int playlistId,
    required int postId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.playlist.removePostFromPlaylist,
      fromJson: StatusModel.fromJson,
      param: {'playlist_id': playlistId, 'post_id': postId},
    );
    return response;
  }

  Future<PostsModel> fetchPlaylistPosts({
    required int playlistId,
    int limit = 20,
    int? lastItemId,
  }) async {
    PostsModel response = await ApiService.instance.call(
      url: WebService.playlist.fetchPlaylistPosts,
      fromJson: PostsModel.fromJson,
      param: {
        'playlist_id': playlistId,
        'limit': limit,
        if (lastItemId != null) 'last_item_id': lastItemId,
      },
    );
    return response;
  }
}
