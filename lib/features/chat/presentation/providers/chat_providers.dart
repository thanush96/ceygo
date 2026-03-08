import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceygo_app/features/chat/data/chat_repository.dart';
import 'package:ceygo_app/features/chat/domain/models/chat_models.dart';

// Conversations list provider
final conversationsProvider = AsyncNotifierProvider<ConversationsNotifier, List<ChatConversation>>(
  ConversationsNotifier.new,
);

class ConversationsNotifier extends AsyncNotifier<List<ChatConversation>> {
  @override
  Future<List<ChatConversation>> build() async {
    final repo = ref.watch(chatRepositoryProvider);
    return repo.getConversations();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final repo = ref.read(chatRepositoryProvider);
      return repo.getConversations();
    });
  }
}

// Messages for a specific conversation (initial load)
final chatMessagesProvider = FutureProvider.family<List<ChatMessage>, String>((ref, userId) async {
  final repo = ref.watch(chatRepositoryProvider);
  // Mark as read
  repo.markAsRead(userId);
  final result = await repo.getMessages(userId);
  return result['items'] as List<ChatMessage>;
});

// Unread count provider
final unreadCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getUnreadCount();
});
