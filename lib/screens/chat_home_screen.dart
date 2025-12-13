import 'package:flutter/material.dart';
import 'chatbot_screen.dart';
import '../routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/chat_service.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _chatService = ChatService();
  List<Map<String, dynamic>> _recentChats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecentChats();
  }

  Future<void> _loadRecentChats() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch recent conversations
      final chats = await _chatService.getRecentChats(userId: currentUser.id);
      setState(() {
        _recentChats = chats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recent chats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chats'),
            Tab(icon: Icon(Icons.smart_toy_outlined), text: 'Smart Bot'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Recent Chats Tab
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recentChats.isEmpty
                  ? const Center(child: Text('No recent chats'))
                  : ListView.builder(
                      itemCount: _recentChats.length,
                      itemBuilder: (context, index) {
                        final chat = _recentChats[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: chat['avatar_url'] != null
                                ? NetworkImage(chat['avatar_url'])
                                : null,
                            child: chat['avatar_url'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(chat['username'] ?? 'Unknown User'),
                          subtitle: Text(
                            chat['last_message'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.userChat,
                              arguments: {
                                'userId': chat['user_id'],
                                'username': chat['username'],
                              },
                            );
                          },
                        );
                      },
                    ),
          
          // Smart Bot Tab
          ChatBotScreen(key: UniqueKey()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new chat functionality
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}