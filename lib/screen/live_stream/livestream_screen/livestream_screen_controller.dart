import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shortzz/common/controller/ads_controller.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/controller/firebase_firestore_controller.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/haptic_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/notification_service.dart';
import 'package:shortzz/common/service/live/livestream_api_service.dart';
import 'package:shortzz/common/service/live/livestream_events.dart';
import 'package:shortzz/common/service/live/livestream_socket_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/model/livestream/live_poll.dart';
import 'package:shortzz/model/livestream/live_qa_question.dart';
import 'package:shortzz/model/livestream/livestream_comment.dart';
import 'package:shortzz/model/livestream/livestream_user_state.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/common/service/api/live_shopping_service.dart';
import 'package:shortzz/common/service/api/product_service.dart';
import 'package:shortzz/model/livestream/live_shopping_product.dart';
import 'package:shortzz/model/product/product_model.dart';
import 'package:shortzz/screen/gift_sheet/send_gift_sheet.dart';
import 'package:shortzz/screen/gift_sheet/send_gift_sheet_controller.dart';
import 'package:shortzz/screen/live_stream/live_stream_end_screen/live_stream_end_screen.dart';
import 'package:shortzz/screen/live_stream/live_stream_end_screen/widget/livestream_summary.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/audience/widget/live_stream_join_sheet.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/host/widget/live_stream_host_top_view.dart';
import 'package:shortzz/screen/report_sheet/report_sheet.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:shortzz/common/service/api/call_service.dart';

class LivestreamScreenController extends BaseController {
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  final firestoreController = Get.find<FirebaseFirestoreController>();
  final adsController = Get.find<AdsController>();

  Timer? timer;
  Timer? minViewerTimeoutTimer;
  Function? onLikeTap;

  Setting? get setting => SessionManager.instance.getSettings();

  int get minViewersThreshold => setting?.liveMinViewers ?? 0;

  int get timeoutMinutes => setting?.liveTimeout ?? 0;

  int get myUserId => SessionManager.instance.getUserID();

  RxBool isPlayerMute = false.obs;
  RxBool isMinViewerTimeout = false.obs;
  RxBool isTextEmpty = true.obs;
  bool isJoinSheetOpen = false;
  bool isFrontCamera = true;
  bool isHost;

  TextEditingController textCommentController = TextEditingController();

  String get _roomId => liveData.value.roomID ?? '';

  Widget? hostPreview;

  LivestreamScreenController(this.liveData, this.isHost, {this.hostPreview});

  int totalBattleSecond = 0;

  RxInt remainingBattleSeconds = 0.obs;
  RxBool isViewVisible = true.obs;

  List<LivestreamUserState> memberList = <LivestreamUserState>[];

  List<Gift> get gifts => setting?.gifts ?? [];
  RxList<LivestreamUserState> requestList = <LivestreamUserState>[].obs;
  RxList<LivestreamUserState> audienceList = <LivestreamUserState>[].obs;
  RxList<LivestreamUserState> invitedList = <LivestreamUserState>[].obs;
  RxList<LivestreamUserState> coHostList = <LivestreamUserState>[].obs;
  RxList<LivestreamUserState> audienceMemberList = <LivestreamUserState>[].obs;
  RxList<StreamView> streamViews = <StreamView>[].obs;
  RxList<LivestreamComment> comments = <LivestreamComment>[].obs;
  RxList<LivestreamUserState> liveUsersStates = <LivestreamUserState>[].obs;

  Rx<AppUser?> selectedGiftUser = Rx(null);
  Rx<VideoPlayerController?> videoPlayerController = Rx(null);

  // Polls & Q&A
  Rx<LivePoll?> activePoll = Rx(null);
  RxList<LiveQAQuestion> qaQuestions = <LiveQAQuestion>[].obs;

  Rx<User?> get myUser => SessionManager.instance.getUser().obs;
  Rx<Livestream> liveData;

  AudioPlayer countdownPlayer = AudioPlayer();
  AudioPlayer battleStartPlayer = AudioPlayer();
  AudioPlayer winAudioPlayer = AudioPlayer();

  List<User> usersList = [];

  @override
  void onInit() {
    super.onInit();

    if (liveData.value.isDummyLive == 1) {
      initVideoPlayer();
    } else {
      totalBattleSecond =
          Duration(minutes: liveData.value.battleDuration).inSeconds;
      remainingBattleSeconds.value = totalBattleSecond;
      loginRoom();
      initAudioPlayer();
    }

    // Load initial data via REST, then register socket listeners
    _loadInitialData();
    _registerSocketListeners();
    fetchLiveShoppingProducts();
    WakelockPlus.enable();
    FirebaseNotificationManager.instance
        .unsubscribeToTopic(topic: myUserId.toString());
  }

  @override
  void onClose() {
    super.onClose();

    WakelockPlus.disable();
    timer?.cancel();
    minViewerTimeoutTimer?.cancel();
    videoPlayerController.value?.dispose();
    _unregisterSocketListeners();
    countdownPlayer.dispose();
    winAudioPlayer.dispose();
    stopListenEvent();
    logoutRoom();
  }

  // ── Initial Data Loading via REST ────────────────────────────────────

  Future<void> _loadInitialData() async {
    if (_roomId.isEmpty) return;

    // Load livestream + user states + comments + poll + Q&A in parallel
    final results = await Future.wait([
      LivestreamApiService.instance.fetchLivestream(_roomId),
      LivestreamApiService.instance.fetchComments(_roomId),
      LivestreamApiService.instance.fetchActivePoll(_roomId),
      LivestreamApiService.instance.fetchQuestions(_roomId),
    ]);

    // Process livestream + user states
    final livestreamData = results[0] as Map<String, dynamic>?;
    if (livestreamData != null) {
      if (livestreamData['livestream'] != null) {
        liveData.value = Livestream.fromJson(
            Map<String, dynamic>.from(livestreamData['livestream']));
      }
      if (livestreamData['user_states'] != null) {
        final states = (livestreamData['user_states'] as List)
            .map((s) => LivestreamUserState.fromJson(Map<String, dynamic>.from(s)))
            .toList();
        liveUsersStates.assignAll(states);
        _refreshUserStateLists();
      }
    }

    // Process comments
    final commentsData = results[1] as List<Map<String, dynamic>>;
    if (commentsData.isNotEmpty) {
      final loadedComments = commentsData
          .map((c) => LivestreamComment.fromJson(c))
          .toList();
      for (var comment in loadedComments) {
        firestoreController.fetchUserIfNeeded(comment.senderId ?? -1);
        comment.gift = gifts.firstWhereOrNull((gift) => gift.id == comment.giftId);
      }
      comments.assignAll(loadedComments);
      comments.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    }

    // Process poll
    final pollData = results[2] as Map<String, dynamic>?;
    if (pollData != null) {
      activePoll.value = LivePoll.fromJson(pollData);
    }

    // Process Q&A
    final questionsData = results[3] as List<Map<String, dynamic>>;
    if (questionsData.isNotEmpty) {
      qaQuestions.assignAll(
          questionsData.map((q) => LiveQAQuestion.fromJson(q)).toList());
    }
  }

  // ── Socket.IO Event Listeners ────────────────────────────────────────

  void _registerSocketListeners() {
    final svc = LivestreamSocketService.instance;

    // Livestream metadata updates
    svc.on(LivestreamEvents.sLiveUpdated, (data) {
      if (data is Map<String, dynamic>) {
        final stream = Livestream.fromJson(data);
        if (stream.roomID != _roomId) return;

        final oldLikeCount = liveData.value.likeCount ?? 0;

        if (stream.battleType == BattleType.initiate) {
          timer?.cancel();
          remainingBattleSeconds.value =
              Duration(minutes: stream.battleDuration).inSeconds;
          countdownPlayer.pause();
        }
        if (stream.battleType == BattleType.waiting) {
          totalBattleSecond =
              Duration(minutes: stream.battleDuration).inSeconds;
        }

        liveData.value = stream;

        final newLikeCount = stream.likeCount ?? 0;
        if (oldLikeCount != newLikeCount) {
          onLikeTap?.call();
        }
      }
    });

    // Stream ended
    svc.on(LivestreamEvents.sLiveEnded, (data) {
      if (data is Map<String, dynamic>) {
        final roomId = data['room_id']?.toString() ?? '';
        if (roomId != _roomId) return;

        if (!isHost) {
          if (Get.isBottomSheetOpen == false) {
            Get.back();
          }
          logoutRoom();
          stopListenEvent();
          liveData.value = Livestream();
        }
      }
    });

    // Like updates
    svc.on(LivestreamEvents.sLiveLike, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        liveData.value.likeCount = data['like_count'] ?? liveData.value.likeCount;
        liveData.refresh();
        onLikeTap?.call();
      }
    });

    // User joined
    svc.on(LivestreamEvents.sLiveUserJoined, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        liveData.value.watchingCount = data['watching_count'];
        liveData.refresh();
      }
    });

    // User left
    svc.on(LivestreamEvents.sLiveUserLeft, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        final userId = data['user_id'];
        liveData.value.watchingCount = data['watching_count'];
        liveData.refresh();
        liveUsersStates.removeWhere((u) => u.userId == userId);
        _refreshUserStateLists();
      }
    });

    // User state changed
    svc.on(LivestreamEvents.sLiveUserStateChanged, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        final state = LivestreamUserState.fromJson(data);

        final oldState = liveUsersStates.firstWhereOrNull(
            (element) => element.userId == state.userId);
        updateStateAction(oldState, state);

        int index = liveUsersStates.indexWhere((u) => u.userId == state.userId);
        if (index != -1) {
          liveUsersStates[index] = state;
        } else {
          _showJoinStreamSheet(state);
          liveUsersStates.add(state);
        }
        _refreshUserStateLists();
      }
    });

    // New comment
    svc.on(LivestreamEvents.sLiveNewComment, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        final comment = LivestreamComment.fromJson(data);
        firestoreController.fetchUserIfNeeded(comment.senderId ?? -1);

        if (comment.commentType == LivestreamCommentType.request && !isHost) {
          return;
        }

        comment.gift = gifts.firstWhereOrNull((gift) => gift.id == comment.giftId);
        comments.insert(0, comment);
      }
    });

    // Comment deleted
    svc.on(LivestreamEvents.sLiveCommentDeleted, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        final commentId = data['comment_id'];
        comments.removeWhere((c) => c.id == commentId);
      }
    });

    // Join request (host only)
    svc.on(LivestreamEvents.sLiveJoinRequest, (data) {
      // Handled via user state change
    });

    // Request response (for requesting user)
    svc.on(LivestreamEvents.sLiveRequestResponse, (data) {
      // Handled via user state change
    });

    // Invite (for target user)
    svc.on(LivestreamEvents.sLiveInvite, (data) {
      // Handled via user state change
    });

    // Co-host removed
    svc.on(LivestreamEvents.sLiveCohostRemoved, (data) {
      // Handled via user state change + livestream update
    });

    // Poll created
    svc.on(LivestreamEvents.sLivePollCreated, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        activePoll.value = LivePoll.fromJson(data);
      }
    });

    // Poll updated (votes)
    svc.on(LivestreamEvents.sLivePollUpdated, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        activePoll.value = LivePoll.fromJson(data);
      }
    });

    // Poll ended
    svc.on(LivestreamEvents.sLivePollEnded, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        activePoll.value = LivePoll.fromJson(data);
      }
    });

    // Q&A question asked
    svc.on(LivestreamEvents.sLiveQuestionAsked, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        qaQuestions.insert(0, LiveQAQuestion.fromJson(data));
      }
    });

    // Q&A question updated
    svc.on(LivestreamEvents.sLiveQuestionUpdated, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        final updated = LiveQAQuestion.fromJson(data);
        int idx = qaQuestions.indexWhere((q) => q.id == updated.id);
        if (idx != -1) {
          qaQuestions[idx] = updated;
        }
      }
    });

    // Q&A question pinned
    svc.on(LivestreamEvents.sLiveQuestionPinned, (data) {
      if (data is Map<String, dynamic>) {
        if (data['room_id']?.toString() != _roomId) return;
        if (data['question'] != null) {
          final updated = LiveQAQuestion.fromJson(
              Map<String, dynamic>.from(data['question']));
          int idx = qaQuestions.indexWhere((q) => q.id == updated.id);
          if (idx != -1) {
            qaQuestions[idx] = updated;
          }
        }
      }
    });
  }

  void _unregisterSocketListeners() {
    final svc = LivestreamSocketService.instance;
    svc.off(LivestreamEvents.sLiveUpdated);
    svc.off(LivestreamEvents.sLiveEnded);
    svc.off(LivestreamEvents.sLiveLike);
    svc.off(LivestreamEvents.sLiveUserJoined);
    svc.off(LivestreamEvents.sLiveUserLeft);
    svc.off(LivestreamEvents.sLiveUserStateChanged);
    svc.off(LivestreamEvents.sLiveNewComment);
    svc.off(LivestreamEvents.sLiveCommentDeleted);
    svc.off(LivestreamEvents.sLiveJoinRequest);
    svc.off(LivestreamEvents.sLiveRequestResponse);
    svc.off(LivestreamEvents.sLiveInvite);
    svc.off(LivestreamEvents.sLiveCohostRemoved);
    svc.off(LivestreamEvents.sLivePollCreated);
    svc.off(LivestreamEvents.sLivePollUpdated);
    svc.off(LivestreamEvents.sLivePollEnded);
    svc.off(LivestreamEvents.sLiveQuestionAsked);
    svc.off(LivestreamEvents.sLiveQuestionUpdated);
    svc.off(LivestreamEvents.sLiveQuestionPinned);
  }

  void _refreshUserStateLists() {
    requestList.value = liveUsersStates
        .where((element) => element.type == LivestreamUserType.requested)
        .toList();
    audienceList.value = liveUsersStates
        .where((element) =>
            element.type != LivestreamUserType.host &&
            element.type != LivestreamUserType.left)
        .toList();
    invitedList.value = liveUsersStates
        .where((element) => element.type == LivestreamUserType.invited)
        .toList();
    coHostList.value = liveUsersStates
        .where((element) => element.type == LivestreamUserType.coHost)
        .toList();
    audienceMemberList.value = liveUsersStates
        .where((element) =>
            element.type != LivestreamUserType.left &&
            element.userId != myUserId)
        .toList();
  }

  // ── Video Player (Dummy Streams) ─────────────────────────────────────

  Future<void> initVideoPlayer() async {
    final url = liveData.value.dummyUserLink ?? '';
    if (url.isEmpty) return;

    await videoPlayerController.value?.dispose();

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    isPlayerMute.value = false;

    try {
      await controller.initialize();
      controller
        ..setLooping(true)
        ..play();

      videoPlayerController.value = controller;
      videoPlayerController.value?.setLooping(true);
    } on PlatformException catch (e) {
      showSnackBar(e.message);
      Loggers.error(e);
    }
  }

  void initAudioPlayer() {
    countdownPlayer.setAsset(AssetRes.endCountdown);
    battleStartPlayer.setAsset(AssetRes.battleStart);
    winAudioPlayer.setAsset(AssetRes.winSound);
  }

  // ── Room Lifecycle ───────────────────────────────────────────────────

  Future<void> logoutRoom() async {
    if (isHost) {
      deleteStreamOnFirebase();
    } else {
      // Audience leaving
      if (_roomId.isNotEmpty) {
        LivestreamSocketService.instance.leaveLivestream(_roomId);
      }
    }
    stopPublish();
    _listener?.dispose();
    _listener = null;
    await _room?.disconnect();
    await _room?.dispose();
    _room = null;
  }

  Future<void> loginRoom() async {
    final roomID = _roomId;

    try {
      final tokenResponse = await CallService.instance.generateLiveKitToken(
        roomName: roomID,
        canPublish: true,
      );

      final token = tokenResponse.data?.token;
      final wsUrl = tokenResponse.data?.wsUrl;

      if (token == null || wsUrl == null) {
        showSnackBar('Failed to get LiveKit token');
        Loggers.error('LiveKit token or URL is null');
        return;
      }

      _room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: AudioPublishOptions(dtx: true),
          defaultVideoPublishOptions: VideoPublishOptions(simulcast: true),
        ),
      );
      startListenEvent();

      await _room!.connect(wsUrl, token);

      if (isHost) {
        startHostPublish();
        return;
      }

      // For Audience — join via Socket.IO
      LivestreamSocketService.instance.joinLivestream(roomID);

      // Send joined comment
      _sendComment(type: LivestreamCommentType.joined);
    } catch (e) {
      Loggers.error('Error in loginRoom: $e');
      showSnackBar('Something went wrong while joining the room.');
    }
  }

  // ── LiveKit Event Handling ───────────────────────────────────────────

  void startListenEvent() {
    if (_room == null) return;
    _listener = _room!.createListener();

    _listener!.on<TrackSubscribedEvent>((event) {
      if (event.track is VideoTrack) {
        final participantId = event.participant.identity;
        final videoTrack = event.track as VideoTrack;
        final priorityId = liveData.value.hostId.toString();

        final view = StreamView(participantId, -1,
            VideoTrackRenderer(videoTrack, fit: VideoViewFit.cover), false);

        if (participantId == priorityId) {
          streamViews.insert(0, view);
        } else {
          streamViews.add(view);
        }
      }
      if ((_room?.remoteParticipants.length ?? 0) > 0) {
        Hardware.instance.setSpeakerphoneOn(true);
      }
    });

    _listener!.on<TrackUnsubscribedEvent>((event) {
      if (event.track is VideoTrack) {
        streamViews.removeWhere((v) => v.streamId == event.participant.identity);
      }
    });

    _listener!.on<ParticipantConnectedEvent>((event) {
      Loggers.info('Participant connected: ${event.participant.identity}');
    });

    _listener!.on<ParticipantDisconnectedEvent>((event) {
      final participantId = event.participant.identity;

      if (isHost) {
        int coHostId = int.tryParse(participantId) ?? -1;
        bool isCoHostExist =
            liveData.value.coHostIds?.contains(coHostId) ?? false;
        if (isCoHostExist) {
          updateUserStateToFirestore(coHostId,
              type: LivestreamUserType.audience,
              audioStatus: VideoAudioStatus.on,
              videoStatus: VideoAudioStatus.on);
          updateLiveStreamData(removeCoHostId: coHostId);
        }
      } else {
        if (participantId == _roomId) {
          if (Get.isBottomSheetOpen == false) {
            Get.back();
          }
          for (var element in liveUsersStates) {
            if (element.type == LivestreamUserType.coHost) {
              streamEnded();
            }
          }
          logoutRoom();
          stopListenEvent();
          liveData.value = Livestream();
        }
      }
      streamViews.removeWhere((v) => v.streamId == participantId);
      Loggers.info('Participant disconnected: $participantId');
    });

    _listener!.on<RoomDisconnectedEvent>((event) {
      Loggers.info('Room disconnected: ${event.reason}');
    });
  }

  void stopListenEvent() {
    _listener?.dispose();
    _listener = null;
  }

  Future<void> startHostPublish() async {
    if (_roomId.isEmpty) {
      return Loggers.error('No ID FOUND');
    }

    final cameraPub = await _room?.localParticipant?.setCameraEnabled(true);
    await _room?.localParticipant?.setMicrophoneEnabled(true);

    final videoTrack = cameraPub?.track as VideoTrack?;
    if (videoTrack != null) {
      streamViews.add(StreamView(_roomId, -1,
          VideoTrackRenderer(videoTrack, fit: VideoViewFit.cover, mirrorMode: VideoViewMirrorMode.mirror), false));
    } else if (hostPreview != null) {
      streamViews.add(StreamView(_roomId, -1, hostPreview!, false));
    }

    startMinViewerTimeoutCheck();
    pushNotificationToFollowers(liveData.value);
  }

  Future<void> stopPublish() async {
    await _room?.localParticipant?.setCameraEnabled(false);
    await _room?.localParticipant?.setMicrophoneEnabled(false);
  }

  Future<void> stopPlayStream(String streamID) async {
    streamViews.removeWhere((element) => element.streamId == streamID);
  }

  // ── Livestream Data Updates (via Socket.IO) ──────────────────────────

  Future<void> updateLiveStreamData({
    BattleType? battleType,
    LivestreamType? type,
    int? battleCreatedAt,
    int? battleDuration,
    int? addCoHostId,
    int? removeCoHostId,
  }) async {
    LivestreamSocketService.instance.updateLivestream({
      'room_id': _roomId,
      if (battleType != null) 'battle_type': battleType.value,
      if (type != null) 'type': type.value,
      if (battleCreatedAt != null) 'battle_created_at': battleCreatedAt,
      if (battleDuration != null) 'battle_duration': battleDuration,
      if (addCoHostId != null) 'add_co_host_id': addCoHostId,
      if (removeCoHostId != null) 'remove_co_host_id': removeCoHostId,
    });
  }

  void handleRequestResponse({
    required AppUser? user,
    required bool isRefused,
    LivestreamComment? comment,
  }) {
    final userId = user?.userId;
    if (userId == null) return;

    LivestreamSocketService.instance.respondRequest(_roomId, userId, !isRefused);

    final commentToDelete = comment ??
        comments.firstWhereOrNull((element) =>
            element.senderId == userId &&
            element.commentType == LivestreamCommentType.request);

    if (commentToDelete != null) {
      LivestreamSocketService.instance.deleteComment(_roomId, commentToDelete.id ?? 0);
    }
  }

  Future<void> deleteStreamOnFirebase() async {
    if (_roomId.isEmpty) {
      Loggers.error('Room ID is null. Cannot stop live stream.');
      return;
    }

    Loggers.info('Stopping live stream Room : $_roomId');

    try {
      LivestreamSocketService.instance.endLivestream(_roomId);
      Loggers.success('Livestream end event sent.');
    } catch (e) {
      Loggers.error('Failed to stop live stream: $e');
    }
  }

  // ── Camera/Audio Controls ────────────────────────────────────────────

  void toggleCamera() {
    isFrontCamera = !isFrontCamera;
    final track = _room?.localParticipant?.videoTrackPublications
        .firstOrNull?.track;
    if (track is LocalVideoTrack) {
      track.setCameraPosition(
          isFrontCamera ? CameraPosition.front : CameraPosition.back);
    }
  }

  void toggleFlipCamera() {
    toggleCamera();
  }

  void toggleMic(LivestreamUserState? state) async {
    if (state?.audioStatus == VideoAudioStatus.offByHost) {
      return showSnackBar(LKey.theHostHasTurnedOffYourAudio);
    }

    bool isAudioOn = state?.audioStatus == VideoAudioStatus.on;

    if (isAudioOn) {
      updateUserStateToFirestore(myUserId,
          audioStatus: VideoAudioStatus.offByMe);
      final audioTrack = _room?.localParticipant?.audioTrackPublications
          .firstOrNull?.track;
      if (audioTrack is LocalAudioTrack) await audioTrack.mute();
    } else {
      updateUserStateToFirestore(myUserId, audioStatus: VideoAudioStatus.on);
      final audioTrack = _room?.localParticipant?.audioTrackPublications
          .firstOrNull?.track;
      if (audioTrack is LocalAudioTrack) await audioTrack.unmute();
    }
  }

  void toggleVideo(LivestreamUserState? state) async {
    if (state?.videoStatus == VideoAudioStatus.offByHost) {
      return showSnackBar(LKey.theHostHasTurnedOffYourVideo.tr);
    }
    bool isVideoOn = state?.videoStatus == VideoAudioStatus.on;
    if (isVideoOn) {
      updateUserStateToFirestore(myUserId,
          videoStatus: VideoAudioStatus.offByMe);
      final videoTrack = _room?.localParticipant?.videoTrackPublications
          .firstOrNull?.track;
      if (videoTrack is LocalVideoTrack) await videoTrack.mute();
    } else {
      updateUserStateToFirestore(myUserId, videoStatus: VideoAudioStatus.on);
      final videoTrack = _room?.localParticipant?.videoTrackPublications
          .firstOrNull?.track;
      if (videoTrack is LocalVideoTrack) await videoTrack.unmute();
    }
  }

  void toggleStreamAudio(int? streamId) {
    StreamView? view = streamViews
        .firstWhereOrNull((element) => int.parse(element.streamId) == streamId);

    bool newMuted = !(view?.isMuted ?? false);

    final participant = _room?.remoteParticipants['$streamId'];
    if (participant != null) {
      for (var pub in participant.audioTrackPublications) {
        newMuted ? pub.disable() : pub.enable();
      }
    }

    view?.isMuted = newMuted;
    if (view != null) {
      streamViews[streamViews.indexWhere(
          (element) => int.parse(element.streamId) == streamId)] = view;
      streamViews.refresh();
    }
  }

  // ── Like & Comments ──────────────────────────────────────────────────

  void onLikeButtonTap() {
    HapticManager.shared.light();
    LivestreamSocketService.instance.likeLivestream(_roomId);
  }

  void onTextCommentSend() {
    String comment = textCommentController.text.trim();
    textCommentController.clear();
    isTextEmpty.value = true;
    if (comment.isEmpty) return;
    _sendComment(type: LivestreamCommentType.text, comment: comment);
  }

  void onGiftTap(GiftType type,
      {BattleView battleViewType = BattleView.red,
      List<AppUser> users = const []}) {
    users.removeWhere((element) => element.userId == myUserId);
    if (liveData.value.type == LivestreamType.battle &&
        liveData.value.battleType == BattleType.end) {
      return showSnackBar(LKey.battleEndedGiftNotSent.tr);
    }
    GiftManager.openGiftSheet(
        onCompletion: (giftManager) {
          Gift gift = giftManager.gift;
          AppUser? user = giftManager.streamUser;

          int coinPrice = gift.coinPrice?.toInt() ?? 0;

          _sendComment(
              type: LivestreamCommentType.gift,
              giftId: gift.id,
              receiverId: user?.userId,
              giftCoinValue: coinPrice);
          updateUserStateToFirestore(
            user?.userId,
            battleCoin: type == GiftType.battle ? coinPrice : null,
            currentBattleCoin: type == GiftType.battle ? coinPrice : null,
            liveCoin: type == GiftType.livestream ? coinPrice : null,
          );
        },
        giftType: type,
        battleViewType: battleViewType,
        streamUsers: users);
  }

  Future<void> setGiftGoal(int target, {String? label}) async {
    LivestreamSocketService.instance.updateLivestream({
      'room_id': _roomId,
      'gift_goal_target': target,
      'gift_goal_current': 0,
      'gift_goal_label': label,
    });
  }

  Future<void> removeGiftGoal() async {
    LivestreamSocketService.instance.updateLivestream({
      'room_id': _roomId,
      'gift_goal_target': 0,
      'gift_goal_current': 0,
      'gift_goal_label': '',
    });
  }

  void _sendComment({
    required LivestreamCommentType type,
    String? comment,
    int? giftId,
    int? receiverId,
    int? giftCoinValue,
  }) {
    int time = DateTime.now().millisecondsSinceEpoch;
    LivestreamSocketService.instance.sendComment({
      'room_id': _roomId,
      'id': time,
      'comment': comment ?? '',
      'comment_type': type.value,
      if (giftId != null) 'gift_id': giftId,
      if (receiverId != null) 'receiver_id': receiverId,
      if (giftCoinValue != null) 'gift_coin_value': giftCoinValue,
    });
  }

  // ── User State Updates (via Socket.IO) ───────────────────────────────

  void onVideoRequestSend(Livestream liveData) {
    LivestreamUserState? state = liveUsersStates
        .firstWhereOrNull((element) => element.userId == myUserId);
    switch (state?.type) {
      case null:
        break;
      case LivestreamUserType.audience:
        LivestreamSocketService.instance.requestJoin(_roomId);
        _sendComment(
            type: LivestreamCommentType.request, receiverId: liveData.hostId);
        showSnackBar(LKey.requestJoinToHost.tr);
        break;
      case LivestreamUserType.requested:
        showSnackBar(LKey.joinRequestSentDescription.tr);
        break;
      case LivestreamUserType.host:
      case LivestreamUserType.coHost:
      case LivestreamUserType.invited:
      case LivestreamUserType.left:
        break;
    }
  }

  Future<void> updateUserStateToFirestore(
    int? userId, {
    LivestreamUserType? type,
    VideoAudioStatus? audioStatus,
    VideoAudioStatus? videoStatus,
    int? battleCoin,
    int? liveCoin,
    bool? isFollow,
    int? joinTime,
    int? currentBattleCoin,
  }) async {
    if (userId == null) {
      Loggers.error('updateUserStateToFirestore: userId is null');
      return;
    }

    if (battleCoin != null || liveCoin != null) {
      myUser.value?.coinEstimatedValue(
          battleCoin?.toDouble() ?? liveCoin?.toDouble());
      SessionManager.instance.setUser(myUser.value);
    }

    LivestreamSocketService.instance.updateUserState({
      'room_id': _roomId,
      'user_id': userId,
      if (type != null) 'type': type.value,
      if (audioStatus != null) 'audio_status': audioStatus.value,
      if (videoStatus != null) 'video_status': videoStatus.value,
      if (battleCoin != null)
        'total_battle_coin_delta': battleCoin == 0 ? null : battleCoin,
      if (currentBattleCoin != null)
        'current_battle_coin_delta': currentBattleCoin == 0 ? null : currentBattleCoin,
      if (liveCoin != null)
        'live_coin_delta': liveCoin == 0 ? null : liveCoin,
      if (isFollow != null && isFollow) 'add_follower_id': myUserId,
      if (isFollow != null && !isFollow) 'remove_follower_id': myUserId,
      if (joinTime != null) 'join_stream_time': joinTime,
    });
  }

  // ── Co-host Management ───────────────────────────────────────────────

  int get maxGuests => setting?.liveMaxGuests ?? 7;

  void onInvite(AppUser? user, {bool isInvited = false}) {
    if (!isInvited) {
      final currentCoHosts = liveData.value.coHostIds?.length ?? 0;
      if (currentCoHosts >= maxGuests) {
        showSnackBar('Maximum $maxGuests guests allowed');
        return;
      }
    }
    if (isInvited) {
      updateUserStateToFirestore(user?.userId, type: LivestreamUserType.audience);
    } else {
      LivestreamSocketService.instance.inviteUser(_roomId, user?.userId ?? 0);
    }
  }

  void _showJoinStreamSheet(LivestreamUserState state) {
    if (state.userId == myUserId && state.type == LivestreamUserType.invited) {
      AppUser? hostUser = liveData.value.getHostUser(firestoreController.users);
      isJoinSheetOpen = true;
      Get.bottomSheet(
              LiveStreamJoinSheet(
                  hostUser: hostUser,
                  myUser: myUser.value,
                  onJoined: () async {
                    LivestreamUserState? userState =
                        liveUsersStates.firstWhereOrNull(
                            (element) => element.userId == myUserId);
                    if (userState?.type == LivestreamUserType.invited) {
                      LivestreamSocketService.instance.respondInvite(_roomId, true);
                    } else {
                      showSnackBar(LKey.joinCancelledDescription.tr);
                    }
                  },
                  onCancel: () {
                    LivestreamSocketService.instance.respondInvite(_roomId, false);
                  }),
              isScrollControlled: true,
              enableDrag: false,
              isDismissible: false)
          .then(
        (value) {
          isJoinSheetOpen = false;
        },
      );
    }
  }

  void publishCoHostStream(int streamId) async {
    bool isPermissionGranted = await requestPermission();
    if (isPermissionGranted) {
      final cameraPub = await _room?.localParticipant?.setCameraEnabled(true);
      await _room?.localParticipant?.setMicrophoneEnabled(true);

      final videoTrack = cameraPub?.track as VideoTrack?;
      if (videoTrack != null) {
        streamViews.add(StreamView('$streamId', -1,
            VideoTrackRenderer(videoTrack, fit: VideoViewFit.cover, mirrorMode: VideoViewMirrorMode.mirror), false));
      }

      Hardware.instance.setSpeakerphoneOn(true);

      updateLiveStreamData(addCoHostId: streamId);
      _sendComment(type: LivestreamCommentType.joinedCoHost);
      updateUserStateToFirestore(myUserId,
          joinTime: DateTime.now().millisecondsSinceEpoch);
    } else {
      Get.bottomSheet(ConfirmationSheet(
        title: LKey.cameraMicrophonePermissionTitle.tr,
        description: LKey.cameraMicrophonePermissionDescription.tr,
        onTap: openAppSettings,
      ));
    }
  }

  void closeCoHostStream(int? streamId) {
    StreamView? view = streamViews
        .firstWhereOrNull((element) => element.streamId == '$streamId');
    if (view != null) {
      stopPublish();
      updateLiveStreamData(removeCoHostId: streamId);
      LivestreamComment? comment = comments.firstWhereOrNull((element) =>
          element.senderId == myUserId &&
          element.commentType == LivestreamCommentType.joinedCoHost);
      if (comment != null) {
        LivestreamSocketService.instance.deleteComment(_roomId, comment.id ?? 0);
      }
      updateUserStateToFirestore(streamId,
          type: LivestreamUserType.audience,
          audioStatus: VideoAudioStatus.offByMe,
          videoStatus: VideoAudioStatus.offByMe,
          battleCoin: 0,
          currentBattleCoin: 0);
      streamViews.removeWhere((element) => element.streamId == '$streamId');
      streamEnded();
    }
  }

  Future<bool> requestPermission() async {
    Loggers.info("requestPermission...");
    try {
      PermissionStatus microphoneStatus = await Permission.microphone.request();
      if (microphoneStatus != PermissionStatus.granted) {
        Loggers.error('Error: Microphone permission not granted!!!');
        return false;
      }
    } on Exception catch (error) {
      Loggers.error("[ERROR], request microphone permission exception, $error");
    }

    try {
      PermissionStatus cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        Loggers.error('Error: Camera permission not granted!!!');
        return false;
      }
    } on Exception catch (error) {
      Loggers.error("[ERROR], request camera permission exception, $error");
    }

    return true;
  }

  void coHostVideoToggle(LivestreamUserState state) {
    if (state.videoStatus == VideoAudioStatus.offByMe) {
      return showSnackBar(LKey.theCoHostHasTurnedOffTheirVideo);
    }

    updateUserStateToFirestore(state.userId,
        videoStatus: state.videoStatus == VideoAudioStatus.on
            ? VideoAudioStatus.offByHost
            : VideoAudioStatus.on);
  }

  void coHostAudioToggle(LivestreamUserState state) {
    if (state.audioStatus == VideoAudioStatus.offByMe) {
      return showSnackBar(LKey.theCoHostHasTurnedOffTheirAudio);
    }

    updateUserStateToFirestore(state.userId,
        audioStatus: state.audioStatus == VideoAudioStatus.on
            ? VideoAudioStatus.offByHost
            : VideoAudioStatus.on);
  }

  void updateStateAction(
      LivestreamUserState? oldState, LivestreamUserState newState) {
    if (newState.userId == myUserId) {
      Loggers.info('Updating state for userId: ${newState.toJson()}');
      if (newState.type == LivestreamUserType.coHost &&
          oldState?.type != LivestreamUserType.coHost) {
        publishCoHostStream(myUserId);
      }

      if (newState.type == LivestreamUserType.audience &&
          oldState?.type == LivestreamUserType.invited &&
          isJoinSheetOpen) {
        Get.back();
      }

      if (newState.type == LivestreamUserType.invited &&
          oldState?.type == LivestreamUserType.audience) {
        _showJoinStreamSheet(newState);
      }
      if (oldState?.type == LivestreamUserType.coHost &&
          newState.type == LivestreamUserType.audience) {
        closeCoHostStream(newState.userId);
      }
    }
  }

  void coHostDelete(LivestreamUserState state) {
    if (state.type == LivestreamUserType.coHost) {
      LivestreamSocketService.instance.removeCohost(_roomId, state.userId);
    }
  }

  void reportUser(int? userId) {
    Get.bottomSheet(ReportSheet(reportType: ReportType.user, id: userId),
        isScrollControlled: true);
  }

  // ── Battle & Timer ───────────────────────────────────────────────────

  void _timerStart(VoidCallback callBack) {
    timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (t) {
        callBack.call();
      },
    );
  }

  void onStopButtonTap() {
    bool isBattleOn = liveData.value.type == LivestreamType.battle;
    String title =
        !isBattleOn ? LKey.endStreamTitle.tr : LKey.stopBattleTitle.tr;
    String description =
        !isBattleOn ? LKey.endStreamMessage.tr : LKey.stopBattleDescription.tr;

    Get.bottomSheet(
        StopLiveStreamSheet(
            onTap: () {
              if (isBattleOn) {
                updateLiveStreamData(
                    battleType: BattleType.initiate,
                    type: LivestreamType.livestream);
                startMinViewerTimeoutCheck();
              } else {
                hostEndStream();
              }
            },
            title: title,
            description: description,
            positiveText: LKey.stop.tr),
        isScrollControlled: true);
  }

  void hostEndStream() {
    streamEnded();
    logoutRoom();
  }

  void streamEnded() {
    LivestreamUserState? userState = liveUsersStates
        .firstWhereOrNull((element) => element.userId == myUserId);
    AppUser? user = firestoreController.users
        .firstWhereOrNull((element) => element.userId == myUserId);
    userState?.user = user;
    int viewers = liveUsersStates.length;
    if (isHost) {
      Get.back();
      Get.off(() => LiveStreamEndScreen(
          userState: userState,
          isHost: isHost,
          viewers: viewers,
          roomId: liveData.value.roomID,
          likeCount: liveData.value.likeCount,
          totalGiftsCoins: userState?.totalCoin));
    } else {
      if (userState?.type == LivestreamUserType.coHost) {
        Get.bottomSheet(
                LiveStreamSummary(
                    userState: userState, isHost: isHost, viewers: viewers),
                isScrollControlled: true)
            .then((value) {
          updateUserStateToFirestore(myUserId,
              battleCoin: 0,
              liveCoin: 0,
              currentBattleCoin: 0,
              type: LivestreamUserType.audience);
          if (_roomId.isEmpty) {
            Get.back();
          }
        });
      }
    }
  }

  togglePlayerAudioToggle() {
    videoPlayerController.value?.setVolume(isPlayerMute.value ? 1 : 0);
    isPlayerMute.value = !isPlayerMute.value;
  }

  void toggleView() {
    isViewVisible.value = !isViewVisible.value;
  }

  void startBattle() {
    updateLiveStreamData(
      battleType: BattleType.waiting,
      battleDuration: AppRes.battleDurationInMinutes,
      battleCreatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  void battleRunning() {
    Livestream stream = liveData.value;

    final startTime =
        DateTime.fromMillisecondsSinceEpoch(stream.battleCreatedAt ?? 0);
    final endTime = startTime
        .add(Duration(seconds: totalBattleSecond + AppRes.battleStartInSecond));

    Loggers.success('Battle Timer Started');

    _timerStart(() {
      final remaining = endTime.difference(DateTime.now()).inSeconds;
      remainingBattleSeconds.value = remaining.clamp(0, totalBattleSecond);

      if (remainingBattleSeconds.value <= 10) {
        if (!countdownPlayer.playing) {
          countdownPlayer
              .seek(Duration(seconds: 10 - remainingBattleSeconds.value));
          countdownPlayer.play();
        }
      }

      Loggers.info(
          '[BATTLE RUNNING] Battle end in ${remainingBattleSeconds.value} sec.');

      if (remainingBattleSeconds.value <= 0) {
        winAudioPlayer.seek(const Duration(seconds: 0));
        winAudioPlayer.play();
        timer?.cancel();
        updateLiveStreamData(battleType: BattleType.end);
      }
    });
  }

  void startMinViewerTimeoutCheck() {
    if (minViewerTimeoutTimer?.isActive ?? false) return;
    Loggers.info(
        'Check Min. Viewers Required to continue live $timeoutMinutes Minutes');
    minViewerTimeoutTimer =
        Timer.periodic(Duration(minutes: timeoutMinutes), (_) {
      minViewerTimeoutTimer?.cancel();
      if ((liveData.value.watchingCount ?? 0) <= minViewersThreshold) {
        isMinViewerTimeout.value = true;
        Loggers.info('Close Stream Because of Min. Viewers');
      }
    });
  }

  void onCloseAudienceBtn() {
    HapticManager.shared.light();
    Get.bottomSheet(ConfirmationSheet(
        title: LKey.exitLiveStreamTitle.tr,
        description: LKey.exitLiveStreamDescription.tr,
        onTap: () async {
          adsController.showInterstitialAdIfAvailable();
          if (liveData.value.coHostIds?.contains(myUserId) ?? false) {
            closeCoHostStream(myUserId);
          }
          logoutRoom();
        }));
  }

  void pushNotificationToFollowers(Livestream liveData) {
    AppUser? hostUser = liveData.getHostUser([]);
    NotificationService.instance.pushNotification(
        type: NotificationType.liveStream,
        title: LKey.liveStreamNotificationTitle
            .trParams({'name': hostUser?.username ?? ''}),
        body: LKey.liveStreamNotificationBody.tr,
        deviceType: 1,
        topic: '${liveData.hostId}_ios',
        data: liveData.toJson());
    NotificationService.instance.pushNotification(
        type: NotificationType.liveStream,
        title: LKey.liveStreamNotificationTitle
            .trParams({'name': hostUser?.username ?? ''}),
        body: LKey.liveStreamNotificationBody.tr,
        deviceType: 0,
        topic: '${liveData.hostId}_android',
        data: liveData.toJson());
  }

  // ── Polls (via Socket.IO) ───────────────────────────────────────────

  Future<void> createPoll(String question, List<String> optionTexts) async {
    if (question.trim().isEmpty || optionTexts.length < 2) return;
    int time = DateTime.now().millisecondsSinceEpoch;
    String pollId = '$time';

    LivestreamSocketService.instance.createPoll({
      'room_id': _roomId,
      'id': pollId,
      'question': question.trim(),
      'options': optionTexts.map((t) => {'text': t.trim()}).toList(),
    });
  }

  Future<void> votePoll(int optionIndex) async {
    final poll = activePoll.value;
    if (poll == null || poll.id == null) return;
    if (poll.hasVoted(myUserId)) return;

    LivestreamSocketService.instance.votePoll(_roomId, poll.id!, optionIndex);
  }

  Future<void> endPoll() async {
    final poll = activePoll.value;
    if (poll == null || poll.id == null) return;

    LivestreamSocketService.instance.endPoll(_roomId, poll.id!);
  }

  // ── Q&A (via Socket.IO) ────────────────────────────────────────────

  Future<void> submitQuestion(String questionText) async {
    if (questionText.trim().isEmpty) return;
    int time = DateTime.now().millisecondsSinceEpoch;
    String qId = '$time';

    final user = myUser.value;
    LivestreamSocketService.instance.askQuestion({
      'room_id': _roomId,
      'id': qId,
      'username': user?.username ?? '',
      'question': questionText.trim(),
    });
  }

  Future<void> upvoteQuestion(LiveQAQuestion q) async {
    if (q.id == null) return;
    if (q.hasUpvoted(myUserId)) return;

    LivestreamSocketService.instance.upvoteQuestion(_roomId, q.id!);
  }

  Future<void> pinQuestion(LiveQAQuestion q) async {
    if (q.id == null) return;
    bool newPinned = !(q.isPinned ?? false);
    LivestreamSocketService.instance.pinQuestion(_roomId, q.id!, newPinned);
  }

  Future<void> markQuestionAnswered(LiveQAQuestion q) async {
    if (q.id == null) return;
    LivestreamSocketService.instance.answerQuestion(_roomId, q.id!);
  }

  // ── Live Shopping ──────────────────────────────────────────────────

  RxList<LiveShoppingProduct> liveShoppingProducts = <LiveShoppingProduct>[].obs;
  RxList<Product> myProducts = <Product>[].obs;
  RxBool isLoadingShoppingProducts = false.obs;
  Rx<LiveShoppingProduct?> pinnedProduct = Rx(null);

  Future<void> fetchLiveShoppingProducts() async {
    final roomId = liveData.value.roomID;
    if (roomId == null || roomId.isEmpty) return;
    isLoadingShoppingProducts.value = true;
    try {
      final response = await LiveShoppingService.instance.fetchLiveProducts(roomId: roomId);
      if (response.status == true && response.data != null) {
        liveShoppingProducts.assignAll(response.data!);
        pinnedProduct.value = liveShoppingProducts.firstWhereOrNull((p) => p.isPinned == true);
      }
    } catch (e) {
      Loggers.error('fetchLiveShoppingProducts error: $e');
    }
    isLoadingShoppingProducts.value = false;
  }

  Future<void> fetchMyProductsForLive() async {
    try {
      final response = await ProductService.instance.fetchMyProducts();
      if (response.status == true && response.data != null) {
        myProducts.assignAll(response.data!);
      }
    } catch (e) {
      Loggers.error('fetchMyProductsForLive error: $e');
    }
  }

  Future<void> addProductToLive(int productId) async {
    final roomId = liveData.value.roomID;
    if (roomId == null) return;
    try {
      final response = await LiveShoppingService.instance.addProductToLive(
        roomId: roomId,
        productId: productId,
      );
      if (response.status == true) {
        showSnackBar(LKey.productAddedToLive);
        fetchLiveShoppingProducts();
      } else {
        showSnackBar(response.message ?? 'Failed');
      }
    } catch (e) {
      Loggers.error('addProductToLive error: $e');
    }
  }

  Future<void> removeProductFromLive(int productId) async {
    final roomId = liveData.value.roomID;
    if (roomId == null) return;
    try {
      final response = await LiveShoppingService.instance.removeProductFromLive(
        roomId: roomId,
        productId: productId,
      );
      if (response.status == true) {
        liveShoppingProducts.removeWhere((p) => p.productId == productId);
        if (pinnedProduct.value?.productId == productId) {
          pinnedProduct.value = null;
        }
        showSnackBar(LKey.productRemovedFromLive);
      }
    } catch (e) {
      Loggers.error('removeProductFromLive error: $e');
    }
  }

  Future<void> togglePinProduct(LiveShoppingProduct item) async {
    final roomId = liveData.value.roomID;
    if (roomId == null || item.productId == null) return;
    try {
      if (item.isPinned == true) {
        final response = await LiveShoppingService.instance.unpinProduct(
          roomId: roomId,
          productId: item.productId!,
        );
        if (response.status == true) {
          item.isPinned = false;
          pinnedProduct.value = null;
          liveShoppingProducts.refresh();
          showSnackBar(LKey.productUnpinned);
        }
      } else {
        final response = await LiveShoppingService.instance.pinProduct(
          roomId: roomId,
          productId: item.productId!,
        );
        if (response.status == true) {
          for (var p in liveShoppingProducts) {
            p.isPinned = false;
          }
          item.isPinned = true;
          pinnedProduct.value = item;
          liveShoppingProducts.refresh();
          showSnackBar(LKey.productPinned);
        }
      }
    } catch (e) {
      Loggers.error('togglePinProduct error: $e');
    }
  }

  Future<void> addToCartFromLive(int productId) async {
    final roomId = liveData.value.roomID;
    try {
      final response = await LiveShoppingService.instance.addToCartFromLive(
        productId: productId,
        roomId: roomId,
      );
      if (response.status == true) {
        showSnackBar(LKey.addedToCart);
      } else {
        showSnackBar(response.message ?? 'Failed');
      }
    } catch (e) {
      Loggers.error('addToCartFromLive error: $e');
    }
  }

  // ── Flash Sale ──────────────────────────────────────────────────────

  Rx<LiveShoppingProduct?> flashSaleProduct = Rx(null);
  RxInt flashSaleSecondsLeft = 0.obs;
  RxInt flashSaleDiscountPercent = 0.obs;
  Timer? _flashSaleTimer;

  void startFlashSale({
    required LiveShoppingProduct product,
    required int durationSeconds,
    required int discountPercent,
  }) {
    stopFlashSale();
    flashSaleProduct.value = product;
    flashSaleSecondsLeft.value = durationSeconds;
    flashSaleDiscountPercent.value = discountPercent;

    _flashSaleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (flashSaleSecondsLeft.value <= 1) {
        stopFlashSale();
      } else {
        flashSaleSecondsLeft.value--;
      }
    });
  }

  void stopFlashSale() {
    _flashSaleTimer?.cancel();
    _flashSaleTimer = null;
    flashSaleProduct.value = null;
    flashSaleSecondsLeft.value = 0;
    flashSaleDiscountPercent.value = 0;
  }

  // ── Giveaway ────────────────────────────────────────────────────────

  RxBool isGiveawayActive = false.obs;
  RxString giveawayPrize = ''.obs;
  Rx<String?> giveawayWinner = Rx(null);
  RxBool isPickingWinner = false.obs;

  void startGiveaway(String prize) {
    giveawayPrize.value = prize;
    isGiveawayActive.value = true;
    giveawayWinner.value = null;
  }

  void pickGiveawayWinner() {
    if (!isGiveawayActive.value) return;
    final viewers = audienceList;
    if (viewers.isEmpty) {
      showSnackBar('No viewers to pick from');
      return;
    }
    isPickingWinner.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      final random = viewers[DateTime.now().millisecondsSinceEpoch % viewers.length];
      giveawayWinner.value = random.user?.username ?? 'Viewer';
      isPickingWinner.value = false;
    });
  }

  void endGiveaway() {
    isGiveawayActive.value = false;
    giveawayPrize.value = '';
    giveawayWinner.value = null;
  }

  // ── Billboard / Promo Banner ────────────────────────────────────────

  RxString promoBannerText = ''.obs;
  RxBool isPromoBannerVisible = false.obs;

  void showPromoBanner(String text) {
    promoBannerText.value = text;
    isPromoBannerVisible.value = true;
  }

  void hidePromoBanner() {
    isPromoBannerVisible.value = false;
    promoBannerText.value = '';
  }
}

class StreamView {
  String streamId;
  int streamViewId;
  Widget streamView;
  bool isMuted;

  StreamView(this.streamId, this.streamViewId, this.streamView, this.isMuted);
}
