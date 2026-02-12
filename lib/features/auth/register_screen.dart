import 'package:flutter/material.dart';
import '../../main_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form Data
  final TextEditingController _nameController = TextEditingController();
  String? _selectedRole;
  String? _selectedLocation;
  String? _experienceLevel;

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishRegistration();
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _finishRegistration() {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate registration
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close dialog
      // Go to main dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _previousPage,
        ),
        title: LinearProgressIndicator(
          value: (_currentStep + 1) / _totalSteps,
          backgroundColor: Colors.grey[200],
          color: Colors.green,
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentStep = index;
          });
        },
        children: [
          _buildQuestionPage(
            title: "What is your full name?",
            input: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter your name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          _buildQuestionPage(
            title: "What is your role?",
            input: _buildDropdown(
              items: ["Farmer", "Student", "Agropreneur", "Investor", "Researcher"],
              value: _selectedRole,
              onChanged: (val) => setState(() => _selectedRole = val),
              hint: "Select your role",
            ),
          ),
          _buildQuestionPage(
            title: "Where are you located?",
            input: _buildDropdown(
              items: ["Selangor", "Johor", "Kedah", "Perak", "Sabah", "Sarawak", "Other"],
              value: _selectedLocation,
              onChanged: (val) => setState(() => _selectedLocation = val),
              hint: "Select state",
            ),
          ),
          _buildQuestionPage(
            title: "How much experience do you have in agriculture?",
            input: _buildDropdown(
              items: ["Beginner (0-1 years)", "Intermediate (2-5 years)", "Expert (5+ years)"],
              value: _experienceLevel,
              onChanged: (val) => setState(() => _experienceLevel = val),
              hint: "Select experience level",
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(
              _currentStep == _totalSteps - 1 ? "Finish" : "Next",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionPage({required String title, required Widget input}) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 30),
          input,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
