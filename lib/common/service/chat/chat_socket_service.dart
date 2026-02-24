import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/utils/web_service.dart';

class ChatSocketService {
  static final ChatSocketService instance = ChatSocketService._();
  ChatSocketService._();

  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (_socket != null && _socket!.connected) return;

    final token = SessionManager.instance.getAuthToken();
    _socket = io.io(
      WebService.chat.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(999999)
          .build(),
    );

    _socket!.onConnect((_) {
      Loggers.info('[Chat] Connected');
    });

    _socket!.onDisconnect((_) {
      Loggers.info('[Chat] Disconnected');
    });

    _socket!.onConnectError((err) {
      Loggers.error('[Chat] Connection error: $err');
    });

    _socket!.onReconnect((_) {
      Loggers.info('[Chat] Reconnected');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void emit(String event, Map<String, dynamic> data) {
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
