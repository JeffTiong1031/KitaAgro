import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String _selectedCategory = 'All';
  final ScrollController _gridController = ScrollController();

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Herbs',
  ];

  final List<Map<String, dynamic>> _plants = [
    // Vegetables
    {
      'name': 'Tomato',
      'scientificName': 'Solanum lycopersicum',
      'category': 'Vegetables',
      'icon': Icons.circle,
      'color': Color(0xFFE53935),
      'description': 'A popular garden vegetable rich in vitamins A and C. Tomatoes are used in salads, sauces, and many cuisines worldwide.',
      'growthTime': '60-80 days',
      'difficulty': 'Easy',
      'sunlight': 'Full sun (6-8 hours)',
      'water': 'Regular watering',
      'soil': 'Well-drained, fertile soil',
    },
    {
      'name': 'Chili',
      'scientificName': 'Capsicum annuum',
      'category': 'Vegetables',
      'icon': Icons.local_fire_department,
      'color': Color(0xFFD32F2F),
      'description': 'Spicy fruit used in many cuisines worldwide. Contains capsaicin which gives the heat.',
      'growthTime': '60-90 days',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'Moderate',
      'soil': 'Sandy loam',
    },
    // Fruits
    {
      'name': 'Papaya',
      'scientificName': 'Carica papaya',
      'category': 'Fruits',
      'icon': Icons.spa,
      'color': Color(0xFFFFB300),
      'description': 'Tropical fruit with sweet orange flesh. Rich in enzymes and vitamins.',
      'growthTime': '9-11 months',
      'difficulty': 'Medium',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Well-drained, rich',
    },
    {
      'name': 'Banana',
      'scientificName': 'Musa acuminata',
      'category': 'Fruits',
      'icon': Icons.nature,
      'color': Color(0xFFFFEB3B),
      'description': 'Popular tropical fruit rich in potassium. Grows in bunches on tall plants.',
      'growthTime': '9-12 months',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'High',
      'soil': 'Rich, well-drained',
    },
    // Herbs
    {
      'name': 'Pandan',
      'scientificName': 'Pandanus amaryllifolius',
      'category': 'Herbs',
      'icon': Icons.grass,
      'color': Color(0xFF388E3C),
      'description': 'Fragrant leaves used in Southeast Asian desserts and rice dishes.',
      'growthTime': '6-12 months',
      'difficulty': 'Easy',
      'sunlight': 'Partial shade',
      'water': 'High',
      'soil': 'Moist, rich',
    },
  ];

  List<Map<String, dynamic>> get _filteredPlants {
    if (_selectedCategory == 'All') {
      return _plants;
    }
    return _plants.where((plant) => plant['category'] == _selectedCategory).toList();
  }

  @override
  void dispose() {
    _gridController.dispose();
    super.dispose();
  }

  Future<void> _addPlantToGarden(Map<String, dynamic> plant) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add plants.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final int totalDays = _parseGrowthDays(plant['growthTime'] as String?);
    final IconData icon = plant['icon'] as IconData;
    final Color color = plant['color'] as Color;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('plantations')
        .add({
          'name': plant['name'],
          'scientificName': plant['scientificName'],
          'category': plant['category'],
          'totalDays': totalDays,
          'daysPlanted': 0,
          'plantedAt': Timestamp.now(),
          'icon': _iconName(icon),
          'color': color.value,
        });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plant['name']} added to your garden!'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _parseGrowthDays(String? growthTime) {
    if (growthTime == null || growthTime.trim().isEmpty) {
      return 60;
    }
    final String lower = growthTime.toLowerCase();
    final match = RegExp(r'(\d+)').firstMatch(lower);
    if (match == null) {
      return 60;
    }
    final int value = int.tryParse(match.group(1) ?? '') ?? 60;
    if (lower.contains('month')) {
      return value * 30;
    }
    return value;
  }

  String _iconName(IconData icon) {
    if (icon == Icons.circle) {
      return 'circle';
    }
    if (icon == Icons.local_fire_department) {
      return 'local_fire_department';
    }
    if (icon == Icons.spa) {
      return 'spa';
    }
    if (icon == Icons.nature) {
      return 'nature';
    }
    if (icon == Icons.grass) {
      return 'grass';
    }
    return 'spa';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B5E20),
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Plant Dictionary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category tabs
          Container(
            color: Color(0xFF2E7D32),
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Color(0xFF2E7D32) : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Plant count
          Container(
            color: Color(0xFF1B5E20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.eco, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_filteredPlants.length} Plants',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Grid of plants
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: GridView.builder(
                key: const PageStorageKey<String>('dictionary_grid'),
                controller: _gridController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _filteredPlants.length,
                itemBuilder: (context, index) {
                  final plant = _filteredPlants[index];
                  return _buildPlantBlock(plant);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantBlock(Map<String, dynamic> plant) {
    return GestureDetector(
      onTap: () => _showPlantDetails(plant),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF388E3C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF4CAF50),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Plant icon in circle
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: plant['color'] as Color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: (plant['color'] as Color).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                plant['icon'] as IconData,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            // Plant name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                plant['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlantDetails(Map<String, dynamic> plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and name
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: plant['color'] as Color,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: (plant['color'] as Color).withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                plant['icon'] as IconData,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: GestureDetector(
                                onTap: () => _addPlantToGarden(plant),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1B5E20),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plant['name'],
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                plant['scientificName'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  plant['category'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plant['description'],
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Growing info cards
                    Text(
                      'Growing Guide',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(Icons.schedule, 'Growth Time', plant['growthTime']),
                    _buildInfoCard(Icons.trending_up, 'Difficulty', plant['difficulty']),
                    _buildInfoCard(Icons.wb_sunny, 'Sunlight', plant['sunlight']),
                    _buildInfoCard(Icons.water_drop, 'Water', plant['water']),
                    _buildInfoCard(Icons.landscape, 'Soil', plant['soil']),

                    const SizedBox(height: 24),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _addPlantToGarden(plant);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add to My Garden'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
