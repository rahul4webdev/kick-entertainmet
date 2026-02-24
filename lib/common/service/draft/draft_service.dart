import 'dart:convert';
import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:shortzz/model/draft/draft_post_model.dart';

class DraftService {
  DraftService._();
  static final DraftService instance = DraftService._();

  static const String _draftsKey = 'user_drafts';

  GetStorage get _storage => GetStorage('shortzz');

  List<DraftPost> getDrafts() {
    final raw = _storage.read<String>(_draftsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((e) => DraftPost.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDraft(DraftPost draft) async {
    final drafts = getDrafts();
    final existingIndex = drafts.indexWhere((d) => d.id == draft.id);
    if (existingIndex >= 0) {
      draft.updatedAt = DateTime.now();
      drafts[existingIndex] = draft;
    } else {
      drafts.insert(0, draft);
    }
    await _writeDrafts(drafts);
  }

  Future<void> deleteDraft(String draftId) async {
    final drafts = getDrafts();
    final draft = drafts.firstWhere((d) => d.id == draftId,
        orElse: () => DraftPost(id: '', draftType: 0));
    if (draft.id.isEmpty) return;

    // Clean up media files
    _deleteFileIfExists(draft.contentPath);
    _deleteFileIfExists(draft.thumbnailPath);

    drafts.removeWhere((d) => d.id == draftId);
    await _writeDrafts(drafts);
  }

  Future<void> deleteAllDrafts() async {
    final drafts = getDrafts();
    for (final draft in drafts) {
      _deleteFileIfExists(draft.contentPath);
      _deleteFileIfExists(draft.thumbnailPath);
    }
    await _storage.write(_draftsKey, '[]');
  }

  int get draftCount => getDrafts().length;

  Future<void> _writeDrafts(List<DraftPost> drafts) async {
    final json = jsonEncode(drafts.map((d) => d.toJson()).toList());
    await _storage.write(_draftsKey, json);
  }

  void _deleteFileIfExists(String? path) {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }
}
