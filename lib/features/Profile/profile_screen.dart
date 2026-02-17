import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../features/auth/auth_service.dart';
import '../auth/welcome_screen.dart'; // Add import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
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

  Future<void> _showEditProfileDialog() async {
    if (_user == null) return;

    final TextEditingController nameController = TextEditingController(text: _user!.fullName);
    final TextEditingController ageController = TextEditingController(text: _user!.age.toString());
    final TextEditingController townController = TextEditingController(text: _user!.town);
    final TextEditingController stateController = TextEditingController(text: _user!.state);
    final TextEditingController countryController = TextEditingController(text: _user!.country);
    String selectedRole = _user!.role.isNotEmpty && ["Farmer", "Home Grower", "Agronomist", "Business Company"].contains(_user!.role) 
        ? _user!.role 
        : "Farmer";

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Profile"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                    ),
                    TextField(
                      controller: ageController,
                      decoration: const InputDecoration(labelText: "Age"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: townController,
                      decoration: const InputDecoration(labelText: "Town"),
                    ),
                    TextField(
                      controller: stateController,
                      decoration: const InputDecoration(labelText: "State"),
                    ),
                    TextField(
                      controller: TextEditingController(text: _user!.town),
                      onChanged: (val) {
                         // We need a controller for town to capture this
                      },
                      decoration: const InputDecoration(labelText: "Town"),
                    ),
                    TextField(
                      controller: countryController,
                      decoration: const InputDecoration(labelText: "Country"),
                    ),
                    DropdownButton<String>(
                      value: selectedRole,
                      isExpanded: true,
                      onChanged: (val) {
                        setDialogState(() {
                          selectedRole = val!;
                        });
                      },
                      items: ["Farmer", "Home Grower", "Agronomist", "Business Company"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Update user model
                    UserModel updatedUser = UserModel(
                      uid: _user!.uid,
                      email: _user!.email,
                      username: _user!.username,
                      fullName: nameController.text.trim(),
                      age: int.tryParse(ageController.text.trim()) ?? _user!.age,
                      gender: _user!.gender, // Not editing gender for now
                      town: townController.text.trim(),
                      state: stateController.text.trim(),
                      country: countryController.text.trim(),
                      role: selectedRole,
                      createdAt: _user!.createdAt,
                    );

                    await _authService.updateUserProfile(updatedUser);
                    
                    if (mounted) {
                      Navigator.pop(context);
                      _fetchUserData(); // Refresh data
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          }
        );
      },
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
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    _user!.fullName.isNotEmpty ? _user!.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 40, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _user!.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  _user!.email,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  _user!.role, // Role
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Profile Details Card
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  _buildProfileRow("Username", _user!.username),
                  const Divider(),
                  _buildProfileRow("Age", "${_user!.age}"),
                  const Divider(),
                  _buildProfileRow("Gender", _user!.gender),
                  const Divider(),
                  _buildProfileRow("Location", "${_user!.town}, ${_user!.state}, ${_user!.country}"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Profile Options
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: _showEditProfileDialog,
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {}, // Implement nice-to-have later
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
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
                        child: const Text("Logout", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
