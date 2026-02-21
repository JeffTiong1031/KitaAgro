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
  final GeminiApiService _geminiService = GeminiApiService('AIzaSyBkgljGd-zVO4lV5Cqpfipo0Br8pKwBe-k');

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
    },
    {
      'name': 'Chili',
      'scientificName': 'Capsicum annuum',
      'category': 'Vegetables',
      'icon': Icons.local_fire_department,
      'color': Color(0xFFD32F2F),
      'description': 'Spicy fruit used in many cuisines worldwide. Contains capsaicin which gives the heat.',
    },
    // Fruits
    {
      'name': 'Papaya',
      'scientificName': 'Carica papaya',
      'category': 'Fruits',
      'icon': Icons.spa,
      'color': Color(0xFFFFB300),
      'description': 'Tropical fruit with sweet orange flesh. Rich in enzymes and vitamins.',
    },
    {
      'name': 'Banana',
      'scientificName': 'Musa acuminata',
      'category': 'Fruits',
      'icon': Icons.nature,
      'color': Color(0xFFFFEB3B),
      'description': 'Tropical fruit rich in potassium. Requires warm frost-free climate (above 10°C year-round). Dies at 0°C. NOT suitable for temperate zones with winter frost.',
    },
    {
      'name': 'Strawberry',
      'scientificName': 'Fragaria × ananassa',
      'category': 'Fruits',
      'icon': Icons.local_florist,
      'color': Color(0xFFE91E63),
      'description': 'Sweet red fruit rich in vitamin C and antioxidants. Best with good drainage and regular care.',
    },
    {
      'name': 'Apple',
      'scientificName': 'Malus domestica',
      'category': 'Fruits',
      'icon': Icons.apple,
      'color': Color(0xFFEF5350),
      'description': 'Temperate fruit tree requiring 800-1000 chill hours (below 7°C). NOT suitable for tropical lowlands. Best in highland areas above 1000m elevation.',
    },
    // Herbs
    {
      'name': 'Pandan',
      'scientificName': 'Pandanus amaryllifolius',
      'category': 'Herbs',
      'icon': Icons.grass,
      'color': Color(0xFF388E3C),
      'description': 'Fragrant leaves used in Southeast Asian desserts and rice dishes.',
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
      return 90; // Default 90 days if no data available
    }
    final String lower = growthTime.toLowerCase();
    final match = RegExp(r'(\d+)').firstMatch(lower);
    if (match == null) {
      return 90;
    }
    final int value = int.tryParse(match.group(1) ?? '') ?? 90;
    if (lower.contains('month')) {
      return value * 30;
    }
    if (lower.contains('year')) {
      return value * 365;
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
  // Static cache to prevent duplicate API calls
  static final Map<String, Map<String, dynamic>> _aiCache = {};
  
  Map<String, dynamic>? _aiAdvice;
  bool _isLoadingAI = true;
  String _locationName = 'Unknown';
  double _temperature = 25.0;
  String _weatherCondition = 'Clear';
  String _debugError = ''; 
  
  // Track which cards are expanded
  final Set<String> _expandedCards = {};

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
      final plantName = widget.plant['name'];
      final cacheKey = '$plantName-$_locationName';
      
      // Check cache first
      if (_aiCache.containsKey(cacheKey)) {
        print('💾 Using cached data for $plantName in $_locationName');
        setState(() {
          _aiAdvice = _aiCache[cacheKey];
          _isLoadingAI = false;
          _debugError = 'Data: Cached ✓';
        });
        return;
      }
      
      print('🤖 Calling Gemini AI for $plantName...');
      print('📍 Location: $_locationName');
      print('🌡️ Temperature: $_temperature°C');
      print('🌤️ Weather: $_weatherCondition');
      
      // Fetch AI advice
      final advice = await widget.geminiService.getLocalizedAdvice(
        plantName: plantName,
        scientificName: widget.plant['scientificName'],
        category: widget.plant['category'],
        location: _locationName,
        temperature: _temperature,
        weatherCondition: _weatherCondition,
      );

      print('✅ AI Response received: ${advice != null}');
      if (advice != null) {
        print('📊 Local Match Score: ${advice['localMatchScore']}');
        print('🌱 Growth Time: ${advice['growthTime']}');
        print('☀️ Sunlight: ${advice['sunlight']}');
        
        // Cache the result
        _aiCache[cacheKey] = advice;
        _debugError = 'Data: OK ✓';
      } else {
        print('⚠️ AI returned null - no fallback provided');
        print('❌ Check Gemini API logs above for details');
        _debugError = 'API quota exceeded. Try again in 1 minute.';
        setState(() {
          _aiAdvice = null;
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

  String _getDetailedInfo(String key) {
    final plantName = widget.plant['name'];
    final location = _locationName;
    
    switch (key) {
      case 'growthTime':
        return 'Growth time varies based on your local climate conditions in $location. '
               'Factors like temperature (${_temperature.toStringAsFixed(1)}°C), daylight hours, '
               'and seasonal patterns all affect how quickly $plantName matures.';
               
      case 'difficulty':
        return 'Difficulty rating considers climate compatibility, maintenance requirements, '
               'pest resistance, and how well $plantName adapts to $location conditions. '
               'Beginners should start with "Easy" rated plants.';
               
      case 'sunlight':
        return 'Sunlight requirements are crucial for photosynthesis and healthy growth. '
               'In $location, consider seasonal variations and provide shade during extremely hot periods. '
               'Morning sun is generally gentler than harsh afternoon sun.';
               
      case 'watering':
        return 'Current weather: $_weatherCondition at ${_temperature.toStringAsFixed(1)}°C. '
               'Adjust watering frequency based on rainfall, humidity, and soil moisture. '
               'Overwatering is a common mistake - check soil before watering.';
               
      case 'soil':
        return 'Soil quality directly impacts nutrient availability and root health. '
               'In $location, amend soil based on local conditions. Good drainage prevents root rot, '
               'while organic matter improves fertility and water retention.';
               
      default:
        return '';
    }
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

                  // AI SECTION 3.5: Growth Stages Timeline
                  if (_aiAdvice != null && _aiAdvice!['growthStages'] != null)
                    _buildGrowthStagesTimeline(_aiAdvice!['growthStages']),
                  if (_aiAdvice != null && _aiAdvice!['growthStages'] != null)
                    const SizedBox(height: 24),

                  // AI SECTION 3.6: Materials Needed
                  if (_aiAdvice != null && _aiAdvice!['materialsNeeded'] != null)
                    _buildMaterialsNeeded(_aiAdvice!['materialsNeeded']),
                  if (_aiAdvice != null && _aiAdvice!['materialsNeeded'] != null)
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
                      'AI Powered',
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
        
        _buildInfoCard(
          Icons.schedule, 
          'Growth Time',
          'growthTime',
          _aiAdvice?['growthTime'] ?? '',
        ),
        _buildInfoCard(
          Icons.trending_up, 
          'Difficulty',
          'difficulty',
          _aiAdvice?['difficulty'] ?? '',
        ),
        _buildInfoCard(
          Icons.wb_sunny, 
          'Sunlight',
          'sunlight',
          _aiAdvice?['sunlight'] ?? '',
        ),
        _buildInfoCard(
          Icons.water_drop, 
          'Water',
          'watering',
          _aiAdvice?['watering'] ?? '',
        ),
        _buildInfoCard(
          Icons.landscape, 
          'Soil',
          'soil',
          _aiAdvice?['soil'] ?? '',
        ),
      ],
    );
  }

  // AI SECTION 3.5: Growth Stages Timeline
  Widget _buildGrowthStagesTimeline(dynamic rawStages) {
    final List<Map<String, dynamic>> stages = [];
    if (rawStages is List) {
      for (final item in rawStages) {
        if (item is Map<String, dynamic>) {
          final int? start = item['startDay'] is int
              ? item['startDay'] as int
              : int.tryParse('${item['startDay']}');
          final int? end = item['endDay'] is int
              ? item['endDay'] as int
              : int.tryParse('${item['endDay']}');
          final String stage = (item['stage'] ?? '').toString().trim();
          final String desc = (item['description'] ?? '').toString().trim();
          if (start != null && end != null && stage.isNotEmpty) {
            stages.add({
              'stage': stage,
              'startDay': start,
              'endDay': end,
              'description': desc,
            });
          }
        }
      }
    }

    if (stages.isEmpty) return const SizedBox.shrink();

    stages.sort((a, b) => (a['startDay'] as int).compareTo(b['startDay'] as int));

    final int totalDays = stages.last['endDay'] as int;

    const List<Color> stageColors = [
      Color(0xFF8D6E63), // brown - seed
      Color(0xFF66BB6A), // light green - sprout
      Color(0xFF43A047), // green - vegetative
      Color(0xFFFFB300), // amber - flowering
      Color(0xFFEF5350), // red - fruiting
      Color(0xFFAB47BC), // purple - ripening
      Color(0xFF26A69A), // teal - harvest
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline, color: Color(0xFF2E7D32), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Growth Stages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
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
                    'AI Powered',
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
        ),
        const SizedBox(height: 4),
        Text(
          'Total: $totalDays days',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 16),

        // Proportional color bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 14,
            child: Row(
              children: List.generate(stages.length, (i) {
                final s = stages[i];
                final int days = (s['endDay'] as int) - (s['startDay'] as int) + 1;
                final double fraction = days / totalDays;
                return Expanded(
                  flex: (fraction * 1000).round().clamp(1, 1000),
                  child: Container(color: stageColors[i % stageColors.length]),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stage timeline cards
        ...List.generate(stages.length, (i) {
          final s = stages[i];
          final color = stageColors[i % stageColors.length];
          final int startDay = s['startDay'] as int;
          final int endDay = s['endDay'] as int;
          final int days = endDay - startDay + 1;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: dot + vertical line
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      if (i < stages.length - 1)
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Right: card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s['stage'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Day $startDay\u2013$endDay',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if ((s['description'] as String).isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            s['description'] as String,
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '$days days',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // AI SECTION 3.6: Materials Needed
  Widget _buildMaterialsNeeded(dynamic rawMaterials) {
    if (rawMaterials == null || rawMaterials is! List || rawMaterials.isEmpty) {
      return const SizedBox.shrink();
    }

    final materials = rawMaterials.cast<Map<String, dynamic>>();

    IconData _materialIcon(String item) {
      final lower = item.toLowerCase();
      if (lower.contains('seed')) return Icons.grain;
      if (lower.contains('fertiliz') || lower.contains('compost') || lower.contains('manure')) return Icons.science;
      if (lower.contains('pot') || lower.contains('container') || lower.contains('tray')) return Icons.inventory_2;
      if (lower.contains('water') || lower.contains('hose') || lower.contains('can')) return Icons.water_drop;
      if (lower.contains('soil') || lower.contains('mulch') || lower.contains('peat')) return Icons.terrain;
      if (lower.contains('trellis') || lower.contains('stake') || lower.contains('support')) return Icons.vertical_align_top;
      if (lower.contains('net') || lower.contains('cover') || lower.contains('shade')) return Icons.shield;
      if (lower.contains('prun') || lower.contains('scissor') || lower.contains('shear')) return Icons.content_cut;
      if (lower.contains('pesticide') || lower.contains('spray') || lower.contains('insect')) return Icons.bug_report;
      if (lower.contains('shovel') || lower.contains('spade') || lower.contains('tool') || lower.contains('hoe')) return Icons.handyman;
      return Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag, color: Colors.amber[800], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Materials Needed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: Colors.amber[800]),
                    const SizedBox(width: 4),
                    Text(
                      'AI Powered',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: materials.map<Widget>((m) {
              final item = (m['item'] as String?) ?? '';
              final purpose = (m['purpose'] as String?) ?? '';
              return Tooltip(
                message: purpose,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_materialIcon(item), size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          if (purpose.isNotEmpty)
                            Text(
                              purpose,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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

  Widget _buildInfoCard(IconData icon, String label, String key, String? value) {
    // Only show card if value exists and is not empty
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final isExpanded = _expandedCards.contains(key);
    final detailedInfo = _getDetailedInfo(key);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedCards.remove(key);
          } else {
            _expandedCards.add(key);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isExpanded ? Color(0xFFE8F5E9) : Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded ? Color(0xFF2E7D32) : Colors.transparent,
            width: isExpanded ? 2 : 0,
          ),
        ),
        child: Column(
          children: [
            Row(
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
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
              ],
            ),
            if (isExpanded && detailedInfo.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  detailedInfo,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

