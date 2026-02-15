import 'package:flutter/material.dart';

// Import wrapper screens
import 'features/Home/home_screen.dart';
import 'features/Farmer/farmer_screen.dart';
import 'features/Diagnostic/scan_feature.dart'; // Import the new ScanFeature
import 'features/Message/message_screen.dart';
import 'features/Profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key, this.initialIndex = 2});

  final int initialIndex;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  // The list of pages matching the icons below
  final List<Widget> _screens = [
    const HomeScreen(),        // 0 - Home (Planting + Community)
    const FarmerScreen(),      // 1 - Farmer (Rental + Map)
    const ScanFeature(),       // 2 - Scan
    const MessageScreen(),     // 3 - Message
    const ProfileScreen(),     // 4 - Profile
  ];

  int _sanitizeIndex(int index) {
    if (index < 0 || index >= _screens.length) {
      return 2;
    }
    return index;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _sanitizeIndex(widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _selectedIndex = _sanitizeIndex(widget.initialIndex);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: Colors.green.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.agriculture_outlined),
            selectedIcon: Icon(Icons.agriculture),
            label: 'Farmer',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.mail_outlined),
            selectedIcon: Icon(Icons.mail),
            label: 'Message',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}