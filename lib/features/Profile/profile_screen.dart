import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_model.dart';
import '../../features/auth/auth_service.dart';
import '../../features/community/community_service.dart';
import '../auth/login_screen.dart';
import '../auth/welcome_screen.dart'; // Add import
import 'edit_profile_screen.dart';
import 'single_post_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final CommunityService _communityService = CommunityService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      UserModel? user = await _authService.getUserData(currentUser.uid);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (_user == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _user!),
      ),
    );

    // If profile was updated, refresh data
    if (result == true) {
      _fetchUserData();
    }
  }

  Future<void> _showChangePasswordDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: const TextField(
          obscureText: true,
          decoration: InputDecoration(labelText: "New Password"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password change feature coming soon!")));
            },
            child: const Text("Save"),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              _user!.username,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: _showChangePasswordDialog,
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          // Header: Avatar + Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green.shade100,
                  backgroundImage: _user!.profilePicUrl.isNotEmpty 
                      ? NetworkImage(_user!.profilePicUrl) 
                      : null,
                  child: _user!.profilePicUrl.isEmpty 
                      ? Text(
                          _user!.fullName.isNotEmpty ? _user!.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn("0", "posts"), // We can update posts dynamically if needed, but keeping simple for now
                      _buildStatColumn("0", "followers"),
                      _buildStatColumn("0", "following"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bio details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user!.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_user!.role} | ${_user!.town} | ${_user!.country}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (_user!.bio.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _user!.bio,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _navigateToEditProfile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View archive', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 0.5),
          
          // My Posts Grid
          StreamBuilder<QuerySnapshot>(
            stream: _communityService.getPostsStream(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                 return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                 return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No posts yet.")));
              }
              
              // Filter posts by user id 
              final myPosts = snapshot.data!.docs.where((doc) {
                 final data = doc.data() as Map<String, dynamic>;
                 return data['publisherId'] == _user!.uid; 
              }).toList();

              if (myPosts.isEmpty) {
                 return const Center(child: Padding(padding: EdgeInsets.all(40), child: Flexible(child: Text("Share photos to see them on your profile.", textAlign: TextAlign.center,))));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: myPosts.length,
                itemBuilder: (context, index) {
                  final post = myPosts[index].data() as Map<String, dynamic>;
                  final imageUrl = post['imageUrl'] as String? ?? "";
                  
                  if (imageUrl.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SinglePostScreen(postDoc: myPosts[index]),
                          ),
                        );
                      },
                      child: Image.network(
                        imageUrl, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error_outline),
                        ),
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SinglePostScreen(postDoc: myPosts[index]),
                          ),
                        );
                      },
                      child: Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.text_snippet, color: Colors.grey)),
                      ),
                    );
                  }
                },
              );
            }
          ),

          const SizedBox(height: 40),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: () {
                // Show confirmation dialog before logout
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                             Navigator.pop(context); // Close dialog
                             await _authService.signOut();
                            
                             if (mounted) {
                               // Navigate to Welcome screen
                               Navigator.pushAndRemoveUntil(
                                 context,
                                 MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                                 (route) => false,
                               );
                             }
                          },
                          child: const Text("Log Out", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }
}
