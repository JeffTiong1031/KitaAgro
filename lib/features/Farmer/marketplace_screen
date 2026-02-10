import 'package:flutter/material.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          final items = [
            {'name': 'Vegetables', 'icon': Icons.local_florist, 'color': Colors.green},
            {'name': 'Fruits', 'icon': Icons.emoji_nature, 'color': Colors.orange},
            {'name': 'Herbs', 'icon': Icons.spa, 'color': Colors.teal},
            {'name': 'Grains', 'icon': Icons.grain, 'color': Colors.amber},
            {'name': 'Livestock', 'icon': Icons.pets, 'color': Colors.brown},
            {'name': 'Dairy', 'icon': Icons.local_shipping, 'color': Colors.blue},
          ];
          
          final item = items[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item['name']} products coming soon!')),
              );
            },
            child: Card(
              elevation: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 48,
                    color: item['color'] as Color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
