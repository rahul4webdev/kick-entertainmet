import 'dart:async';

import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/chat/chat_api_service.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/user_model/user_model.dart';

class FirebaseFirestoreController extends BaseController {
  RxList<AppUser> users = <AppUser>[].obs;

  static final instance = FirebaseFirestoreController();

  void fetchUserIfNeeded(int userId) {
    Loggers.info('[LOAD_USER] Checking if user $userId already exists in list');

    final exists = users.any((element) => element.userId == userId);
    if (exists) {
      Loggers.info('[LOAD_USER] User $userId already loaded, skipping fetch');
      return;
    }

    Loggers.info('[LOAD_USER] Fetching user $userId from REST');

    ChatApiService.instance.fetchChatUser(userId).then((appUser) {
      if (appUser != null) {
        users.add(appUser);
        Loggers.info('[LOAD_USER] User ${appUser.userId} added to list');
      } else {
        Loggers.warning('[LOAD_USER] User $userId not found via REST');
      }
    }).catchError((error) {
      Loggers.error('[LOAD_USER] Failed to fetch user $userId — $error');
    });
  }

  void updateUser(User? user) async {
    // No-op: Firestore sync removed, user data managed via REST API
  }

  void addUser(User? user) async {
    // No-op: Firestore sync removed, user data managed via REST API
  }

  Future<void> deleteUser(int? userId) async {
    // No-op: Firestore sync removed, user data managed via REST API
  }
}
