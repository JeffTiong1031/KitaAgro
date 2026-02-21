import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:kita_agro/features/Home/Planting/planting_screen.dart';
import 'package:kita_agro/features/Home/community/community_screen.dart';
import 'package:kita_agro/features/community/create_post_screen.dart';
import 'package:kita_agro/features/Home/Dictionary/dictionary_screen.dart';
import 'package:kita_agro/features/community/community_service.dart';
import 'package:kita_agro/features/Profile/single_post_screen.dart';
import 'package:kita_agro/services/notification_service.dart';
import 'search_users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  final CommunityService _communityService = CommunityService();
  final NotificationService _notificationService = NotificationService();

  Future<void> _pickImageAndNavigate(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePostScreen(imageFile: pickedFile),
        ),
      );
    }
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  _notificationService.markAllAsRead();
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: StreamBuilder<List<NotificationModel>>(
              stream: _notificationService.getNotificationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notifications = snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return const Center(child: Text("No notifications yet"));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: notif.isRead
                            ? Colors.grey[200]
                            : Colors.blue[50],
                        child: Icon(
                          notif.type == 'like'
                              ? Icons.favorite
                              : notif.type == 'friend_request'
                              ? Icons.person_add
                              : Icons.notifications,
                          color: notif.isRead ? Colors.grey : Colors.blue,
                        ),
                      ),
                      title: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: notif.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notif.body),
                      onTap: () {
                        if (!notif.isRead) {
                          _notificationService.markAsRead(notif.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: null,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchUsersScreen(),
                          ),
                        );
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search people, crops, pests...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showNotificationsDialog(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: StreamBuilder<int>(
                      stream: _notificationService.getUnseenCountStream(),
                      builder: (context, snapshot) {
                        int unseenCount = snapshot.data ?? 0;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications,
                              color: Colors.grey[700],
                              size: 24,
                            ),
                            if (unseenCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unseenCount > 9
                                        ? '9+'
                                        : unseenCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Dashboard Section
          SliverToBoxAdapter(child: _buildDashboard()),
          // Action Buttons Section
          SliverToBoxAdapter(child: _buildActionButtons()),
          // Tab Navigation
          SliverToBoxAdapter(child: _buildTabNavigation()),
          // Community Posts from Firebase
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: _communityService.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading posts: ${snapshot.error}"),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Text("No posts yet. Be the first to share!"),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final postDoc = snapshot.data!.docs[index];
                    return _buildRealCommunityPost(postDoc);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Growth Stage Card with Weather and Reminder
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Growth Stage Circle
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer circle
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 8,
                                ),
                              ),
                            ),
                            // Progress circle
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: 0.75,
                                strokeWidth: 8,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.teal[400]!,
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            // Center circle with plant icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: const Icon(
                                Icons.eco,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '75%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[400],
                        ),
                      ),
                      Text(
                        'Growth Stage',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Weather and Reminder
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Weather Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Icon(
                                  Icons.wb_sunny,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '24°C',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Sunny',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Reminder Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Reminder',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Icon(
                                  Icons.water_drop,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Watering',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            label: 'My Journey',
            color: Colors.teal[100]!,
            icon: Icons.favorite,
            iconColor: Colors.teal,
          ),
          _buildActionButton(
            label: 'Dictionary',
            color: Colors.orange[100]!,
            icon: Icons.description,
            iconColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DictionaryScreen(),
                ),
              );
            },
          ),
          _buildActionButton(
            label: 'AI Assistant',
            color: Colors.purple[100]!,
            icon: Icons.smart_toy,
            iconColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    final tabs = ['Community', 'Recommend', 'Market', 'Q&A'];
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _selectedTabIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedTabIndex == index
                                ? Colors.teal
                                : Colors.grey,
                          ),
                        ),
                        if (index == 0) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _pickImageAndNavigate(context),
                            child: Icon(
                              Icons.add_circle,
                              size: 18,
                              color: _selectedTabIndex == index
                                  ? Colors.teal
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_selectedTabIndex == index)
                    Container(height: 3, color: Colors.teal),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRealCommunityPost(DocumentSnapshot postDoc) {
    final data = postDoc.data() as Map<String, dynamic>;
    final publisherId = data['publisherId'] as String?;
    final username = data['publisherName'] ?? 'Unknown User';
    final userProfilePic = data['publisherProfilePic'] ?? '?';
    final caption = data['caption'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';
    final likesCount = data['likesCount'] ?? 0;
    final commentsCount = data['commentsCount'] ?? 0;
    final likedBy = data['likedBy'] as List<dynamic>? ?? [];

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isMyPost = publisherId == currentUserId;
    final isLiked = currentUserId != null && likedBy.contains(currentUserId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SinglePostScreen(postDoc: postDoc),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal[300],
                        radius: 20,
                        child: Text(
                          userProfilePic.isNotEmpty
                              ? userProfilePic[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Community Member',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isMyPost)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          // Confirm deletion
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Post'),
                              content: const Text(
                                'Are you sure you want to delete this post?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    _communityService.deletePost(
                                      postDoc.id,
                                    ); // Delete the post
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete Post',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    )
                  else
                    Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                ],
              ),
              const SizedBox(height: 12),

              // Post Caption
              if (caption.isNotEmpty) ...[
                Text(caption, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
              ],

              // Post Image (if available)
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline),
                    ),
                  ),
                ),

              if (imageUrl.isNotEmpty) const SizedBox(height: 12),

              // Engagement Metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildEngagementButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    iconColor: isLiked ? Colors.red : null,
                    count: likesCount,
                    onTap: () {
                      if (currentUserId != null) {
                        _communityService.toggleLike(
                          postDoc.id,
                          currentUserId,
                          likedBy,
                        );
                      }
                    },
                  ),
                  _buildEngagementButton(
                    icon: Icons.comment_outlined,
                    count: commentsCount,
                    onTap: () {
                      // Since both should link to single view, we navigate here as well
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SinglePostScreen(postDoc: postDoc),
                        ),
                      );
                    },
                  ),
                  _buildEngagementButton(icon: Icons.share_outlined, count: 0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEngagementButton({
    required IconData icon,
    required int count,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
