import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart' show SessionManager;
import 'package:shortzz/common/service/api/notification_service.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/languages/dynamic_translations.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/call/call_model.dart';
import 'package:shortzz/screen/call_screen/call_helper.dart';
import 'package:shortzz/screen/chat_screen/chat_screen.dart';
import 'package:shortzz/screen/chat_screen/chat_screen_controller.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/audience/live_stream_audience_screen.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/host/livestream_host_screen.dart';
import 'package:shortzz/screen/post_screen/single_post_screen.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/common/service/live/livestream_api_service.dart';
import 'package:shortzz/utilities/const_res.dart';

const String _chatQuickReplyUrl = 'http://168.231.123.230:3002/api/chat/quick-reply';
const String _chatReplyActionId = 'reply';
const String _chatCategoryId = 'chat_reply';

/// Background isolate handler — called when user taps an action on a
/// notification while the app is not in the foreground.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  // Quick reply: user typed a reply directly from the notification shade
  if (notificationResponse.actionId == _chatReplyActionId &&
      notificationResponse.input != null &&
      notificationResponse.input!.trim().isNotEmpty) {
    try {
      final payload = notificationResponse.payload;
      if (payload == null) return;

      final msgMap = jsonDecode(payload) as Map<String, dynamic>;
      final data = (msgMap['data'] as Map?)?.cast<String, dynamic>() ?? {};

      final authToken = data['reply_auth_token'] as String? ?? '';
      final conversationId = data['conversation_id'] as String? ?? '';
      final replyText = notificationResponse.input!.trim();

      if (authToken.isEmpty || conversationId.isEmpty) return;

      await http.post(
        Uri.parse(_chatQuickReplyUrl),
        headers: {
          'Content-Type': 'application/json',
          'authtoken': authToken,
        },
        body: jsonEncode({
          'conversation_id': conversationId,
          'text': replyText,
        }),
      );
    } catch (e) {
      print('[QuickReply background] error: $e');
    }
    return;
  }

  // Regular notification tap (not an action): navigation is handled by
  // FirebaseMessaging.onMessageOpenedApp or getInitialMessage — nothing to do here.
}

class FirebaseNotificationManager {
  FirebaseNotificationManager._() {
    init();
  }

  static final instance = FirebaseNotificationManager._();

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  RxString notificationPayload = ''.obs;

  /// Channel for regular messages
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'shortzz',
      'Shortzz',
      playSound: true,
      enableLights: true,
      enableVibration: true,
      showBadge: false,
      importance: Importance.max);

  /// Channel for messages that support quick reply (needs HIGH importance)
  AndroidNotificationChannel chatChannel = const AndroidNotificationChannel(
      'shortzz_chat',
      'Shortzz Messages',
      playSound: true,
      enableLights: true,
      enableVibration: true,
      showBadge: true,
      importance: Importance.max);

  String? notificationId;

  void init() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, sound: true);
      await firebaseMessaging.requestPermission(alert: true, badge: false, sound: true);
    }

    subscribeToTopic();

    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS: register notification category with text input action for quick reply
    final chatCategory = DarwinNotificationCategory(
      _chatCategoryId,
      actions: [
        DarwinNotificationAction.text(
          _chatReplyActionId,
          'Reply',
          buttonTitle: 'Send',
          placeholder: 'Message...',
        ),
      ],
      options: {DarwinNotificationCategoryOption.hiddenPreviewShowTitle},
    );

    var initializationSettingsIOS = DarwinInitializationSettings(
        defaultPresentAlert: true,
        defaultPresentSound: true,
        defaultPresentBadge: false,
        notificationCategories: [chatCategory]);

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('onDidReceiveNotificationResponse actionId:${response.actionId} input:${response.input}');

          // Quick reply in foreground — send via HTTP
          if (response.actionId == _chatReplyActionId &&
              response.input != null &&
              response.input!.trim().isNotEmpty) {
            _handleForegroundQuickReply(response);
            return;
          }

          // Regular tap — navigate to the conversation
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            notificationPayload.value = payload;
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

    // Watch notificationPayload — navigate whenever a local notification is tapped
    ever(notificationPayload, (String payload) {
      if (payload.isNotEmpty) {
        handleNotification(payload);
        // Reset so the same payload can trigger again if needed
        Future.microtask(() => notificationPayload.value = '');
      }
    });

    // Handle FCM notification when app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (notificationId == message.messageId) return;
      notificationId = message.messageId;

      final data = message.data['notification_data'] ?? '';

      if (message.data['type'] == NotificationType.chat.type) {
        if (data.isNotEmpty) {
          try {
            final conversationUser = ChatThread.fromJson(jsonDecode(data));
            if (conversationUser.conversationId == ChatScreenController.chatId) {
              return; // Already viewing this chat
            }
          } catch (_) {}
        }
      } else {
        SessionManager.instance.setNotifyCount(1);
      }
      showNotification(message);
    });

    // Handle notification tap when app comes from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Loggers.info('User tapped the notification: ${message.data}');
      if (message.data.isNotEmpty) {
        handleNotification(jsonEncode(message.toMap()));
      }
    });

    // Create Android notification channels
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(chatChannel);

    // Handle notification tap when app was fully terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && message.data.isNotEmpty) {
        // Delay to let the app finish initializing before navigating
        Future.delayed(const Duration(seconds: 2), () {
          handleNotification(jsonEncode(message.toMap()));
        });
      }
    });
  }

  void _handleForegroundQuickReply(NotificationResponse response) async {
    try {
      final payload = response.payload;
      if (payload == null) return;

      final msgMap = jsonDecode(payload) as Map<String, dynamic>;
      final data = (msgMap['data'] as Map?)?.cast<String, dynamic>() ?? {};

      final authToken = data['reply_auth_token'] as String? ?? '';
      final conversationId = data['conversation_id'] as String? ?? '';
      final replyText = response.input!.trim();

      if (authToken.isEmpty || conversationId.isEmpty) return;

      await http.post(
        Uri.parse(_chatQuickReplyUrl),
        headers: {
          'Content-Type': 'application/json',
          'authtoken': authToken,
        },
        body: jsonEncode({
          'conversation_id': conversationId,
          'text': replyText,
        }),
      );
    } catch (e) {
      Loggers.error('Quick reply foreground error: $e');
    }
  }

  void unsubscribeToTopic({String? topic}) async {
    Loggers.success(
        '🔔 Topic UnSubscribe : ${topic ?? notificationTopic}_${Platform.isAndroid ? 'android' : 'ios'}');
    await firebaseMessaging.unsubscribeFromTopic(
        '${topic ?? notificationTopic}_${Platform.isAndroid ? 'android' : 'ios'}');
    if (kDebugMode) {
      await firebaseMessaging.unsubscribeFromTopic(
          'test_${topic ?? notificationTopic}_${Platform.isAndroid ? 'android' : 'ios'}');
    }
  }

  Future<void> subscribeToTopic({String? topic}) async {
    Loggers.success(
        '🔔 Topic Subscribe : ${topic ?? notificationTopic}_${Platform.isAndroid ? 'android' : 'ios'}');
    await firebaseMessaging.subscribeToTopic(
        '${topic ?? notificationTopic}_${Platform.isAndroid ? 'android' : 'ios'}');

    if (kDebugMode) {
      await firebaseMessaging.subscribeToTopic(
          'test_${topic ?? notificationTopic}_${Platform.isAndroid ? 'android' : 'ios'}');
    }
  }

  void showNotification(RemoteMessage message) {
    print('SHOW MESSAGE : ${message.toMap()}');
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final isChatNotification = message.data['type'] == NotificationType.chat.type;

    flutterLocalNotificationsPlugin.show(
        id: id,
        title: (message.data['title']) ?? message.notification?.title,
        body: (message.data['body'] as String?) ?? message.notification?.body,
        notificationDetails: NotificationDetails(
            iOS: DarwinNotificationDetails(
                presentSound: true,
                presentAlert: true,
                presentBadge: false,
                categoryIdentifier: isChatNotification ? _chatCategoryId : null),
            android: AndroidNotificationDetails(
              isChatNotification ? chatChannel.id : channel.id,
              isChatNotification ? chatChannel.name : channel.name,
              actions: isChatNotification
                  ? [
                      const AndroidNotificationAction(
                        _chatReplyActionId,
                        'Reply',
                        showsUserInterface: false,
                        inputs: [AndroidNotificationActionInput(label: 'Message...')],
                      ),
                    ]
                  : null,
            )),
        payload: jsonEncode(message.toMap()));
  }

  Future<void> handleNotification(String payload) async {
    final RemoteMessage message = RemoteMessage.fromMap(jsonDecode(payload));
    final dataType = message.data['type'];
    final dataString = message.data['notification_data'];
    print('DATA TYPE : $dataType');
    print('DATA STRING : $dataString');
    if (dataType == null || dataString == null || dataString.isEmpty) return;
    final controller = Get.put(DashboardScreenController());
    switch (dataType) {
      case 'chat':
        Future.delayed(const Duration(milliseconds: 500), () async {
          controller.selectedPageIndex.value = 4;
          await _handleChatNotification(dataString);
        });

        break;
      case 'post':
        await _handlePostNotification(dataString, controller);
        break;
      case 'user':
        controller.selectedPageIndex.value = 5;
        await _handleUserNotification(dataString);
        break;
      case 'live_stream':
        controller.selectedPageIndex.value = 2;
        await _handleLivestreamNotification(dataString);
        break;
      case 'call':
        _handleCallNotification(dataString);
        break;
      default:
        Loggers.warning('Unknown notification type: $dataType');
    }
  }

  Future<void> _handleChatNotification(String data) async {
    try {
      final conversationUser = ChatThread.fromJson(jsonDecode(data));
      Loggers.info('Navigating to chat: ${conversationUser.toJson()}');
      await Get.to(() => ChatScreen(conversationUser: conversationUser));
    } catch (e) {
      Loggers.error('Failed to handle chat notification: $e');
    }
  }

  Future<void> _handlePostNotification(String data, DashboardScreenController controller) async {
    try {
      NotificationInfo notificationInfo = NotificationInfo.fromJson(jsonDecode(data));
      final int postId = notificationInfo.id ?? -1;
      final int? commentId = notificationInfo.commentId;
      final int? replyId = notificationInfo.replyCommentId;
      final result = await PostService.instance
          .fetchPostById(postId: postId, commentId: commentId, replyId: replyId);

      if (result.status == true && result.data != null) {
        final Post? post = result.data?.post;
        if (post == null) return;

        if (post.postType == PostType.reel) {
          controller.selectedPageIndex.value = 5;
          Get.to(() => ReelsScreen(reels: [post].obs, position: 0, postByIdData: result.data));
        } else if ([PostType.text, PostType.image, PostType.video].contains(post.postType)) {
          controller.selectedPageIndex.value = 1;
          await Get.to(() =>
              SinglePostScreen(post: post, postByIdData: result.data, isFromNotification: true));
        }
      }
    } catch (e) {
      Loggers.error('Failed to handle post notification: $e');
    }
  }

  Future<void> _handleUserNotification(String data) async {
    try {
      final map = jsonDecode(data);
      final int id = map['id'];
      final user = await UserService.instance.fetchUserDetails(userId: id);

      if (user != null) {
        Loggers.success('Navigating to user: ${user.id}');
        NavigationService.shared.openProfileScreen(user);
      }
    } catch (e) {
      Loggers.error('Failed to handle user notification: $e');
    }
  }

  Future<String?> getNotificationToken() async {
    try {
      String? token = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      Loggers.info('DeviceToken $token');
      return token;
    } catch (e) {
      Loggers.error('DeviceToken Exception $e');
      return null;
    }
  }

  Future<void> sendLocalisationNotification(
    String key, {
    Map<String, String> keyParams = const {},
    String? deviceToken = '',
    int? deviceType = 0,
    String? languageCode = 'en',
    required NotificationInfo body,
    required NotificationType type,
  }) async {
    if ((deviceToken ?? '').isEmpty) {
      Loggers.error('Device Token Empty - Notification not sent for key: $key');
      return;
    }

    final user = SessionManager.instance.getUser();
    final title = user?.fullname ?? '';

    final translations = Get.find<DynamicTranslations>();
    final languageData = translations.keys[languageCode] ?? {};

    var description = languageData[key] ?? key;

    keyParams.forEach((key, value) {
      description = description.replaceAll('@$key', value);
    });

    Loggers.info('''
      [Notification Details]
      Language: $languageCode
      Key: $key
      Description: $description
      Recipient: ${user?.id ?? 'Unknown'}
      Device Type: $deviceType
      Device Token: $deviceToken
    ''');

    await NotificationService.instance.pushNotification(
        title: title,
        body: description,
        data: body.toJson(),
        deviceType: deviceType,
        token: deviceToken,
        type: type);
  }

  Future<void> _handleLivestreamNotification(String dataString) async {
    try {
      final incomingStream = Livestream.fromJson(jsonDecode(dataString));
      final roomId = incomingStream.roomID ?? '';
      if (roomId.isEmpty) {
        BaseController.share.showSnackBar(LKey.livestreamHasEnded.tr);
        return;
      }

      final result = await LivestreamApiService.instance.fetchLivestream(roomId);
      if (result == null) {
        BaseController.share.showSnackBar(LKey.livestreamHasEnded.tr);
        return;
      }

      final stream = result['livestream'];
      if (stream == null) {
        BaseController.share.showSnackBar(LKey.livestreamHasEnded.tr);
        return;
      }

      final livestream = Livestream.fromJson(stream);
      final myUser = SessionManager.instance.getUser();

      if (livestream.hostId == myUser?.id) {
        Get.to(() => LivestreamHostScreen(isHost: true, livestream: livestream));
      } else {
        Get.to(() => LiveStreamAudienceScreen(isHost: false, livestream: livestream));
      }
    } catch (e) {
      debugPrint('[LIVESTREAM] Failed to handle livestream notification: $e');
      BaseController.share.showSnackBar(LKey.livestreamHasEnded.tr);
    }
  }

  void _handleCallNotification(String dataString) {
    try {
      final callData = IncomingCallData.fromJson(jsonDecode(dataString));
      CallHelper.handleIncomingCall(callData);
    } catch (e) {
      Loggers.error('Failed to handle call notification: $e');
    }
  }
}

enum NotificationType {
  chat('chat'),
  post('post'),
  user('user'),
  liveStream('live_stream'),
  other('other');

  final String type;

  const NotificationType(this.type);
}

class NotificationInfo {
  int? id;
  int? commentId;
  int? replyCommentId;

  NotificationInfo({
    this.id,
    this.commentId,
    this.replyCommentId,
  });

  factory NotificationInfo.fromJson(Map<String, dynamic> json) => NotificationInfo(
        id: json["id"],
        commentId: json["comment_id"],
        replyCommentId: json["reply_comment_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "comment_id": commentId,
        "reply_comment_id": replyCommentId,
      };
}
