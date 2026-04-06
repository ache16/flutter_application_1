import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

class SocketService extends GetxService {
  IO.Socket? _socket;
  
  final RxBool isConnected = false.obs;
  final RxMap<String, dynamic> onlineUsers = <String, dynamic>{}.obs;
  final _messageListeners = <Function(Map<String, dynamic>)>[];
  final _typingListeners = <Function(Map<String, dynamic>)>[];

  void connect() {
    final storage = Get.find<StorageService>();
    final token = storage.getToken();
    final user = storage.getUser();
    
    if (token == null || user == null) {
      AppLogger.w('Socket: 未登录，无法连接');
      return;
    }

    _socket = IO.io('http://211.159.186.157:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
      'auth': {'token': token},
    });

    _socket!.onConnect((_) {
      isConnected.value = true;
      AppLogger.i('✅ Socket 已连接');
      
      // 加入用户房间
      _socket!.emit('join', user['id'].toString());
      AppLogger.d('Socket: 加入房间 ${user['id']}');
    });

    _socket!.onDisconnect((_) {
      isConnected.value = false;
      AppLogger.w('⚠️ Socket 已断开');
    });

    _socket!.onReconnect((_) {
      AppLogger.i('🔄 Socket 重新连接');
    });

    _socket!.onReconnectError((error) {
      AppLogger.e('❌ Socket 重连失败: $error');
    });

    // 接收新消息
    _socket!.on('new_message', (data) {
      AppLogger.d('📨 收到新消息: $data');
      for (var listener in _messageListeners) {
        listener(data);
      }
    });

    // 接收正在输入状态
    _socket!.on('typing', (data) {
      AppLogger.d('⌨️ 对方正在输入: $data');
      for (var listener in _typingListeners) {
        listener(data);
      }
    });

    // 用户上线/下线
    _socket!.on('user_online', (data) {
      AppLogger.d('🟢 用户上线: $data');
      onlineUsers[data['userId']] = true;
    });

    _socket!.on('user_offline', (data) {
      AppLogger.d('🔴 用户离线: $data');
      onlineUsers[data['userId']] = false;
    });

    _socket!.onConnectError((error) {
      AppLogger.e('Socket 连接错误: $error');
    });

    _socket!.onError((error) {
      AppLogger.e('Socket 错误: $error');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    isConnected.value = false;
    AppLogger.i('Socket 已断开连接');
  }

  // 发送私聊消息
  void sendMessage(String receiverId, String content, {String type = 'text'}) {
    final user = Get.find<StorageService>().getUser();
    if (user == null) return;

    _socket?.emit('private_message', {
      'senderId': user['id'].toString(),
      'receiverId': receiverId,
      'content': content,
      'type': type,
    });
    
    AppLogger.d('📤 发送消息给 $receiverId');
  }

  // 发送正在输入状态
  void sendTyping(String receiverId, bool isTyping) {
    final user = Get.find<StorageService>().getUser();
    if (user == null) return;

    _socket?.emit('typing', {
      'senderId': user['id'].toString(),
      'receiverId': receiverId,
      'isTyping': isTyping,
    });
  }

  // 添加消息监听器
  void addMessageListener(Function(Map<String, dynamic>) listener) {
    _messageListeners.add(listener);
  }

  void removeMessageListener(Function(Map<String, dynamic>) listener) {
    _messageListeners.remove(listener);
  }

  // 添加输入状态监听器
  void addTypingListener(Function(Map<String, dynamic>) listener) {
    _typingListeners.add(listener);
  }

  void removeTypingListener(Function(Map<String, dynamic>) listener) {
    _typingListeners.remove(listener);
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
