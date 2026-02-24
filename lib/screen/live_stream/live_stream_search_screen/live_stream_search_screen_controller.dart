import 'dart:async';

import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/controller/firebase_firestore_controller.dart';
import 'package:shortzz/common/extensions/list_extension.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/live/livestream_api_service.dart';
import 'package:shortzz/common/service/live/livestream_events.dart';
import 'package:shortzz/common/service/live/livestream_socket_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/live_stream/create_live_stream_screen/create_live_stream_screen.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/audience/live_stream_audience_screen.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/host/livestream_host_screen.dart';

class LiveStreamSearchScreenController extends BaseController {
  RxList<Livestream> livestreamList = <Livestream>[].obs;
  RxList<Livestream> livestreamFilterList = <Livestream>[].obs;

  final firebaseFirestoreController = Get.find<FirebaseFirestoreController>();

  Setting? get setting => SessionManager.instance.getSettings();

  RxList<DummyLive> get dummyLives => (setting?.dummyLives ?? []).obs;

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
    _registerSocketListeners();
  }

  @override
  void onClose() {
    super.onClose();
    _unregisterSocketListeners();
  }

  // ── Initial Load via REST ──────────────────────────────────────────

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    await Future.wait([fetchLiveStreams(), addDummyUsers()]);
    isLoading.value = false;
  }

  Future<void> fetchLiveStreams() async {
    final streams = await LivestreamApiService.instance.fetchActiveLivestreams();

    livestreamList.value = streams;
    livestreamFilterList.value = List.from(streams);
    livestreamFilterList.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

    // Fetch host user data for each stream
    for (var stream in streams) {
      if (stream.hostId != null && stream.hostId != -1) {
        firebaseFirestoreController.fetchUserIfNeeded(stream.hostId ?? -1);
      }
      for (var coHostId in (stream.coHostIds ?? [])) {
        firebaseFirestoreController.fetchUserIfNeeded(coHostId);
      }
    }

    _assignHostUsersToStreams();
    removeDummyLive();
  }

  // ── Real-time Socket.IO Listeners ──────────────────────────────────

  void _registerSocketListeners() {
    LivestreamSocketService.instance.on(LivestreamEvents.sLiveStarted, (data) {
      if (data is Map<String, dynamic>) {
        final stream = Livestream.fromJson(data);
        final roomId = stream.roomID ?? '';
        if (roomId.isEmpty) return;

        // Add if not already present
        if (!livestreamList.any((e) => e.roomID == roomId)) {
          livestreamList.add(stream);
          livestreamFilterList.add(stream);
          livestreamFilterList.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

          if (stream.hostId != null && stream.hostId != -1) {
            firebaseFirestoreController.fetchUserIfNeeded(stream.hostId ?? -1);
          }
          _assignHostUsersToStreams();
        }
      }
    });

    LivestreamSocketService.instance.on(LivestreamEvents.sLiveUpdated, (data) {
      if (data is Map<String, dynamic>) {
        final updated = Livestream.fromJson(data);
        final roomId = updated.roomID ?? '';
        if (roomId.isEmpty) return;

        final idx = livestreamList.indexWhere((e) => e.roomID == roomId);
        if (idx != -1) {
          livestreamList[idx] = updated;
          final fIdx = livestreamFilterList.indexWhere((e) => e.roomID == roomId);
          if (fIdx != -1) livestreamFilterList[fIdx] = updated;
        }

        for (var coHostId in (updated.coHostIds ?? [])) {
          firebaseFirestoreController.fetchUserIfNeeded(coHostId);
        }
        _assignHostUsersToStreams();
      }
    });

    LivestreamSocketService.instance.on(LivestreamEvents.sLiveEnded, (data) {
      if (data is Map<String, dynamic>) {
        final roomId = data['room_id']?.toString() ?? '';
        if (roomId.isEmpty) return;

        livestreamList.removeWhere((e) => e.roomID == roomId);
        livestreamFilterList.removeWhere((e) => e.roomID == roomId);
      }
    });
  }

  void _unregisterSocketListeners() {
    LivestreamSocketService.instance.off(LivestreamEvents.sLiveStarted);
    LivestreamSocketService.instance.off(LivestreamEvents.sLiveUpdated);
    LivestreamSocketService.instance.off(LivestreamEvents.sLiveEnded);
  }

  // ── Helpers ────────────────────────────────────────────────────────

  void _assignHostUsersToStreams() {
    final userMap = _userMapFromList(firebaseFirestoreController.users);
    for (var stream in livestreamList) {
      stream.hostUser = userMap[stream.hostId];
    }
  }

  Map<int, AppUser> _userMapFromList(List<AppUser> list) {
    return {
      for (var user in list)
        if (user.userId != null) user.userId!: user,
    };
  }

  void onLiveUserTap(Livestream stream) async {
    User? myUser = SessionManager.instance.getUser();
    if (stream.hostId == myUser?.id) {
      Get.to(() => LivestreamHostScreen(isHost: true, livestream: stream));
    } else {
      Get.to(() => LiveStreamAudienceScreen(isHost: false, livestream: stream));
    }
  }

  onSearchChange(String value) {
    livestreamFilterList.value = livestreamList.search(value, (p0) {
      return p0.hostUser?.username ?? '';
    }, (p1) => p1.description ?? '');
  }

  // ── Dummy Livestreams via REST ─────────────────────────────────────

  Future<void> addDummyUsers() async {
    try {
      // Get existing active livestream IDs from already-loaded list
      final existingIds = livestreamList.map((e) => e.roomID ?? '').toSet();

      for (var dummy in dummyLives) {
        final dummyId = dummy.userId;
        if (dummyId == -1) continue;

        final alreadyExists = existingIds.contains('$dummyId');
        if (!alreadyExists && dummy.status == 1) {
          await createLiveStream(dummy);
          Loggers.info('Created dummy livestream: $dummyId');
        } else if (alreadyExists && dummy.status == 0) {
          await deleteStreamOnFirebase(dummyId);
          Loggers.info('Deleted inactive dummy livestream: $dummyId');
        }
      }
    } catch (e) {
      Loggers.error('Error in addDummyUsers: $e');
    }
  }

  Future<void> createLiveStream(DummyLive? dummyLive) async {
    User? dummyUser = dummyLive?.user;
    if (dummyUser == null) {
      Loggers.error('Dummy User Not found');
      return;
    }
    int userId = dummyLive?.userId ?? -1;

    try {
      await LivestreamApiService.instance.createDummyLivestream({
        'room_id': '$userId',
        'host_id': userId,
        'description': dummyLive?.title ?? '',
        'dummy_user_link': dummyLive?.link,
        'watching_count': 0,
      });
      Loggers.success('Created/Updated Dummy Live via REST');
    } catch (e) {
      Loggers.error('Failed to create dummy live stream: $e');
    }
  }

  Future<void> deleteStreamOnFirebase(int? dummyUserId) async {
    if (dummyUserId == null) return;
    final String roomId = dummyUserId.toString();

    try {
      await LivestreamApiService.instance.deleteDummyLivestream(roomId);
      Loggers.success('Deleted dummy live stream via REST: $roomId');

      livestreamList.removeWhere((e) => e.roomID == roomId);
      livestreamFilterList.removeWhere((e) => e.roomID == roomId);
    } catch (e) {
      Loggers.error('Failed to delete live stream: $e');
    }
  }

  void removeDummyLive() {
    final dummyStream = livestreamFilterList.where((e) => e.isDummyLive == 1).toList();
    if (dummyStream.isEmpty) return;
    if (setting?.liveDummyShow == 0) {
      for (var element in dummyStream) {
        deleteStreamOnFirebase(element.hostId);
      }
    } else {
      for (var element in dummyStream) {
        final shouldDelete = dummyLives.isEmpty || !dummyLives.any((e) => e.userId == element.hostId);
        if (shouldDelete) {
          deleteStreamOnFirebase(element.hostId);
        }
      }
    }
  }

  Future<void> onGoLive() async {
    User? myUser = SessionManager.instance.getUser();
    bool isExist = livestreamList.any((element) => element.hostId == myUser?.id);
    if (myUser?.isDummy == 1 && isExist) {
      return showSnackBar(LKey.yourProfileIsAlreadyInUseForDummyEtc.tr);
    }

    if (myUser?.isDummy == 0 && isExist) {
      showLoader();
      await deleteStreamOnFirebase(myUser?.id);
      stopLoader();
    }

    Get.to(() => const CreateLiveStreamScreen());
  }
}
