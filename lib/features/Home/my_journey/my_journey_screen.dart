import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MyJourneyScreen extends StatefulWidget {
  const MyJourneyScreen({super.key});

  @override
  State<MyJourneyScreen> createState() => _MyJourneyScreenState();
}

class _MyJourneyScreenState extends State<MyJourneyScreen> {
  static const String _googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  String _sortBy = 'name'; // 'name', 'daysPlanted', 'health'
  bool _gardenLocationLoading = false;
  String? _gardenAddress;
  double? _gardenLatitude;
  double? _gardenLongitude;
  String? _gardenPlaceId;

  @override
  void initState() {
    super.initState();
    _loadGardenLocation();
  }

  DocumentReference<Map<String, dynamic>>? _userDocRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  Future<void> _loadGardenLocation() async {
    final userDocRef = _userDocRef();
    if (userDocRef == null) {
      return;
    }

    setState(() {
      _gardenLocationLoading = true;
    });

    try {
      final snapshot = await userDocRef.get();
      final data = snapshot.data();
      final location = data?['gardenLocation'] as Map<String, dynamic>?;

      if (!mounted) {
        return;
      }

      if (location != null) {
        setState(() {
          _gardenAddress = location['address'] as String?;
          _gardenLatitude = (location['latitude'] as num?)?.toDouble();
          _gardenLongitude = (location['longitude'] as num?)?.toDouble();
          _gardenPlaceId = location['placeId'] as String?;
          _gardenLocationLoading = false;
        });
      } else {
        setState(() {
          _gardenAddress = null;
          _gardenLatitude = null;
          _gardenLongitude = null;
          _gardenPlaceId = null;
          _gardenLocationLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _gardenLocationLoading = false;
      });
    }
  }

  Future<void> _setGardenLocation() async {
    final userDocRef = _userDocRef();
    if (userDocRef == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to save garden location.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final result = await Navigator.push<_GardenLocationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => _GardenLocationPickerScreen(
          apiKey: _googleMapsApiKey,
          initialLatitude: _gardenLatitude,
          initialLongitude: _gardenLongitude,
          initialAddress: _gardenAddress,
        ),
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _gardenLocationLoading = true;
    });

    try {
      await userDocRef.set(
        {
          'gardenLocation': {
            'latitude': result.latitude,
            'longitude': result.longitude,
            'address': result.address,
            'placeId': result.placeId,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        },
        SetOptions(merge: true),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _gardenLatitude = result.latitude;
        _gardenLongitude = result.longitude;
        _gardenAddress = result.address;
        _gardenPlaceId = result.placeId;
        _gardenLocationLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Garden location saved successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _gardenLocationLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save garden location: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildGardenLocationCard() {
    final hasLocation = _gardenLatitude != null && _gardenLongitude != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'My Garden Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              if (_gardenLocationLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasLocation
                ? (_gardenAddress ??
                      'Lat: ${_gardenLatitude!.toStringAsFixed(5)}, Lng: ${_gardenLongitude!.toStringAsFixed(5)}')
                : 'Set your garden location to get localized suggestions and weather context.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          if (hasLocation) ...[
            const SizedBox(height: 6),
            Text(
              'Lat: ${_gardenLatitude!.toStringAsFixed(5)}, Lng: ${_gardenLongitude!.toStringAsFixed(5)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _gardenLocationLoading ? null : _setGardenLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.edit_location_alt),
                label: Text(hasLocation ? 'Edit Location' : 'Set Location'),
              ),
              const SizedBox(width: 10),
              if (_googleMapsApiKey.isEmpty)
                Expanded(
                  child: Text(
                    'Tip: pass --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY for Places search.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

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
          _buildGardenLocationCard(),
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

class _GardenLocationResult {
  const _GardenLocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.placeId,
  });

  final double latitude;
  final double longitude;
  final String address;
  final String? placeId;
}

class _GardenLocationPickerScreen extends StatefulWidget {
  const _GardenLocationPickerScreen({
    required this.apiKey,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  final String apiKey;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  @override
  State<_GardenLocationPickerScreen> createState() => _GardenLocationPickerScreenState();
}

class _GardenLocationPickerScreenState extends State<_GardenLocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();

  GoogleMapController? _mapController;
  List<_PlaceSuggestion> _suggestions = [];
  bool _searching = false;
  bool _resolvingAddress = false;
  String? _selectedAddress;
  String? _selectedPlaceId;
  LatLng _selectedPoint = const LatLng(3.1390, 101.6869);

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedPoint = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _selectedAddress = widget.initialAddress;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location services.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final target = LatLng(position.latitude, position.longitude);

    setState(() {
      _selectedPoint = target;
      _selectedPlaceId = null;
      _resolvingAddress = true;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 16),
    );

    final address = await _reverseGeocode(target);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedAddress =
          address ?? 'Lat: ${target.latitude.toStringAsFixed(5)}, Lng: ${target.longitude.toStringAsFixed(5)}';
      _resolvingAddress = false;
    });
  }

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _selectedPoint = point;
      _selectedPlaceId = null;
      _resolvingAddress = true;
    });

    final address = await _reverseGeocode(point);

    if (!mounted) {
      return;
    }
    setState(() {
      _selectedAddress =
          address ?? 'Lat: ${point.latitude.toStringAsFixed(5)}, Lng: ${point.longitude.toStringAsFixed(5)}';
      _resolvingAddress = false;
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    if (widget.apiKey.isEmpty) {
      await _searchPlacesFallback(query);
      return;
    }

    setState(() {
      _searching = true;
    });

    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': query,
        'key': widget.apiKey,
      });
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        if (mounted) {
          setState(() {
            _searching = false;
            _suggestions = [];
          });
        }
        return;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final predictions = (payload['predictions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _suggestions = predictions
            .map(
              (item) => _PlaceSuggestion(
                placeId: (item['place_id'] as String?) ?? '',
                description: (item['description'] as String?) ?? '',
              ),
            )
            .where((item) => (item.placeId?.isNotEmpty ?? false) && item.description.isNotEmpty)
            .toList();
        _searching = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searching = false;
        _suggestions = [];
      });
    }
  }

  Future<void> _searchPlacesFallback(String query) async {
    setState(() {
      _searching = true;
    });

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5',
      );
      final response = await http.get(
        uri,
        headers: const {'User-Agent': 'KitaAgroApp/1.0'},
      );

      if (response.statusCode != 200) {
        if (!mounted) {
          return;
        }
        setState(() {
          _searching = false;
          _suggestions = [];
        });
        return;
      }

      final results = (jsonDecode(response.body) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _suggestions = results
            .map(
              (item) => _PlaceSuggestion(
                placeId: null,
                description: (item['display_name'] as String?) ?? '',
                latitude: double.tryParse(item['lat'] as String? ?? ''),
                longitude: double.tryParse(item['lon'] as String? ?? ''),
              ),
            )
            .where(
              (item) =>
                  item.description.isNotEmpty &&
                  item.latitude != null &&
                  item.longitude != null,
            )
            .toList();
        _searching = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searching = false;
        _suggestions = [];
      });
    }
  }

  Future<void> _selectSuggestion(_PlaceSuggestion suggestion) async {
    if (suggestion.latitude != null && suggestion.longitude != null) {
      final target = LatLng(suggestion.latitude!, suggestion.longitude!);
      setState(() {
        _selectedPoint = target;
        _selectedAddress = suggestion.description;
        _selectedPlaceId = suggestion.placeId;
        _suggestions = [];
        _resolvingAddress = false;
        _searching = false;
      });
      _searchController.text = suggestion.description;
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
      return;
    }

    if (widget.apiKey.isEmpty || suggestion.placeId == null) {
      return;
    }

    setState(() {
      _searching = true;
      _suggestions = [];
      _resolvingAddress = true;
    });

    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
        'place_id': suggestion.placeId!,
        'fields': 'geometry,formatted_address,place_id',
        'key': widget.apiKey,
      });
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        if (!mounted) {
          return;
        }
        setState(() {
          _searching = false;
          _resolvingAddress = false;
        });
        return;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final result = payload['result'] as Map<String, dynamic>?;
      final geometry = result?['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;

      final lat = (location?['lat'] as num?)?.toDouble();
      final lng = (location?['lng'] as num?)?.toDouble();
      final formattedAddress = result?['formatted_address'] as String?;

      if (lat == null || lng == null) {
        if (!mounted) {
          return;
        }
        setState(() {
          _searching = false;
          _resolvingAddress = false;
        });
        return;
      }

      final target = LatLng(lat, lng);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedPoint = target;
        _selectedAddress =
            formattedAddress ??
            'Lat: ${target.latitude.toStringAsFixed(5)}, Lng: ${target.longitude.toStringAsFixed(5)}';
        _selectedPlaceId = suggestion.placeId!;
        _searching = false;
        _resolvingAddress = false;
      });

      _searchController.text = suggestion.description;

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searching = false;
        _resolvingAddress = false;
      });
    }
  }

  Future<String?> _reverseGeocode(LatLng point) async {
    if (widget.apiKey.isEmpty) {
      try {
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}',
        );
        final response = await http.get(
          uri,
          headers: const {'User-Agent': 'KitaAgroApp/1.0'},
        );
        if (response.statusCode != 200) {
          return null;
        }
        final payload = jsonDecode(response.body) as Map<String, dynamic>;
        return payload['display_name'] as String?;
      } catch (_) {
        return null;
      }
    }
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '${point.latitude},${point.longitude}',
        'key': widget.apiKey,
      });
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return null;
      }
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (payload['results'] as List<dynamic>? ?? []);
      if (results.isEmpty) {
        return null;
      }
      final first = results.first as Map<String, dynamic>;
      return first['formatted_address'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackAddress =
        'Lat: ${_selectedPoint.latitude.toStringAsFixed(5)}, Lng: ${_selectedPoint.longitude.toStringAsFixed(5)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Garden Location'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: widget.apiKey.isEmpty
                          ? 'Search place or address (fallback mode)'
                          : 'Search place or address',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _searchPlaces,
                    onSubmitted: _searchPlaces,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _goToCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  tooltip: 'Use current location',
                ),
              ],
            ),
          ),
          if (_searching) const LinearProgressIndicator(minHeight: 2),
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(suggestion.description),
                    onTap: () => _selectSuggestion(suggestion),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedPoint,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: _onMapTap,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('garden_location'),
                  position: _selectedPoint,
                ),
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pin_drop, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedAddress ?? fallbackAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    if (_resolvingAddress)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context,
                        _GardenLocationResult(
                          latitude: _selectedPoint.latitude,
                          longitude: _selectedPoint.longitude,
                          address: _selectedAddress ?? fallbackAddress,
                          placeId: _selectedPlaceId,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Save Garden Location'),
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

class _PlaceSuggestion {
  const _PlaceSuggestion({
    required this.placeId,
    required this.description,
    this.latitude,
    this.longitude,
  });

  final String? placeId;
  final String description;
  final double? latitude;
  final double? longitude;
}
