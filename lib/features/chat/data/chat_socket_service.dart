import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:ceygo_app/core/config/api_config.dart';
import 'package:ceygo_app/core/services/api_service.dart';
import 'package:ceygo_app/features/chat/domain/models/chat_models.dart';

final chatSocketServiceProvider = Provider<ChatSocketService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final service = ChatSocketService(storage);
  ref.onDispose(() => service.disconnect());
  return service;
});

class ChatSocketService {
  final dynamic _storage;
  io.Socket? _socket;
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<ChatMessage> get onMessage => _messageController.stream;
  Stream<String> get onError => _errorController.stream;
  bool get isConnected => _socket?.connected ?? false;

  ChatSocketService(this._storage);

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await _storage.getAccessToken();
    if (token == null) return;

    // Build WebSocket URL (strip /api/v1 suffix for socket connection)
    final baseUrl = ApiConfig.baseUrl;
    final wsUrl = baseUrl.replaceAll(RegExp(r'/api/v1$'), '');

    _socket = io.io(wsUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    _socket!.onConnect((_) {
      // Connected to chat server
    });

    _socket!.on('receive_message', (data) {
      try {
        final message = ChatMessage.fromJson(data as Map<String, dynamic>);
        _messageController.add(message);
      } catch (e) {
        _errorController.add('Failed to parse message');
      }
    });

    _socket!.on('error', (data) {
      _errorController.add(data.toString());
    });

    _socket!.onDisconnect((_) {
      // Disconnected from chat server
    });

    _socket!.connect();
  }

  void sendMessage(String receiverId, String message) {
    _socket?.emit('send_message', {
      'receiverId': receiverId,
      'message': message,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _errorController.close();
  }
}
