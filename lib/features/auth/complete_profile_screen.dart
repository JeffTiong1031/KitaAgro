import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../features/auth/auth_service.dart';
import '../../main_layout.dart';
// Note: You need a form to collect Age, Town, etc.

class CompleteProfileScreen extends StatefulWidget {
  final UserModel user;
  const CompleteProfileScreen({super.key, required this.user});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _townController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  
  String _selectedGender = 'Male';
  String _selectedRole = 'Farmer';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if any
    if (widget.user.age > 0) _ageController.text = widget.user.age.toString();
    if (widget.user.town != 'Not Specified') _townController.text = widget.user.town;
    if (widget.user.state != 'Not Specified') _stateController.text = widget.user.state;
    if (widget.user.country != 'Not Specified') _countryController.text = widget.user.country;
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserModel updatedUser = UserModel(
          uid: widget.user.uid,
          email: widget.user.email,
          username: widget.user.username,
          fullName: widget.user.fullName,
          age: int.tryParse(_ageController.text) ?? 0,
          gender: _selectedGender,
          town: _townController.text.trim(),
          state: _stateController.text.trim(),
          country: _countryController.text.trim(),
          role: _selectedRole,
          createdAt: widget.user.createdAt,
        );

        await AuthService().updateUserProfile(updatedUser);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating profile: $e")),
          );
        }
      } finally {
        if (mounted) setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Please complete your profile to continue."),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your age';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                items: ['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() { _selectedGender = newValue!; });
                },
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _townController,
                decoration: const InputDecoration(labelText: "Town"),
                validator: (value) {
                   if (value == null || value.isEmpty) return 'Please enter your town';
                   return null;
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: "State"),
                validator: (value) {
                   if (value == null || value.isEmpty) return 'Please enter your state';
                   return null;
                },
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: "Country"),
                validator: (value) {
                   if (value == null || value.isEmpty) return 'Please enter your country';
                   return null;
                },
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                items: ['Farmer', 'Buyer', 'Investor', 'Researcher'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                   setState(() { _selectedRole = newValue!; });
                },
                decoration: const InputDecoration(labelText: "Role"),
              ),
              const SizedBox(height: 20),

              _isLoading 
               ? const CircularProgressIndicator()
               : ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text("Save & Continue"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
