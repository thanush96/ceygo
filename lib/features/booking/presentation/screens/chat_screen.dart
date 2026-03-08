import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ceygo_app/core/widgets/custom_app_bar.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/features/chat/presentation/providers/chat_providers.dart';
import 'package:ceygo_app/features/chat/data/chat_repository.dart';
import 'package:ceygo_app/features/chat/data/chat_socket_service.dart';
import 'package:ceygo_app/features/chat/domain/models/chat_models.dart';
import 'package:ceygo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ceygo_app/features/auth/domain/models/auth_state.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(title: "Messages"),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "No conversations yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Book a car to start chatting with the owner",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(conversationsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _ChatTile(conversation: conversation);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load conversations', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.read(conversationsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatConversation conversation;

  const _ChatTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                userId: conversation.userId,
                userName: conversation.userName,
                isOnline: conversation.isOnline,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      _getInitials(conversation.userName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conversation.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        if (conversation.lastMessageTime != null)
                          Text(
                            _formatTime(conversation.lastMessageTime!),
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              conversation.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  final bool isOnline;

  const ChatDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.isOnline = false,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _showEmojiPicker = false;
  final List<ChatMessage> _localMessages = [];
  StreamSubscription? _socketSub;
  String? _currentUserId;

  final List<String> _emojis = [
    '😀', '😂', '❤️', '👍', '🎉', '🔥', '😍', '🎈',
    '🙌', '✨', '😎', '👌', '🚀', '💪', '🌟', '😊',
    '😢', '😴', '🤔', '😱', '🤗', '😘', '😝', '🙈',
    '🐱', '🐶', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯',
    '🍕', '🍔', '🍟', '🌮', '🍜', '🍱', '🍰', '🍪',
    '☕', '🍷', '🍺', '⚽', '🏀', '🎾', '🎮', '🎲',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupCurrentUser();
      _setupSocket();
    });
  }

  void _setupCurrentUser() {
    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      setState(() => _currentUserId = authState.user.id);
    }
  }

  void _setupSocket() async {
    final socketService = ref.read(chatSocketServiceProvider);
    await socketService.connect();

    _socketSub = socketService.onMessage.listen((message) {
      if (message.senderId == widget.userId || message.receiverId == widget.userId) {
        if (!_localMessages.any((m) => m.id == message.id)) {
          setState(() => _localMessages.add(message));
          _scrollToBottom();
        }
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    final repo = ref.read(chatRepositoryProvider);
    final socketService = ref.read(chatSocketServiceProvider);

    // Send via socket for real-time
    socketService.sendMessage(widget.userId, text);

    // Send via REST
    try {
      final sent = await repo.sendMessage(widget.userId, text);
      if (!_localMessages.any((m) => m.id == sent.id)) {
        setState(() => _localMessages.add(sent));
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final repo = ref.read(chatRepositoryProvider);
        try {
          final sent = await repo.sendMessage(widget.userId, '[Image: ${image.name}]');
          setState(() => _localMessages.add(sent));
          _scrollToBottom();
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error picking image')),
        );
      }
    }
  }

  void _insertEmoji(String emoji) {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = text.replaceRange(selection.start, selection.end, emoji);
    _controller.value = _controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.userId));

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                // Refresh conversations when going back
                ref.read(conversationsProvider.notifier).refresh();
                Navigator.pop(context);
              },
            ),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[400],
                child: Text(
                  widget.userName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.isOnline ? "Online" : "Offline",
                    style: TextStyle(
                      color: widget.isOnline ? Colors.green : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.call, color: Colors.black),
                  onPressed: () {},
                  iconSize: 20,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (apiMessages) {
                  // Combine API messages with locally added messages
                  final allMessages = [...apiMessages];
                  for (final local in _localMessages) {
                    if (!allMessages.any((m) => m.id == local.id)) {
                      allMessages.add(local);
                    }
                  }
                  allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                  if (allMessages.isEmpty) {
                    return Center(
                      child: Text(
                        'Start a conversation',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                      ),
                    );
                  }

                  // Auto scroll to bottom on first load
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: allMessages.length,
                    itemBuilder: (context, index) {
                      final msg = allMessages[index];
                      final isMe = msg.senderId == _currentUserId;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Theme.of(context).primaryColor : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.message,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatMsgTime(msg.timestamp),
                                    style: TextStyle(
                                      color: isMe ? Colors.white70 : Colors.black54,
                                      fontSize: 10,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      msg.isRead ? Icons.done_all : Icons.done,
                                      size: 14,
                                      color: msg.isRead ? Colors.lightBlueAccent : Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text('Failed to load messages', style: TextStyle(color: Colors.grey.shade600)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_showEmojiPicker)
                    Container(
                      height: 250,
                      color: Colors.white,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                        itemCount: _emojis.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => _insertEmoji(_emojis[index]),
                            child: Center(
                              child: Text(_emojis[index], style: const TextStyle(fontSize: 32)),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        onPressed: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
                      ),
                      IconButton(
                        icon: const Icon(Icons.image_outlined),
                        onPressed: _pickImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor.withOpacity(0.5),
                                width: 1.6,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor.withOpacity(0.5),
                                width: 1.6,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatMsgTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _socketSub?.cancel();
    super.dispose();
  }
}
