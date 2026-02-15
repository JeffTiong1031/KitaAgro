import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyJourneyScreen extends StatefulWidget {
  const MyJourneyScreen({super.key});

  @override
  State<MyJourneyScreen> createState() => _MyJourneyScreenState();
}

class _MyJourneyScreenState extends State<MyJourneyScreen> {
  String _sortBy = 'name'; // 'name', 'daysPlanted', 'health'

  Stream<List<Map<String, dynamic>>> _gardenPlantStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('plantations')
        .snapshots()
        .map((snapshot) {
          final plants = snapshot.docs.map((doc) => _mapGardenPlant(doc)).toList();
          // Sort based on selected criteria
          switch (_sortBy) {
            case 'daysPlanted':
              plants.sort((a, b) => (b['daysPlanted'] as int).compareTo(a['daysPlanted'] as int));
              break;
            case 'health':
              plants.sort((a, b) {
                final aHealth = _calculateHealth(a);
                final bHealth = _calculateHealth(b);
                return bHealth.compareTo(aHealth);
              });
              break;
            case 'name':
            default:
              plants.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
          }
          return plants;
        });
  }

  Map<String, dynamic> _mapGardenPlant(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = (data['name'] as String?) ?? 'Unnamed Plant';
    final scientificName = (data['scientificName'] as String?) ?? '';
    final category = (data['category'] as String?) ?? 'Unknown';
    final totalDays = (data['totalDays'] as int?) ?? 60;
    final daysPlanted = (data['daysPlanted'] as int?) ?? 0;
    final plantedAt = data['plantedAt'] as Timestamp?;
    final iconName = (data['icon'] as String?) ?? 'spa';
    final colorValue = (data['color'] as int?) ?? 0xFF4CAF50;

    int actualDaysPlanted = daysPlanted;
    if (plantedAt != null) {
      actualDaysPlanted = DateTime.now().difference(plantedAt.toDate()).inDays;
    }

    return {
      'id': doc.id,
      'name': name,
      'scientificName': scientificName,
      'category': category,
      'totalDays': totalDays,
      'daysPlanted': actualDaysPlanted,
      'plantedAt': plantedAt,
      'icon': _iconFromName(iconName),
      'color': _parseColor(colorValue),
    };
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'circle':
        return Icons.circle;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'spa':
        return Icons.spa;
      case 'nature':
        return Icons.nature;
      case 'grass':
        return Icons.grass;
      default:
        return Icons.spa;
    }
  }

  Color _parseColor(dynamic value) {
    if (value is int) {
      return Color(value);
    }
    if (value is String && value.startsWith('0x')) {
      return Color(int.parse(value));
    }
    if (value is String && value.startsWith('#')) {
      return Color(int.parse(value.replaceFirst('#', '0xff')));
    }
    return const Color(0xFF4CAF50);
  }

  int _calculateHealth(Map<String, dynamic> plant) {
    final int daysPlanted = plant['daysPlanted'] as int;
    final int totalDays = plant['totalDays'] as int;

    if (totalDays == 0) return 50;
    final progress = (daysPlanted / totalDays * 100).clamp(0, 100).toInt();
    return progress;
  }

  String _getHealthStatus(int health) {
    if (health == 0) return '🌱 Just Planted';
    if (health < 30) return '🌿 Growing';
    if (health < 70) return '🌾 Thriving';
    if (health < 100) return '📦 Nearly Ready';
    return '✅ Harvest Ready';
  }

  Color _getHealthColor(int health) {
    if (health == 0) return Colors.blue;
    if (health < 30) return Colors.green[300]!;
    if (health < 70) return Colors.green;
    if (health < 100) return Colors.amber;
    return Colors.orange;
  }

  Future<void> _deletePlant(String plantId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('plantations')
          .doc(plantId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plant removed from your garden'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting plant: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text(
          'Are you sure you want to remove "${plant['name']}" from your garden?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlant(plant['id'] as String);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Journey',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Sort options
          Container(
            color: Color(0xFF2E7D32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortButton('Name', 'name'),
                  const SizedBox(width: 8),
                  _buildSortButton('Days Planted', 'daysPlanted'),
                  const SizedBox(width: 8),
                  _buildSortButton('Health', 'health'),
                ],
              ),
            ),
          ),
          // Plant list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _gardenPlantStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        const Text('Error loading your garden'),
                      ],
                    ),
                  );
                }

                final plants = snapshot.data ?? [];
                if (plants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grass, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Your garden is empty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add plants from the Dictionary to get started!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    final health = _calculateHealth(plant);
                    return _buildPlantListItem(plant, health);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Color(0xFF2E7D32) : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPlantListItem(Map<String, dynamic> plant, int health) {
    final healthStatus = _getHealthStatus(health);
    final healthColor = _getHealthColor(health);
    final daysRemaining = (plant['totalDays'] as int) - (plant['daysPlanted'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: (plant['color'] as Color).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: plant['color'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        plant['icon'] as IconData,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plant['scientificName'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              plant['category'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Health status and progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      healthStatus,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: healthColor,
                      ),
                    ),
                    Text(
                      '${plant['daysPlanted']} / ${plant['totalDays']} days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: health / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                  ),
                ),

                const SizedBox(height: 12),

                // Days remaining info
                if (daysRemaining > 0)
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        daysRemaining > 1
                            ? '$daysRemaining days until harvest'
                            : '$daysRemaining day until harvest',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        'Ready to harvest!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Delete button - top right corner
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _showDeleteConfirmation(plant),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red[600],
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
