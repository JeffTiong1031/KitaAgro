import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/chat_service.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  bool _showingRequests = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed to white
      appBar: AppBar(
        backgroundColor: Colors.white, // Changed to white
        elevation: 0,
        toolbarHeight: 0, 
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200], // Changed to light grey
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.black87), // Changed to black
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[600]), // Changed to darker grey
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]), // Changed to darker grey
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),

          // Requests / Chats Toggle Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton('Chats', !_showingRequests),
                _buildTabButton('Requests', _showingRequests),
              ],
            ),
          ),

          Expanded(
            child: _showingRequests ? _buildRequestsList() : _buildChatsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showingRequests = text == 'Requests';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent, // Light grey for selected
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.grey[600], // Black for selected, grey for unselected
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return StreamBuilder<List<UserModel>>(
      stream: _userService.streamFriendRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Error loading requests",
              style: TextStyle(color: Colors.black54), // Changed to black54
            ),
          );
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Center(
            child: Text(
              "No friend requests yet",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final user = requests[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: user.profilePicUrl.isNotEmpty
                    ? NetworkImage(user.profilePicUrl)
                    : null,
                backgroundColor: Colors.grey[300], // Lighter grey avatar background
                child: user.profilePicUrl.isEmpty
                    ? Text(
                        user.fullName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.black87), // Black letter
                      )
                    : null,
              ),
              title: Text(
                user.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Changed to black
                ),
              ),
              subtitle: const Text(
                'Sent you a friend request',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () => _userService.acceptFriendRequest(user.uid),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                    onPressed: () => _userService.rejectFriendRequest(user.uid),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatsList() {
    return StreamBuilder<List<UserModel>>(
      stream: _userService.streamFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final friends = snapshot.data ?? [];
        if (friends.isEmpty) {
          return const Center(
            child: Text(
              "Add friends to start chatting!",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            final currentUserId = FirebaseAuth.instance.currentUser!.uid;
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatService.getChatId(currentUserId, friend.uid))
                  .snapshots(),
              builder: (context, chatSnapshot) {
                final data = chatSnapshot.hasData && chatSnapshot.data!.exists
                    ? chatSnapshot.data!.data() as Map<String, dynamic>
                    : {};
                final lastMessage = data['lastMessage'] ?? 'Tap to chat';
                final unreadCountData =
                    data['unreadCount'] as Map<String, dynamic>?;
                final unreadCount = unreadCountData?[currentUserId] ?? 0;
                final isUnread = unreadCount > 0;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: friend.profilePicUrl.isNotEmpty
                        ? NetworkImage(friend.profilePicUrl)
                        : null,
                    backgroundColor: Colors.grey[300], // Lighter avatar background
                    child: friend.profilePicUrl.isEmpty
                        ? Text(
                            friend.fullName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.black87), // Black letter
                          )
                        : null,
                  ),
                  title: Text(
                    friend.fullName,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold,
                      color: Colors.black87, // Changed to black
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    lastMessage,
                    style: TextStyle(
                      color: isUnread ? Colors.black87 : Colors.grey[600], // Adjusted colors
                      fontWeight: isUnread
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isUnread
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(receiverUser: friend),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}