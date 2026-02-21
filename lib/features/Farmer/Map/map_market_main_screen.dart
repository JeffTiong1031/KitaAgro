import 'package:flutter/material.dart';

import 'map_screen.dart';
import 'marketplace_screen.dart';
import 'my_product_screen.dart';

class MapMarketMainScreen extends StatefulWidget {
  const MapMarketMainScreen({super.key});

  @override
  State<MapMarketMainScreen> createState() => _MapMarketMainScreenState();
}

class _MapMarketMainScreenState extends State<MapMarketMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = const <Widget>[
    MapScreen(),
    MarketplaceScreen(),
    MyProductScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
    BottomNavigationBarItem(
      icon: Icon(Icons.storefront_outlined),
      label: 'Marketplace',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.inventory_2_outlined),
      label: 'My Product',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
