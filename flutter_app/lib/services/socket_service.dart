// lib/services/socket_service.dart
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef OnUsersList = void Function(List<dynamic> users);
typedef OnNewMessage = void Function(Map<String, dynamic> message);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final _usersController = StreamController<List<dynamic>>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<List<dynamic>> get usersStream => _usersController.stream;
  Stream<Map<String, dynamic>> get messagesStream => _messageController.stream;

  void connect({required String url}) {
    if (_socket != null && _socket!.connected) return;
    _socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
    });
    _socket!.on('connect', (_) {
      // print('socket connected ${_socket!.id}');
    });
    _socket!.on('users_list', (data) {
      try {
        final users = data['users'] as List<dynamic>;
        _usersController.add(users);
      } catch (_) {
        _usersController.add([]);
      }
    });
    _socket!.on('new_message', (data) {
      if (data is Map<String, dynamic>) {
        _messageController.add(data);
      } else if (data is Map) {
        _messageController.add(Map<String, dynamic>.from(data));
      }
    });
    _socket!.on('disconnect', (_) {
      // print('socket disconnected');
    });
  }

  void identify(int userId) {
    _socket?.emit('identify', {'user_id': userId});
  }

  void sendMessage(int senderId, int receiverId, String ciphertext) {
    _socket?.emit('client_send', {'sender_id': senderId, 'receiver_id': receiverId, 'ciphertext': ciphertext});
  }

  void dispose() {
    _usersController.close();
    _messageController.close();
    _socket?.disconnect();
    _socket = null;
  }
}
