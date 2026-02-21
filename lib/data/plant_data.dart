import 'package:flutter/material.dart';

class PlantData {
  static const List<Map<String, dynamic>> allPlants = [
    {
      'name': 'Chili',
      'icon': Icons.local_fire_department,
      'color': Colors.redAccent,
    },
    {'name': 'Tomato', 'icon': Icons.local_florist, 'color': Colors.deepOrange},
    {'name': 'Corn', 'icon': Icons.grass, 'color': Colors.amber},
    {'name': 'Cabbage', 'icon': Icons.spa, 'color': Colors.green},
    {'name': 'Rice', 'icon': Icons.eco, 'color': Colors.lightGreen},
    {'name': 'Potato', 'icon': Icons.agriculture, 'color': Colors.brown},
  ];
}
