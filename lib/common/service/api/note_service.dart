import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/notes/user_note_model.dart';

class NoteService {
  NoteService._();
  static final NoteService instance = NoteService._();

  Future<Map<String, dynamic>> createNote({
    required String content,
    String? emoji,
  }) async {
    final param = <String, dynamic>{'content': content};
    if (emoji != null) param['emoji'] = emoji;
    return await ApiService.instance.call(
      url: WebService.notes.createNote,
      param: param,
      fromJson: (json) => json,
    );
  }

  Future<UserNote?> fetchMyNote() async {
    final response = await ApiService.instance.call(
      url: WebService.notes.fetchMyNote,
      param: {},
      fromJson: (json) => json,
    );
    if (response['status'] == true && response['data'] != null) {
      return UserNote.fromJson(Map<String, dynamic>.from(response['data']));
    }
    return null;
  }

  Future<List<UserNote>> fetchFollowerNotes() async {
    final response = await ApiService.instance.call(
      url: WebService.notes.fetchFollowerNotes,
      param: {},
      fromJson: (json) => json,
    );
    if (response['status'] == true && response['data'] != null) {
      final list = response['data'] as List;
      return list
          .map((e) => UserNote.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<StatusModel> deleteNote() async {
    return await ApiService.instance.call(
      url: WebService.notes.deleteNote,
      param: {},
      fromJson: StatusModel.fromJson,
    );
  }
}
