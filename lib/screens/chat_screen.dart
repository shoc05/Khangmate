import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_bottom_nav.dart';
import '../routes.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../models/message.dart';
import '../models/profile.dart';
import 'chatbot_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _navIndex = 3; // current tab index for Chat
  final _chatService = ChatService();
  final _authService = AuthService();
  List<dynamic> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _loading = true);
    try {
      final conversations = await _chatService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        // Don't show error for empty conversations
      }
    }
  }

  void _onNav(int idx) {
    if (idx == 0) {
      Navigator.pushNamed(context, Routes.home);
      return;
    }
    if (idx == 1) {
      Navigator.pushNamed(context, Routes.map);
      return;
    }
    if (idx == 2) {
      Navigator.pushNamed(context, Routes.favorites);
      return;
    }
    if (idx == 3) return; // already on chat
    if (idx == 4) {
      Navigator.pushNamed(context, Routes.profile);
      return;
    }
    setState(() => _navIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primary = Colors.red;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            AppLogo(size: 34),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Your recent conversations', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline, color: primary),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _conversations.length + 1, // +1 for SmartBot
                itemBuilder: (ctx, i) {
                  // SmartBot at index 0
                  if (i == 0) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: primary.withOpacity(0.12),
                          child: const Icon(Icons.smart_toy, color: primary, size: 28),
                        ),
                        title: Text('SmartBot',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            )),
                        subtitle: Text('Ask me anything...',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                            )),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChatBotScreen()),
                          );
                        },
                      ),
                    );
                  }

                  // User conversations
                  final convIndex = i - 1;
                  if (convIndex >= _conversations.length) return const SizedBox.shrink();
                  
                  final conv = _conversations[convIndex] as Conversation;
                  
                  // Get other user ID (not current user)
                  return FutureBuilder<Profile?>(
                    future: () async {
                      final currentUser = await _authService.getCurrentProfile();
                      final otherUserId = conv.memberIds.firstWhere(
                        (id) => currentUser == null || id != currentUser.id,
                        orElse: () => conv.memberIds.isNotEmpty ? conv.memberIds.first : '',
                      );
                      
                      if (otherUserId.isNotEmpty) {
                        return await _authService.getUserProfile(otherUserId);
                      }
                      return null;
                    }(),
                    builder: (context, snapshot) {
                      final otherUser = snapshot.data;
                      final userName = otherUser?.fullName ?? 
                                      otherUser?.username ?? 
                                      conv.title ?? 
                                      'User';
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: primary.withOpacity(0.12),
                            backgroundImage: otherUser?.avatarUrl != null
                                ? NetworkImage(otherUser!.avatarUrl!) as ImageProvider
                                : null,
                            child: otherUser?.avatarUrl == null
                                ? const Icon(Icons.person, color: primary)
                                : null,
                          ),
                          title: Text(
                            userName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Tap to open conversation',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          onTap: () {
                            final otherUser = snapshot.data;
                            final otherUserId = otherUser?.id ?? 
                                (conv.memberIds.isNotEmpty ? conv.memberIds.first : '');
                            
                            Navigator.pushNamed(
                              context,
                              Routes.chatUser,
                              arguments: {
                                'conversationId': conv.id,
                                'userId': otherUserId,
                                'username': userName,
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _onNav,
      ),
    );
  }
}
