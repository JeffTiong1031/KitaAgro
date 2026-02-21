import 'package:flutter/material.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Herbs',
    'Grains',
    'Flowers',
  ];

  final List<Map<String, dynamic>> _plants = [
    // Vegetables
    {
      'name': 'Tomato',
      'scientificName': 'Solanum lycopersicum',
      'category': 'Vegetables',
      'icon': Icons.circle,
      'color': Color(0xFFE53935),
      'description':
          'A popular garden vegetable rich in vitamins A and C. Tomatoes are used in salads, sauces, and many cuisines worldwide.',
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
      'description':
          'Spicy fruit used in many cuisines worldwide. Contains capsaicin which gives the heat.',
      'growthTime': '60-90 days',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'Moderate',
      'soil': 'Sandy loam',
    },
    {
      'name': 'Kangkung',
      'scientificName': 'Ipomoea aquatica',
      'category': 'Vegetables',
      'icon': Icons.grass,
      'color': Color(0xFF43A047),
      'description':
          'Water spinach, a popular leafy vegetable in Southeast Asia. Fast-growing and nutritious.',
      'growthTime': '30-45 days',
      'difficulty': 'Easy',
      'sunlight': 'Partial to full sun',
      'water': 'High - loves wet soil',
      'soil': 'Moist, rich soil',
    },
    {
      'name': 'Cucumber',
      'scientificName': 'Cucumis sativus',
      'category': 'Vegetables',
      'icon': Icons.spa,
      'color': Color(0xFF66BB6A),
      'description':
          'Refreshing vegetable with high water content. Great for salads and pickles.',
      'growthTime': '50-70 days',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'Regular, consistent',
      'soil': 'Rich, well-drained',
    },
    {
      'name': 'Eggplant',
      'scientificName': 'Solanum melongena',
      'category': 'Vegetables',
      'icon': Icons.egg,
      'color': Color(0xFF7B1FA2),
      'description':
          'Also known as aubergine. Versatile vegetable used in many Asian and Mediterranean dishes.',
      'growthTime': '70-85 days',
      'difficulty': 'Medium',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Sandy loam, well-drained',
    },
    {
      'name': 'Carrot',
      'scientificName': 'Daucus carota',
      'category': 'Vegetables',
      'icon': Icons.eco,
      'color': Color(0xFFFF7043),
      'description':
          'Root vegetable rich in beta-carotene. Sweet and crunchy, great raw or cooked.',
      'growthTime': '70-80 days',
      'difficulty': 'Medium',
      'sunlight': 'Full sun to partial shade',
      'water': 'Consistent moisture',
      'soil': 'Loose, sandy soil',
    },
    {
      'name': 'Cabbage',
      'scientificName': 'Brassica oleracea',
      'category': 'Vegetables',
      'icon': Icons.circle,
      'color': Color(0xFF81C784),
      'description':
          'Leafy green vegetable forming a compact head. Used in salads, stir-fries, and fermented foods.',
      'growthTime': '70-100 days',
      'difficulty': 'Medium',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Rich, well-drained',
    },
    {
      'name': 'Spinach',
      'scientificName': 'Spinacia oleracea',
      'category': 'Vegetables',
      'icon': Icons.local_florist,
      'color': Color(0xFF2E7D32),
      'description':
          'Nutrient-dense leafy green packed with iron and vitamins. Quick to grow.',
      'growthTime': '40-50 days',
      'difficulty': 'Easy',
      'sunlight': 'Partial shade to full sun',
      'water': 'Consistent moisture',
      'soil': 'Rich, well-drained',
    },
    {
      'name': 'Onion',
      'scientificName': 'Allium cepa',
      'category': 'Vegetables',
      'icon': Icons.circle,
      'color': Color(0xFFFFB74D),
      'description':
          'Essential bulb vegetable used as base flavor in countless dishes worldwide.',
      'growthTime': '90-120 days',
      'difficulty': 'Medium',
      'sunlight': 'Full sun',
      'water': 'Moderate',
      'soil': 'Well-drained, fertile',
    },
    {
      'name': 'Potato',
      'scientificName': 'Solanum tuberosum',
      'category': 'Vegetables',
      'icon': Icons.circle,
      'color': Color(0xFF8D6E63),
      'description':
          'Starchy tuber and staple food. Extremely versatile in cooking methods.',
      'growthTime': '70-120 days',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Loose, well-drained',
    },

    // Fruits
    {
      'name': 'Papaya',
      'scientificName': 'Carica papaya',
      'category': 'Fruits',
      'icon': Icons.spa,
      'color': Color(0xFFFFB300),
      'description':
          'Tropical fruit with sweet orange flesh. Rich in enzymes and vitamins.',
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
      'description':
          'Popular tropical fruit rich in potassium. Grows in bunches on tall plants.',
      'growthTime': '9-12 months',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'High',
      'soil': 'Rich, well-drained',
    },
    {
      'name': 'Mango',
      'scientificName': 'Mangifera indica',
      'category': 'Fruits',
      'icon': Icons.nature,
      'color': Color(0xFFFF8F00),
      'description':
          'King of fruits with sweet, juicy flesh. Popular in tropical regions.',
      'growthTime': '3-6 years to fruit',
      'difficulty': 'Hard',
      'sunlight': 'Full sun',
      'water': 'Moderate',
      'soil': 'Deep, well-drained',
    },
    {
      'name': 'Watermelon',
      'scientificName': 'Citrullus lanatus',
      'category': 'Fruits',
      'icon': Icons.circle,
      'color': Color(0xFF4CAF50),
      'description':
          'Large fruit with sweet red flesh and high water content. Perfect for hot days.',
      'growthTime': '70-90 days',
      'difficulty': 'Medium',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Sandy, well-drained',
    },
    {
      'name': 'Pineapple',
      'scientificName': 'Ananas comosus',
      'category': 'Fruits',
      'icon': Icons.spa,
      'color': Color(0xFFFFC107),
      'description':
          'Tropical fruit with spiky exterior and sweet-tart flesh. Takes long to mature.',
      'growthTime': '18-24 months',
      'difficulty': 'Medium',
      'sunlight': 'Full sun',
      'water': 'Moderate',
      'soil': 'Sandy, acidic',
    },
    {
      'name': 'Strawberry',
      'scientificName': 'Fragaria × ananassa',
      'category': 'Fruits',
      'icon': Icons.favorite,
      'color': Color(0xFFE91E63),
      'description':
          'Sweet red berries loved worldwide. Compact plants suitable for containers.',
      'growthTime': '4-6 weeks after flowering',
      'difficulty': 'Medium',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Rich, slightly acidic',
    },
    {
      'name': 'Guava',
      'scientificName': 'Psidium guajava',
      'category': 'Fruits',
      'icon': Icons.circle,
      'color': Color(0xFF8BC34A),
      'description': 'Tropical fruit with fragrant flesh. High in vitamin C.',
      'growthTime': '2-4 years to fruit',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'Moderate',
      'soil': 'Well-drained',
    },
    {
      'name': 'Coconut',
      'scientificName': 'Cocos nucifera',
      'category': 'Fruits',
      'icon': Icons.circle,
      'color': Color(0xFF795548),
      'description':
          'Versatile tropical palm fruit providing water, milk, oil, and flesh.',
      'growthTime': '5-6 years to fruit',
      'difficulty': 'Hard',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Sandy, well-drained',
    },

    // Herbs
    {
      'name': 'Basil',
      'scientificName': 'Ocimum basilicum',
      'category': 'Herbs',
      'icon': Icons.local_florist,
      'color': Color(0xFF4CAF50),
      'description':
          'Aromatic herb essential in Italian and Thai cuisine. Easy to grow indoors.',
      'growthTime': '50-75 days',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Moist, well-drained',
    },
    {
      'name': 'Lemongrass',
      'scientificName': 'Cymbopogon citratus',
      'category': 'Herbs',
      'icon': Icons.yard,
      'color': Color(0xFFC5E1A5),
      'description':
          'Fragrant herb used in Asian cuisine and tea. Also repels mosquitoes.',
      'growthTime': '75-100 days',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'High',
      'soil': 'Rich, moist',
    },
    {
      'name': 'Mint',
      'scientificName': 'Mentha',
      'category': 'Herbs',
      'icon': Icons.spa,
      'color': Color(0xFF26A69A),
      'description':
          'Refreshing herb used in drinks, desserts, and savory dishes. Spreads quickly.',
      'growthTime': '30-40 days',
      'difficulty': 'Easy',
      'sunlight': 'Partial shade',
      'water': 'Regular',
      'soil': 'Moist, rich',
    },
    {
      'name': 'Coriander',
      'scientificName': 'Coriandrum sativum',
      'category': 'Herbs',
      'icon': Icons.eco,
      'color': Color(0xFF66BB6A),
      'description':
          'Versatile herb with edible leaves and seeds. Essential in Asian cooking.',
      'growthTime': '45-70 days',
      'difficulty': 'Easy',
      'sunlight': 'Partial to full sun',
      'water': 'Moderate',
      'soil': 'Well-drained',
    },
    {
      'name': 'Pandan',
      'scientificName': 'Pandanus amaryllifolius',
      'category': 'Herbs',
      'icon': Icons.grass,
      'color': Color(0xFF388E3C),
      'description':
          'Fragrant leaves used in Southeast Asian desserts and rice dishes.',
      'growthTime': '6-12 months',
      'difficulty': 'Easy',
      'sunlight': 'Partial shade',
      'water': 'High',
      'soil': 'Moist, rich',
    },
    {
      'name': 'Turmeric',
      'scientificName': 'Curcuma longa',
      'category': 'Herbs',
      'icon': Icons.circle,
      'color': Color(0xFFFF9800),
      'description':
          'Golden spice with anti-inflammatory properties. Used in curries.',
      'growthTime': '8-10 months',
      'difficulty': 'Medium',
      'sunlight': 'Partial shade',
      'water': 'Regular',
      'soil': 'Rich, well-drained',
    },
    {
      'name': 'Ginger',
      'scientificName': 'Zingiber officinale',
      'category': 'Herbs',
      'icon': Icons.spa,
      'color': Color(0xFFFFCC80),
      'description':
          'Spicy rhizome used in cooking and traditional medicine worldwide.',
      'growthTime': '8-10 months',
      'difficulty': 'Medium',
      'sunlight': 'Partial shade',
      'water': 'Regular',
      'soil': 'Rich, moist',
    },

    // Grains
    {
      'name': 'Rice',
      'scientificName': 'Oryza sativa',
      'category': 'Grains',
      'icon': Icons.grain,
      'color': Color(0xFFE0E0E0),
      'description':
          'Staple food for over half of world population. Grown in paddies.',
      'growthTime': '120-150 days',
      'difficulty': 'Medium',
      'sunlight': 'Full sun',
      'water': 'Flooded paddies',
      'soil': 'Clay, water-retaining',
    },
    {
      'name': 'Corn',
      'scientificName': 'Zea mays',
      'category': 'Grains',
      'icon': Icons.grain,
      'color': Color(0xFFFDD835),
      'description':
          'Versatile grain used for food, feed, and industrial products.',
      'growthTime': '60-100 days',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Fertile, well-drained',
    },
    {
      'name': 'Wheat',
      'scientificName': 'Triticum aestivum',
      'category': 'Grains',
      'icon': Icons.grass,
      'color': Color(0xFFD4A574),
      'description':
          'Major cereal grain for bread and pasta. Cool season crop.',
      'growthTime': '120-180 days',
      'difficulty': 'Medium',
      'sunlight': 'Full sun',
      'water': 'Moderate',
      'soil': 'Fertile loam',
    },

    // Flowers
    {
      'name': 'Orchid',
      'scientificName': 'Orchidaceae',
      'category': 'Flowers',
      'icon': Icons.filter_vintage,
      'color': Color(0xFFAB47BC),
      'description':
          'Beautiful flowering plant with diverse varieties. Popular ornamental.',
      'growthTime': 'Varies by species',
      'difficulty': 'Hard',
      'sunlight': 'Indirect light',
      'water': 'Weekly',
      'soil': 'Bark mix, well-drained',
    },
    {
      'name': 'Sunflower',
      'scientificName': 'Helianthus annuus',
      'category': 'Flowers',
      'icon': Icons.wb_sunny,
      'color': Color(0xFFFFEB3B),
      'description':
          'Tall flowering plant that tracks the sun. Seeds are edible.',
      'growthTime': '70-100 days',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Well-drained',
    },
    {
      'name': 'Rose',
      'scientificName': 'Rosa',
      'category': 'Flowers',
      'icon': Icons.local_florist,
      'color': Color(0xFFE91E63),
      'description':
          'Classic flowering plant symbolizing love. Many varieties available.',
      'growthTime': '6-8 weeks to bloom',
      'difficulty': 'Medium',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Rich, well-drained',
    },
    {
      'name': 'Jasmine',
      'scientificName': 'Jasminum',
      'category': 'Flowers',
      'icon': Icons.spa,
      'color': Color(0xFFFFFDE7),
      'description': 'Fragrant white flowers used in teas and perfumes.',
      'growthTime': '6 months to bloom',
      'difficulty': 'Medium',
      'sunlight': 'Full to partial sun',
      'water': 'Regular',
      'soil': 'Well-drained',
    },
    {
      'name': 'Hibiscus',
      'scientificName': 'Hibiscus rosa-sinensis',
      'category': 'Flowers',
      'icon': Icons.local_florist,
      'color': Color(0xFFF44336),
      'description':
          'Tropical flower with large colorful blooms. Malaysia\'s national flower.',
      'growthTime': '3-4 months to bloom',
      'difficulty': 'Easy',
      'sunlight': 'Full sun',
      'water': 'Regular',
      'soil': 'Rich, well-drained',
    },
  ];

  List<Map<String, dynamic>> get _filteredPlants {
    if (_selectedCategory == 'All') {
      return _plants;
    }
    return _plants
        .where((plant) => plant['category'] == _selectedCategory)
        .toList();
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Color(0xFF2E7D32)
                                : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
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
                  style: TextStyle(color: Colors.white70, fontSize: 14),
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
          border: Border.all(color: Color(0xFF4CAF50), width: 2),
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
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: plant['color'] as Color,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (plant['color'] as Color).withOpacity(
                                  0.4,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
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

                    _buildInfoCard(
                      Icons.schedule,
                      'Growth Time',
                      plant['growthTime'],
                    ),
                    _buildInfoCard(
                      Icons.trending_up,
                      'Difficulty',
                      plant['difficulty'],
                    ),
                    _buildInfoCard(
                      Icons.wb_sunny,
                      'Sunlight',
                      plant['sunlight'],
                    ),
                    _buildInfoCard(Icons.water_drop, 'Water', plant['water']),
                    _buildInfoCard(Icons.landscape, 'Soil', plant['soil']),

                    const SizedBox(height: 24),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${plant['name']} added to your garden!',
                              ),
                              backgroundColor: Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
