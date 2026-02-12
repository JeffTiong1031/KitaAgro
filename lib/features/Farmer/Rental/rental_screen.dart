import 'package:flutter/material.dart';

class RentalScreen extends StatelessWidget {
  const RentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Rental')),
      body: ListView(
        children: [
          _buildRentalItem("Tractor Model X", "RM 50/day"),
          _buildRentalItem("Drone Sprayer", "RM 100/day"),
          _buildRentalItem("Harvester", "RM 200/day"),
        ],
      ),
    );
  }

  Widget _buildRentalItem(String title, String price) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.handyman, color: Colors.brown),
        title: Text(title),
        subtitle: Text(price),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text("Rent"),
        ),
      ),
    );
  }
}