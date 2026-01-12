import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ceygo_app/core/widgets/custom_app_bar.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: "1",
      customerName: "John Doe",
      profileImage: "https://via.placeholder.com/50?text=JD",
      lastMessage: "Yes, it is available. Would you like to book it?",
      lastMessageTime: "10:05 AM",
      isOnline: true,
      unreadCount: 0,
    ),
    ChatConversation(
      id: "2",
      customerName: "Sarah Smith",
      profileImage: "https://via.placeholder.com/50?text=SS",
      lastMessage: "Thank you for the quick response!",
      lastMessageTime: "Yesterday",
      isOnline: false,
      unreadCount: 2,
    ),
    ChatConversation(
      id: "3",
      customerName: "Michael Johnson",
      profileImage: "https://via.placeholder.com/50?text=MJ",
      lastMessage: "When can I pick up the car?",
      lastMessageTime: "2 hours ago",
      isOnline: true,
      unreadCount: 1,
    ),
    ChatConversation(
      id: "4",
      customerName: "Emma Williams",
      profileImage: "https://via.placeholder.com/50?text=EW",
      lastMessage: "Perfect! I'll confirm the booking tomorrow.",
      lastMessageTime: "3 days ago",
      isOnline: false,
      unreadCount: 0,
    ),
    ChatConversation(
      id: "5",
      customerName: "David Brown",
      profileImage: "https://via.placeholder.com/50?text=DB",
      lastMessage: "Can I get a discount for weekly rental?",
      lastMessageTime: "1 week ago",
      isOnline: false,
      unreadCount: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
        title: "Messages",
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16),
        //     child: IconButton(
        //       icon: const Icon(Icons.add, color: Colors.black, size: 28),
        //       onPressed: () {
        //         // Handle new chat
        //       },
        //     ),
        //   ),
        // ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _buildChatTile(context, conversation);
        },
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatConversation conversation) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigate to chat detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatDetailScreen(conversation: conversation),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Profile Picture with Online Status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      conversation.customerName
                          .split(' ')
                          .map((e) => e[0])
                          .join(),
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
              // Chat Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conversation.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          conversation.lastMessageTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
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
}

class ChatDetailScreen extends StatefulWidget {
  final ChatConversation conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _showEmojiPicker = false;

  final List<String> _emojis = [
    '😀',
    '😂',
    '❤️',
    '👍',
    '🎉',
    '🔥',
    '😍',
    '🎈',
    '🙌',
    '✨',
    '😎',
    '👌',
    '🚀',
    '💪',
    '🌟',
    '😊',
    '😢',
    '😴',
    '🤔',
    '😱',
    '🤗',
    '😘',
    '😝',
    '🙈',
    '🐱',
    '🐶',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🐨',
    '🐯',
    '🍕',
    '🍔',
    '🍟',
    '🌮',
    '🍜',
    '🍱',
    '🍰',
    '🍪',
    '☕',
    '🍷',
    '🍺',
    '⚽',
    '🏀',
    '🎾',
    '🎮',
    '🎲',
  ];

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  void _initializeMessages() {
    _messages.addAll([
      Message(
        text: "Hi, is the car available for tomorrow?",
        isMe: true,
        time: "10:00 AM",
      ),
      Message(
        text: widget.conversation.lastMessage,
        isMe: false,
        time: "10:05 AM",
      ),
    ]);
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(Message(text: _controller.text, isMe: true, time: "Now"));
        _controller.clear();
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add(
              Message(
                text: "Thanks for your message!",
                isMe: false,
                time: "Now",
              ),
            );
          });
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _messages.add(
            Message(imagePath: image.path, isMe: true, time: "Now"),
          );
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _messages.add(
                Message(text: "Nice image!", isMe: false, time: "Now"),
              );
            });
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error picking image')));
    }
  }

  void _insertEmoji(String emoji) {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText = text.replaceRange(selection.start, selection.end, emoji);
    _controller.value = _controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emoji.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[400],
                child: Text(
                  widget.conversation.customerName
                      .split(' ')
                      .map((e) => e[0])
                      .join(),
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
                    widget.conversation.customerName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.conversation.isOnline ? "Online" : "Offline",
                    style: TextStyle(
                      color:
                          widget.conversation.isOnline
                              ? Colors.green
                              : Colors.grey,
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
                decoration: BoxDecoration(
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
            // IconButton(
            //   icon: const Icon(Icons.more_vert, color: Colors.black),
            //   onPressed: () {},
            // ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment:
                        msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            msg.isMe
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft:
                              msg.isMe
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                          bottomRight:
                              msg.isMe
                                  ? Radius.zero
                                  : const Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (msg.imagePath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(msg.imagePath!),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (msg.text != null)
                            Text(
                              msg.text!,
                              style: TextStyle(
                                color: msg.isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            msg.time,
                            style: TextStyle(
                              color: msg.isMe ? Colors.white70 : Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                            ),
                        itemCount: _emojis.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              _insertEmoji(_emojis[index]);
                            },
                            child: Center(
                              child: Text(
                                _emojis[index],
                                style: const TextStyle(fontSize: 32),
                              ),
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
                        onPressed: () {
                          setState(() {
                            _showEmojiPicker = !_showEmojiPicker;
                          });
                        },
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
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.5),
                                width: 1.6,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.5),
                                width: 1.6,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ChatConversation {
  final String id;
  final String customerName;
  final String profileImage;
  final String lastMessage;
  final String lastMessageTime;
  final bool isOnline;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.customerName,
    required this.profileImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isOnline,
    required this.unreadCount,
  });
}

class Message {
  final String? text;
  final bool isMe;
  final String time;
  final String? imagePath;

  Message({this.text, required this.isMe, required this.time, this.imagePath});
}
