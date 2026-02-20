import 'package:flutter/material.dart';

class PlantingScreen extends StatelessWidget {
  const PlantingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Garden')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            const Text('Watering Schedule & Growth Journal'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Add New Plant"),
            ),
          ],
        ),
      ),
    );
  }
}
