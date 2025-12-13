import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../models/message.dart';
import '../models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserChatScreen extends StatefulWidget {
  final String? username;
  final String? conversationId;
  final String? userId;
  
  const UserChatScreen({
    super.key,
    this.username,
    this.conversationId,
    this.userId,
  });

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _chatService = ChatService();
  final _authService = AuthService();

  List<Message> _messages = [];
  String? _conversationId;
  bool _loading = true;
  RealtimeChannel? _channel;
  Profile? _otherUserProfile;

  Future<Profile?> _loadUserProfile() async {
    if (widget.userId != null && _otherUserProfile == null) {
      try {
        _otherUserProfile = await _authService.getUserProfile(widget.userId!);
      } catch (e) {
        // Ignore errors
      }
    }
    return _otherUserProfile;
  } 
  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      // Get or create conversation (simplified - you may need to pass otherUserId)
      final user = _authService.getCurrentProfile();
      // For now, we'll need to get the conversation ID from route arguments or create it
      // This is a simplified version - adjust based on your routing
      
      // Load messages
      await _loadMessages();
      
      // Subscribe to real-time updates
      _subscribeToMessages();
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize chat: $e')),
        );
      }
    }
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) return;
    
    setState(() => _loading = true);
    try {
      final messages = await _chatService.getMessages(conversationId: _conversationId!);
      if (mounted) {
        setState(() {
          _messages = messages.map((msg) => Message.fromJson(msg)).toList();
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _subscribeToMessages() {
    if (_conversationId == null) return;
    
    _channel = Supabase.instance.client
        .channel('messages_$_conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: _conversationId,
          ),
          callback: (payload) {
            final newMessage = Message.fromJson(payload.newRecord);
            if (mounted) {
              setState(() {
                _messages.add(newMessage);
              });
              _scrollToBottom();
            }
          },
        )
        .subscribe();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _conversationId == null) return;

    try {
      await _chatService.sendMessage(
        conversationId: _conversationId!,
        content: text.trim(),
      );
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showMessageActions(Message msg) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final bool isMe = msg.senderId == (currentUser?.id ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.black87),
                  title: const Text("Edit Message"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _editMessage(msg);
                  },
                ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.undo, color: Colors.red),
                  title: const Text("Delete Message"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _deleteMessage(msg);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editMessage(Message msg) {
    _controller.text = msg.content ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Edit your message"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _chatService.updateMessage(
                  messageId: msg.id,
                  newContent: _controller.text.trim(),
                );
                _controller.clear();
                Navigator.pop(ctx);
                _loadMessages();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update message: $e')),
                );
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMessage(Message msg) async {
    try {
      await _chatService.deleteMessage(msg.id);
      _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFE53935); // KhangMate red shade

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: FutureBuilder(
          future: _loadUserProfile(),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  backgroundImage: profile?.avatarUrl != null
                      ? NetworkImage(profile!.avatarUrl!) as ImageProvider
                      : null,
                  child: profile?.avatarUrl == null
                      ? const Icon(Icons.person, color: primary, size: 22)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.username ?? profile?.fullName ?? profile?.username ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (ctx, i) {
                        final msg = _messages[i];
                        final currentUser = Supabase.instance.client.auth.currentUser;
                        final isMe = msg.senderId == (currentUser?.id ?? '');
                        return GestureDetector(
                    onLongPress: () => _showMessageActions(msg),
                    child: Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? primary : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft:
                                Radius.circular(isMe ? 18 : 4), // Messenger-like
                            bottomRight:
                                Radius.circular(isMe ? 4 : 18), // Messenger-like
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.content ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            if (msg.edited)
                              Text(
                                "Edited",
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white70
                                      : Colors.black45,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input bar
            SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Message...",
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      decoration: const BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => sendMessage(_controller.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
