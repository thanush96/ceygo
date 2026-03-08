class ChatConversation {
  final String userId;
  final String userName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isOnline;
  final int unreadCount;

  ChatConversation({
    required this.userId,
    required this.userName,
    this.lastMessage,
    this.lastMessageTime,
    this.isOnline = false,
    this.unreadCount = 0,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final lastMsg = json['lastMessage'] as Map<String, dynamic>?;

    return ChatConversation(
      userId: user?['id'] as String? ?? json['userId'] as String,
      userName: _buildUserName(user),
      lastMessage: lastMsg?['message'] as String? ?? json['lastMessage'] as String?,
      lastMessageTime: lastMsg?['timestamp'] != null
          ? DateTime.parse(lastMsg!['timestamp'] as String)
          : null,
      isOnline: json['isOnline'] as bool? ?? false,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  static String _buildUserName(Map<String, dynamic>? user) {
    if (user == null) return 'Unknown';
    // User entity has a single 'name' field
    final name = user['name'] as String? ?? '';
    if (name.isNotEmpty) return name;
    // Fallback for firstName/lastName if ever used
    final first = user['firstName'] as String? ?? '';
    final last = user['lastName'] as String? ?? '';
    final fullName = '$first $last'.trim();
    return fullName.isEmpty ? 'User' : fullName;
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final bool isRead;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.isRead = false,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    final receiver = json['receiver'];

    return ChatMessage(
      id: json['id'] as String,
      senderId: sender is Map ? sender['id'] as String : sender as String,
      receiverId: receiver is Map ? receiver['id'] as String : receiver as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
