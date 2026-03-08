import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/core/services/api_service.dart';
import 'package:ceygo_app/features/chat/domain/models/chat_models.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(dioProvider));
});

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  Future<List<ChatConversation>> getConversations() async {
    try {
      final response = await _dio.get('/chat/conversations');
      final list = response.data as List;
      return list.map((json) => ChatConversation.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getMessages(String userId, {int page = 1}) async {
    try {
      final response = await _dio.get('/chat/$userId/messages', queryParameters: {'page': page});
      final data = response.data;
      final items = (data['items'] as List)
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
      final meta = data['meta'] as Map<String, dynamic>;
      return {
        'items': items,
        'total': meta['total'] as int,
        'page': meta['page'] as int,
        'limit': meta['limit'] as int,
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ChatMessage> sendMessage(String receiverId, String message) async {
    try {
      final response = await _dio.post('/chat/messages', data: {
        'receiverId': receiverId,
        'message': message,
      });
      return ChatMessage.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> markAsRead(String senderId) async {
    try {
      await _dio.post('/chat/read/$senderId');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/chat/unread');
      return response.data as int;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
