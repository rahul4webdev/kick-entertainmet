import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/post_story/post_collaborator_model.dart';

class CollaborationService {
  CollaborationService._();
  static final CollaborationService instance = CollaborationService._();

  Future<StatusModel> inviteCollaborator({
    required int postId,
    required int userId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.collab.inviteCollaborator,
      param: {'post_id': postId, 'user_id': userId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> respondToInvite({
    required int collaborationId,
    required String action, // 'accept' or 'decline'
  }) async {
    return await ApiService.instance.call(
      url: WebService.collab.respondToInvite,
      param: {'collaboration_id': collaborationId, 'action': action},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<List<CollabInvite>> fetchPendingInvites() async {
    final response = await ApiService.instance.call(
      url: WebService.collab.fetchPendingInvites,
      param: {},
      fromJson: (json) => json,
    );
    if (response['status'] == true && response['data'] != null) {
      final list = response['data'] as List;
      return list
          .map((e) => CollabInvite.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<List<PostCollaborator>> fetchPostCollaborators({
    required int postId,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.collab.fetchPostCollaborators,
      param: {'post_id': postId},
      fromJson: (json) => json,
    );
    if (response['status'] == true && response['data'] != null) {
      final list = response['data'] as List;
      return list
          .map((e) => PostCollaborator.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<StatusModel> removeCollaborator({
    required int collaborationId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.collab.removeCollaborator,
      param: {'collaboration_id': collaborationId},
      fromJson: StatusModel.fromJson,
    );
  }
}
