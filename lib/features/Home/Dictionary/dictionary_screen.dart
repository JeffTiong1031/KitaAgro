import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kita_agro/core/services/gemini_api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String _selectedCategory = 'All';
  final ScrollController _gridController = ScrollController();
  final GeminiApiService _geminiService = GeminiApiService('AIzaSyAONXuYRzzHalWMopx82Zalefaa2-w5lmU');

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
      builder: (context) => _PlantDetailSheet(
        plant: plant,
        geminiService: _geminiService,
        onAddToGarden: () => _addPlantToGarden(plant),
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

// ========== AI-POWERED PLANT DETAIL SHEET ==========

class _PlantDetailSheet extends StatefulWidget {
  final Map<String, dynamic> plant;
  final GeminiApiService geminiService;
  final VoidCallback onAddToGarden;

  const _PlantDetailSheet({
    required this.plant,
    required this.geminiService,
    required this.onAddToGarden,
  });

  @override
  State<_PlantDetailSheet> createState() => _PlantDetailSheetState();
}

class _PlantDetailSheetState extends State<_PlantDetailSheet> {
  Map<String, dynamic>? _aiAdvice;
  bool _isLoadingAI = true;
  String _locationName = 'Unknown';
  double _temperature = 25.0;
  String _weatherCondition = 'Clear';
  String _debugError = '';

  @override
  void initState() {
    super.initState();
    _loadLocationAndAI();
  }

  Future<void> _loadLocationAndAI() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // No user logged in - use default location for demo
        _locationName = 'Malaysia';
        _fetchAIAdvice();
        return;
      }

      // Fetch saved garden location from user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || userDoc.data()?['gardenLocation'] == null) {
        // No saved location - use default location for demo
        _locationName = 'Malaysia';
        _fetchAIAdvice();
        return;
      }

      final locationData = userDoc.data()!['gardenLocation'] as Map<String, dynamic>;
      final latitude = locationData['latitude'] as double;
      final longitude = locationData['longitude'] as double;
      _locationName = locationData['address'] ?? 'Your location';

      // Fetch current weather
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code',
      );
      final weatherResponse = await http.get(weatherUrl);

      if (weatherResponse.statusCode == 200) {
        final weatherJson = jsonDecode(weatherResponse.body);
        _temperature = (weatherJson['current']?['temperature_2m'] ?? 25.0).toDouble();
        final weatherCode = weatherJson['current']?['weather_code'] ?? 0;
        _weatherCondition = _weatherCodeToCondition(weatherCode);
      }

      // Fetch AI advice with real data
      _fetchAIAdvice();
    } catch (e) {
      print('Error loading AI advice: $e');
      setState(() => _isLoadingAI = false);
    }
  }

  Future<void> _fetchAIAdvice() async {
    try {
      print('🤖 Calling Gemini AI for ${widget.plant['name']}...');
      print('📍 Location: $_locationName');
      print('🌡️ Temperature: $_temperature°C');
      print('🌤️ Weather: $_weatherCondition');
      
      // Fetch AI advice
      final advice = await widget.geminiService.getLocalizedAdvice(
        plantName: widget.plant['name'],
        scientificName: widget.plant['scientificName'],
        category: widget.plant['category'],
        location: _locationName,
        temperature: _temperature,
        weatherCondition: _weatherCondition,
      );

      print('✅ AI Response received: ${advice != null}');
      if (advice != null) {
        print('📊 Local Match Score: ${advice['localMatchScore']}');
        print('🌱 Growing Tips: ${advice['growingTips'] != null}');
      } else {
        print('⚠️ AI returned null - using fallback data');
        _debugError = 'API returned null - check console';
        // Provide fallback data for testing
        setState(() {
          _aiAdvice = {
            'localMatchScore': 80,
            'growingContext': 'In $_locationName\'s tropical climate (${_temperature.toStringAsFixed(1)}°C, $_weatherCondition), this ${widget.plant['name']} adapts well with proper care. The consistent warmth and humidity provide excellent growing conditions.',
            'growingTips': {
              'sunlight': 'In your tropical climate, provide morning sun (6-8 hours) to avoid afternoon heat stress. Consider partial shade during peak hours.',
              'watering': 'During $_weatherCondition weather, adjust watering frequency. Check soil moisture before watering to prevent root rot in humid conditions.',
              'soil': 'Use well-draining soil mixed with organic compost. In $_locationName, add extra drainage materials due to high rainfall.',
            },
            'carbonReduction': 'Growing this ${widget.plant['name']} saves approximately 2.5 kg CO₂/month compared to store-bought produce, while reducing food miles.',
          };
          _isLoadingAI = false;
        });
        return;
      }

      setState(() {
        _aiAdvice = advice;
        _isLoadingAI = false;
      });
    } catch (e) {
      print('❌ Error fetching AI advice: $e');
      _debugError = 'Exception: ${e.toString()}';
      setState(() => _isLoadingAI = false);
    }
  }

  String _weatherCodeToCondition(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 49) return 'Foggy';
    if (code <= 59) return 'Drizzle';
    if (code <= 69) return 'Rainy';
    if (code <= 79) return 'Snowy';
    if (code <= 84) return 'Showers';
    return 'Stormy';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // Location info banner
                  if (_locationName == 'Malaysia')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Save your garden location in My Journey for personalized local advice!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_locationName == 'Malaysia') const SizedBox(height: 16),

                  const SizedBox(height: 8),

                  // DEBUG PANEL - Remove after testing
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔍 Debug Info',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Loading: $_isLoadingAI',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                        ),
                        Text(
                          'AI Data: ${_aiAdvice != null ? "✅ Received" : "❌ Null"}',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                        ),
                        Text(
                          'Location: $_locationName',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                        ),
                        if (_aiAdvice != null)
                          Text(
                            'Score: ${_aiAdvice!['localMatchScore']}',
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                          ),
                        if (_debugError.isNotEmpty)
                          Text(
                            'Error: $_debugError',
                            style: TextStyle(fontSize: 11, color: Colors.red.shade800),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // AI SECTION 1: Local Match Score
                  if (_aiAdvice != null) ...[
                    _buildLocalMatchScore(_aiAdvice!['localMatchScore']),
                    const SizedBox(height: 16),
                  ],

                  // AI SECTION 2: Local Growing Context
                  if (_aiAdvice != null) ...[
                    _buildLocalGrowingContext(_aiAdvice!['growingContext']),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  _buildSection('About', widget.plant['description']),
                  const SizedBox(height: 24),

                  // AI SECTION 3: AI-Enhanced Growing Guide
                  _buildAIGrowingGuide(),
                  const SizedBox(height: 24),

                  // AI SECTION 4: Carbon Reduction
                  if (_aiAdvice != null) ...[
                    _buildCarbonReduction(_aiAdvice!['carbonReduction']),
                    const SizedBox(height: 16),
                  ],

                  // Loading state
                  if (_isLoadingAI)
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF2E7D32),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '🤖 AI is analyzing local conditions...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onAddToGarden();
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
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.plant['color'] as Color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (widget.plant['color'] as Color).withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.plant['icon'] as IconData,
                color: Colors.white,
                size: 40,
              ),
            ),
            Positioned(
              top: -2,
              right: -2,
              child: GestureDetector(
                onTap: widget.onAddToGarden,
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
                widget.plant['name'],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.plant['scientificName'],
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
                  widget.plant['category'],
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
    );
  }

  // AI SECTION 1: Local Match Score
  Widget _buildLocalMatchScore(int score) {
    Color scoreColor;
    String scoreLabel;
    if (score >= 80) {
      scoreColor = Colors.green;
      scoreLabel = 'Excellent Match';
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      scoreLabel = 'Good Match';
    } else {
      scoreColor = Colors.red;
      scoreLabel = 'Challenging';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scoreColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: scoreColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local Climate Match',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  scoreLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'for $_locationName',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.eco, color: scoreColor, size: 32),
        ],
      ),
    );
  }

  // AI SECTION 2: Local Growing Context
  Widget _buildLocalGrowingContext(String context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2E7D32).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 8),
              Text(
                'Local Growing Context',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '🌡️ Current: ${_temperature.toStringAsFixed(1)}°C, $_weatherCondition',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // AI SECTION 3: AI-Enhanced Growing Guide
  Widget _buildAIGrowingGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_florist, color: Color(0xFF2E7D32), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Growing Guide',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            if (_aiAdvice != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    const Text(
                      'AI Enhanced',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        
        // Growth Time (static)
        _buildInfoCard(Icons.schedule, 'Growth Time', widget.plant['growthTime']),
        
        // Difficulty (static)
        _buildInfoCard(Icons.trending_up, 'Difficulty', widget.plant['difficulty']),
        
        // Sunlight - AI Enhanced or Static
        if (_aiAdvice != null && _aiAdvice!['growingTips'] != null)
          _buildAIInfoCard(
            Icons.wb_sunny,
            'Sunlight',
            widget.plant['sunlight'],
            _aiAdvice!['growingTips']['sunlight'],
          )
        else
          _buildInfoCard(Icons.wb_sunny, 'Sunlight', widget.plant['sunlight']),
        
        // Water - AI Enhanced or Static
        if (_aiAdvice != null && _aiAdvice!['growingTips'] != null)
          _buildAIInfoCard(
            Icons.water_drop,
            'Water',
            widget.plant['water'],
            _aiAdvice!['growingTips']['watering'],
          )
        else
          _buildInfoCard(Icons.water_drop, 'Water', widget.plant['water']),
        
        // Soil - AI Enhanced or Static
        if (_aiAdvice != null && _aiAdvice!['growingTips'] != null)
          _buildAIInfoCard(
            Icons.landscape,
            'Soil',
            widget.plant['soil'],
            _aiAdvice!['growingTips']['soil'],
          )
        else
          _buildInfoCard(Icons.landscape, 'Soil', widget.plant['soil']),
      ],
    );
  }

  // AI SECTION 4: Carbon Reduction
  Widget _buildCarbonReduction(String carbonText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Carbon Impact',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  carbonText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // AI-Enhanced Info Card with expandable AI tip
  Widget _buildAIInfoCard(IconData icon, String label, String baseValue, String aiTip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2E7D32).withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
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
                        baseValue,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFF2E7D32).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome, color: Color(0xFF2E7D32), size: 16),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFF2E7D32), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    aiTip,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
