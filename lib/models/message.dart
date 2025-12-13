/// Message model for chat conversations
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String? content;
  final String? messageType; // 'text', 'image', etc.
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool edited;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    this.messageType = 'text',
    required this.createdAt,
    this.updatedAt,
    this.edited = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      edited: json['edited'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'edited': edited,
    };
  }
}

/// Conversation model
class Conversation {
  final String id;
  final String? title;
  final bool isBotConversation; // true for SmartBot
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> memberIds;

  Conversation({
    required this.id,
    this.title,
    this.isBotConversation = false,
    required this.createdAt,
    this.updatedAt,
    this.memberIds = const [],
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String?,
      isBotConversation: json['is_bot_conversation'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      memberIds: (json['member_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_bot_conversation': isBotConversation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'member_ids': memberIds,
    };
  }
}

