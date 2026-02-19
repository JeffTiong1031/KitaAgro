import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:kita_agro/features/Home/Planting/planting_screen.dart';
import 'package:kita_agro/features/Home/Dictionary/dictionary_screen.dart';
import 'package:kita_agro/features/Home/my_journey/my_journey_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  final PageController _gardenCarouselController = PageController(viewportFraction: 0.85);
  int _currentGardenPage = 0;
  final ValueNotifier<int> _gardenPageNotifier = ValueNotifier<int>(0);
  Future<_WeatherData?>? _weatherFuture;
  String? _weatherLocationKey;
  DateTime? _weatherFetchedAt;

  @override
  void dispose() {
    _gardenCarouselController.dispose();
    _gardenPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: null,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search crops, pests...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.notifications, color: Colors.grey[700], size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Dashboard Section
          SliverToBoxAdapter(
            child: _buildDashboard(),
          ),
          // My Garden Carousel
          SliverToBoxAdapter(
            child: _buildMyGardenCarousel(),
          ),
          // Action Buttons Section
          SliverToBoxAdapter(
            child: _buildActionButtons(),
          ),
          // Tab Navigation
          SliverToBoxAdapter(
            child: _buildTabNavigation(),
          ),
          // Community Posts
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCommunityPost(index),
              childCount: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _gardenPlantStream(),
      builder: (context, snapshot) {
        final plants = snapshot.data ?? <Map<String, dynamic>>[];

        final totalProgress = plants.fold<double>(
          0,
          (sum, plant) {
            final totalDays = plant['totalDays'] as int;
            final daysPlanted = plant['daysPlanted'] as int;
            if (totalDays <= 0) {
              return sum;
            }
            return sum + (daysPlanted / totalDays).clamp(0.0, 1.0);
          },
        );

        final averageProgress = plants.isEmpty ? 0.0 : (totalProgress / plants.length);
        final progressPercent = (averageProgress * 100).round();

        Map<String, dynamic>? nextPlant;
        int? nextHarvestDays;
        for (final plant in plants) {
          final totalDays = plant['totalDays'] as int;
          final daysPlanted = plant['daysPlanted'] as int;
          final remaining = totalDays - daysPlanted;
          if (remaining <= 0) {
            continue;
          }
          if (nextHarvestDays == null || remaining < nextHarvestDays) {
            nextHarvestDays = remaining;
            nextPlant = plant;
          }
        }

        final reminderTitle = plants.isEmpty
            ? 'Add your first plant'
            : nextPlant == null
                ? 'Ready to harvest'
                : '${nextPlant['name']} in $nextHarvestDays day${nextHarvestDays == 1 ? '' : 's'}';

        final reminderColor = plants.isEmpty
            ? Colors.orange
            : nextPlant == null
                ? Colors.green
                : Colors.red;

        final reminderIcon = plants.isEmpty
            ? Icons.add_circle_outline
            : nextPlant == null
                ? Icons.check_circle
                : Icons.schedule;

        return Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 8,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: averageProgress,
                                    strokeWidth: 8,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[400]!),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: const Icon(Icons.eco, color: Colors.white, size: 32),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$progressPercent%',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[400],
                            ),
                          ),
                          Text(
                            plants.isEmpty ? 'No plants yet' : 'Average Growth',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StreamBuilder<Map<String, dynamic>?>(
                            stream: _gardenLocationStream(),
                            builder: (context, locationSnapshot) {
                              final locationData = locationSnapshot.data;
                              final locationText = _formatGardenLocation(locationData);
                              final weatherFuture = _weatherFutureForLocation(locationData);

                              return FutureBuilder<_WeatherData?>(
                                future: weatherFuture,
                                builder: (context, weatherSnapshot) {
                                  final weather = weatherSnapshot.data;
                                  final isLoading = weatherSnapshot.connectionState == ConnectionState.waiting;
                                  final hasError = weatherSnapshot.hasError;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Today',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Icon(
                                              weather != null ? _weatherIconForCode(weather.weatherCode) : Icons.cloud_outlined,
                                              color: Colors.blue[600],
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        if (isLoading)
                                          const Text(
                                            'Loading weather...',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        else if (weather != null)
                                          Text(
                                            '${weather.temperatureCelsius.toStringAsFixed(1)}°C',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        else
                                          Text(
                                            hasError
                                                ? 'Weather unavailable'
                                                : 'Set location first',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        const SizedBox(height: 2),
                                        Text(
                                          weather != null
                                              ? _weatherConditionLabel(weather.weatherCode)
                                              : locationText,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Reminder',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Icon(reminderIcon, color: reminderColor, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  reminderTitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<Map<String, dynamic>?> _gardenLocationStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      final location = data?['gardenLocation'];
      if (location is Map<String, dynamic>) {
        return location;
      }
      if (location is Map) {
        return location.cast<String, dynamic>();
      }
      return null;
    });
  }

  String _formatGardenLocation(Map<String, dynamic>? locationData) {
    if (locationData == null) {
      return 'Set in My Journey';
    }

    final address = locationData['address'] as String?;
    if (address != null && address.trim().isNotEmpty) {
      final firstSegment = address.split(',').first.trim();
      return firstSegment.isEmpty ? address : firstSegment;
    }

    final latitude = (locationData['latitude'] as num?)?.toDouble();
    final longitude = (locationData['longitude'] as num?)?.toDouble();
    if (latitude != null && longitude != null) {
      return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }

    return 'Set in My Journey';
  }

  Future<_WeatherData?> _weatherFutureForLocation(Map<String, dynamic>? locationData) {
    final latitude = (locationData?['latitude'] as num?)?.toDouble();
    final longitude = (locationData?['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) {
      return Future.value(null);
    }

    final key = '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';
    final now = DateTime.now();
    final shouldRefresh = _weatherFuture == null ||
        _weatherLocationKey != key ||
        _weatherFetchedAt == null ||
        now.difference(_weatherFetchedAt!) > const Duration(minutes: 20);

    if (shouldRefresh) {
      _weatherLocationKey = key;
      _weatherFetchedAt = now;
      _weatherFuture = _fetchCurrentWeather(latitude: latitude, longitude: longitude);
    }

    return _weatherFuture!;
  }

  Future<_WeatherData?> _fetchCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,weather_code',
        'timezone': 'auto',
      });

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return null;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final current = payload['current'] as Map<String, dynamic>?;
      if (current == null) {
        return null;
      }

      final temperature = (current['temperature_2m'] as num?)?.toDouble();
      final weatherCode = (current['weather_code'] as num?)?.toInt();
      if (temperature == null || weatherCode == null) {
        return null;
      }

      return _WeatherData(
        temperatureCelsius: temperature,
        weatherCode: weatherCode,
      );
    } catch (_) {
      return null;
    }
  }

  String _weatherConditionLabel(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1 || code == 2) return 'Partly cloudy';
    if (code == 3) return 'Cloudy';
    if (code == 45 || code == 48) return 'Fog';
    if (code == 51 || code == 53 || code == 55) return 'Drizzle';
    if (code == 56 || code == 57) return 'Freezing drizzle';
    if (code == 61 || code == 63 || code == 65) return 'Rain';
    if (code == 66 || code == 67) return 'Freezing rain';
    if (code == 71 || code == 73 || code == 75 || code == 77) return 'Snow';
    if (code == 80 || code == 81 || code == 82) return 'Rain showers';
    if (code == 85 || code == 86) return 'Snow showers';
    if (code == 95 || code == 96 || code == 99) return 'Thunderstorm';
    return 'Unknown';
  }

  IconData _weatherIconForCode(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code == 1 || code == 2) return Icons.wb_cloudy;
    if (code == 3) return Icons.cloud;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code == 51 || code == 53 || code == 55 || code == 56 || code == 57) {
      return Icons.grain;
    }
    if (code == 61 || code == 63 || code == 65 || code == 66 || code == 67 || code == 80 || code == 81 || code == 82) {
      return Icons.umbrella;
    }
    if (code == 71 || code == 73 || code == 75 || code == 77 || code == 85 || code == 86) {
      return Icons.ac_unit;
    }
    if (code == 95 || code == 96 || code == 99) return Icons.flash_on;
    return Icons.cloud_outlined;
  }

  Widget _buildActionButtons() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            label: 'My Journey',
            color: Colors.teal[100]!,
            icon: Icons.favorite,
            iconColor: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyJourneyScreen()),
              );
            },
          ),
          _buildActionButton(
            label: 'Dictionary',
            color: Colors.orange[100]!,
            icon: Icons.description,
            iconColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DictionaryScreen()),
              );
            },
          ),
          _buildActionButton(
            label: 'AI Assistant',
            color: Colors.purple[100]!,
            icon: Icons.smart_toy,
            iconColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    final tabs = ['Community', 'Recommend', 'Market', 'Q&A'];
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
                        color: _selectedTabIndex == index ? Colors.teal : Colors.grey,
                      ),
                    ),
                  ),
                  if (_selectedTabIndex == index)
                    Container(
                      height: 3,
                      color: Colors.teal,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityPost(int index) {
    final users = [
      {'name': 'David Miller', 'role': 'Urban Gardener', 'time': '2h ago'},
      {'name': 'Sarah Jenkins', 'role': 'Expert Farmer', 'time': '5h ago'},
      {'name': 'John Smith', 'role': 'Crop Specialist', 'time': '3h ago'},
      {'name': 'Emma Wilson', 'role': 'Soil Expert', 'time': '1h ago'},
      {'name': 'Robert Brown', 'role': 'Farmer', 'time': '4h ago'},
    ];

    final posts = [
      {
        'title': 'First harvest of my hydroponic lettuce!',
        'content': 'Look at these vibrant colors 🌱 #UrbanFarming #Hydroponics',
        'hasImage': true,
        'likes': 245,
        'comments': 42,
        'shares': 12,
      },
      {
        'title': 'Tips for pest control this season',
        'content': 'Tips for pest control this season without harmful chemicals. Check out my new guide!',
        'hasImage': false,
        'likes': 89,
        'comments': 15,
        'shares': 8,
      },
      {
        'title': 'New greenhouse setup completed!',
        'content': 'Finally completed my greenhouse. Super excited to start growing vegetables!',
        'hasImage': true,
        'likes': 156,
        'comments': 28,
        'shares': 10,
      },
      {
        'title': 'Soil preparation tips',
        'content': 'Best practices for preparing your soil before planting season starts.',
        'hasImage': false,
        'likes': 120,
        'comments': 22,
        'shares': 9,
      },
      {
        'title': 'Composting guide for farmers',
        'content': 'Learn how to make your own compost at home and improve soil quality.',
        'hasImage': true,
        'likes': 198,
        'comments': 35,
        'shares': 14,
      },
    ];

    final user = users[index % users.length];
    final post = posts[index % posts.length];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal[300],
                      radius: 24,
                      child: Text(
                        user['name']![0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name']!,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${user['role']} • ${user['time']}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
              ],
            ),
            const SizedBox(height: 12),

            // Post Title
            Text(
              post['title']! as String,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Post Content
            Text(
              post['content']! as String,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            // Post Image (if available)
            if (post['hasImage'] == true)
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage('assets/images/ArgiPic.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            if (post['hasImage'] == true) const SizedBox(height: 12),

            // Engagement Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEngagementButton(
                  icon: Icons.favorite_outline,
                  count: post['likes']! as int,
                ),
                _buildEngagementButton(
                  icon: Icons.comment_outlined,
                  count: post['comments']! as int,
                ),
                _buildEngagementButton(
                  icon: Icons.share_outlined,
                  count: post['shares']! as int,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGardenCarousel() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _gardenPlantStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildGardenLoadingState();
        }
        if (snapshot.hasError) {
          return _buildGardenErrorState();
        }

        final plants = snapshot.data ?? <Map<String, dynamic>>[];
        if (plants.isEmpty) {
          return _buildGardenEmptyState();
        }

        var safeCurrentPage = _currentGardenPage;
        if (safeCurrentPage >= plants.length) {
          safeCurrentPage = 0;
        }
        if (_gardenPageNotifier.value != safeCurrentPage) {
          _gardenPageNotifier.value = safeCurrentPage;
        }
        if (_gardenCarouselController.hasClients &&
            _gardenCarouselController.page?.round() != safeCurrentPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_gardenCarouselController.hasClients) {
              _gardenCarouselController.jumpToPage(safeCurrentPage);
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ValueListenableBuilder<int>(
                valueListenable: _gardenPageNotifier,
                builder: (context, pageIndex, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Garden',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${pageIndex + 1}/${plants.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: 220,
              child: PageView.builder(
                key: const PageStorageKey<String>('my_garden_pageview'),
                controller: _gardenCarouselController,
                onPageChanged: (index) {
                  _currentGardenPage = index;
                  _gardenPageNotifier.value = index;
                },
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  final int totalDays = plant['totalDays'] as int;
                  final int daysPlanted = plant['daysPlanted'] as int;
                  final double progress = totalDays <= 0
                      ? 0.0
                      : (daysPlanted / totalDays).clamp(0.0, 1.0);
                  final int remainingDays = (totalDays - daysPlanted) < 0
                      ? 0
                      : (totalDays - daysPlanted);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (plant['color'] as Color).withOpacity(0.8),
                          plant['color'] as Color,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (plant['color'] as Color).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            plant['icon'] as IconData,
                            size: 150,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    plant['icon'] as IconData,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$daysPlanted days',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                plant['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                plant['scientificName'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Growth Progress',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.white.withOpacity(0.3),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$remainingDays days to harvest',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: ValueListenableBuilder<int>(
                  valueListenable: _gardenPageNotifier,
                  builder: (context, pageIndex, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        plants.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: pageIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: pageIndex == index
                                ? Colors.green[700]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _gardenPlantStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(<Map<String, dynamic>>[]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('plantations')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapGardenPlant(doc.data()))
              .toList(),
        );
  }

  Map<String, dynamic> _mapGardenPlant(Map<String, dynamic> data) {
    final String? rawName = data['name'] as String?;
    final String name = (rawName == null || rawName.trim().isEmpty)
        ? 'Unnamed Plant'
        : rawName.trim();
    final String scientificName = data['scientificName'] as String? ?? '';
    final int totalDays = _parsePositiveInt(data['totalDays'], fallback: 60);
    final int daysPlanted = _resolveDaysPlanted(data, totalDays);
    final Color color = _parseColor(data['color']) ?? const Color(0xFF2E7D32);
    final IconData icon = _iconFromName(data['icon'] as String?);

    return {
      'name': name,
      'scientificName': scientificName,
      'daysPlanted': daysPlanted,
      'totalDays': totalDays,
      'icon': icon,
      'color': color,
    };
  }

  int _parsePositiveInt(dynamic value, {required int fallback}) {
    if (value is num) {
      final int parsed = value.round();
      return parsed <= 0 ? fallback : parsed;
    }
    return fallback;
  }

  int _resolveDaysPlanted(Map<String, dynamic> data, int totalDays) {
    final dynamic daysValue = data['daysPlanted'];
    if (daysValue is num) {
      final int clamped = daysValue.round();
      if (clamped < 0) {
        return 0;
      }
      return clamped > totalDays ? totalDays : clamped;
    }

    final dynamic plantedAt = data['plantedAt'];
    if (plantedAt is Timestamp) {
      final int diffDays = DateTime.now().difference(plantedAt.toDate()).inDays;
      if (diffDays < 0) {
        return 0;
      }
      return diffDays > totalDays ? totalDays : diffDays;
    }

    return 0;
  }

  Color? _parseColor(dynamic value) {
    if (value is int) {
      return Color(value);
    }
    if (value is String) {
      var sanitized = value.trim();
      if (sanitized.startsWith('#')) {
        sanitized = sanitized.substring(1);
      }
      if (sanitized.startsWith('0x')) {
        sanitized = sanitized.substring(2);
      }
      if (sanitized.length == 6) {
        sanitized = 'FF$sanitized';
      }
      final int? colorInt = int.tryParse(sanitized, radix: 16);
      if (colorInt != null) {
        return Color(colorInt);
      }
    }
    return null;
  }

  IconData _iconFromName(String? name) {
    switch (name) {
      case 'circle':
      case 'tomato':
        return Icons.circle;
      case 'local_fire_department':
      case 'fire':
      case 'chili':
        return Icons.local_fire_department;
      case 'grass':
      case 'pandan':
        return Icons.grass;
      case 'spa':
      case 'papaya':
        return Icons.spa;
      case 'nature':
      case 'banana':
        return Icons.nature;
      case 'eco':
        return Icons.eco;
      case 'yard':
        return Icons.yard;
      default:
        return Icons.spa;
    }
  }

  Widget _buildGardenEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8F5E9),
            Color(0xFFC8E6C9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFAED581)),
      ),
      child: Column(
        children: [
          const Icon(Icons.yard_outlined, size: 48, color: Color(0xFF2E7D32)),
          const SizedBox(height: 12),
          const Text(
            'No plantations yet',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first plant to start tracking growth.',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlantingScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Plantation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenLoadingState() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      ),
    );
  }

  Widget _buildGardenErrorState() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: Color(0xFFD32F2F)),
          const SizedBox(height: 12),
          Text(
            'Unable to load your garden right now.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementButton({
    required IconData icon,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _WeatherData {
  const _WeatherData({
    required this.temperatureCelsius,
    required this.weatherCode,
  });

  final double temperatureCelsius;
  final int weatherCode;
}