import 'package:flutter/material.dart';
import 'land_model.dart';
import 'land_service.dart';

class LandListingScreen extends StatefulWidget {
  const LandListingScreen({super.key});

  @override
  State<LandListingScreen> createState() => _LandListingScreenState();
}

class _LandListingScreenState extends State<LandListingScreen> {
  final LandService _landService = LandService();
  List<Land> _allLands = [];
  List<Land> _filteredLands = [];

  // Filter states
  String _searchText = '';
  String _selectedState = 'All States';
  String _selectedPrice = 'Any Price';
  String _selectedSize = 'All';

  List<String> _states = ['All States'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLands();
  }

  /// Load lands from Google Sheets
  Future<void> _loadLands() async {
    try {
      final lands = await _landService.fetchLands();
      setState(() {
        _allLands = lands;
        _extractStates();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lands: $e')),
        );
      }
    }
  }

  /// Extract unique states from lands data
  void _extractStates() {
    final states = _allLands.map((land) => land.state).toSet().toList();
    states.sort();
    _states = ['All States', ...states];
  }

  /// Apply all filters: search + state + price + size
  void _applyFilters() {
    _filteredLands = _allLands.where((land) {
      // Search filter (title OR location)
      final searchMatch = _searchText.isEmpty ||
          land.title.toLowerCase().contains(_searchText.toLowerCase()) ||
          land.location.toLowerCase().contains(_searchText.toLowerCase());

      // State filter
      final stateMatch =
          _selectedState == 'All States' || land.state == _selectedState;

      // Price filter
      bool priceMatch = true;
      switch (_selectedPrice) {
        case 'Budget (< RM 1,000)':
          priceMatch = land.price < 1000;
          break;
        case 'Standard (RM 1,000 - 3,000)':
          priceMatch = land.price >= 1000 && land.price <= 3000;
          break;
        case 'Premium (> RM 3,000)':
          priceMatch = land.price > 3000;
          break;
        default:
          priceMatch = true;
      }

      // Size filter
      bool sizeMatch = true;
      switch (_selectedSize) {
        case 'Small (< 1 Acre)':
          sizeMatch = land.sizeValue < 1;
          break;
        case 'Medium (1-5 Acres)':
          sizeMatch = land.sizeValue >= 1 && land.sizeValue <= 5;
          break;
        case 'Large (> 5 Acres)':
          sizeMatch = land.sizeValue > 5;
          break;
        default:
          sizeMatch = true;
      }

      return searchMatch && stateMatch && priceMatch && sizeMatch;
    }).toList();
  }

  /// Handle search text changes
  void _onSearchChanged(String value) {
    setState(() {
      _searchText = value;
      _applyFilters();
    });
  }

  /// Handle state/location filter changes
  void _onStateChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedState = value;
        _applyFilters();
      });
    }
  }

  /// Handle price range filter changes
  void _onPriceChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedPrice = value;
        _applyFilters();
      });
    }
  }

  /// Handle size filter changes
  void _onSizeSelected(String size) {
    setState(() {
      _selectedSize = size;
      _applyFilters();
    });
  }

  /// Show contact dialog with owner phone
  void _showContactDialog(String ownerPhone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Owner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact owner for further information',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Owner Phone Number:'),
            const SizedBox(height: 12),
            Text(
              ownerPhone,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Land Rental'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by title or location...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Filters Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // State and Price Dropdowns
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedState,
                              isExpanded: true,
                              onChanged: _onStateChanged,
                              items: _states.map((state) {
                                return DropdownMenuItem(
                                  value: state,
                                  child: Text(state),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedPrice,
                              isExpanded: true,
                              onChanged: _onPriceChanged,
                              items: [
                                'Any Price',
                                'Budget (< RM 1,000)',
                                'Standard (RM 1,000 - 3,000)',
                                'Premium (> RM 3,000)',
                              ]
                                  .map((price) {
                                    return DropdownMenuItem(
                                      value: price,
                                      child: Text(price),
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Size Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'All',
                            'Small (< 1 Acre)',
                            'Medium (1-5 Acres)',
                            'Large (> 5 Acres)',
                          ]
                              .map((size) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ChoiceChip(
                                    label: Text(size),
                                    selected: _selectedSize == size,
                                    onSelected: (_) => _onSizeSelected(size),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Land List
                Expanded(
                  child: _filteredLands.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No lands found',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredLands.length,
                          itemBuilder: (ctx, index) {
                            final land = _filteredLands[index];
                            return _buildLandCard(land);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  /// Build individual land card
  Widget _buildLandCard(Land land) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Section: Image with "For Rent" Badge
          Stack(
            children: [
              // Land Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  land.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              // "For Rent" Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'For Rent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Middle Section: Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Price & Size Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      'RM ${land.price.toStringAsFixed(0)} /mo',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    // Size Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        land.sizeDisplay,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Row 2: Title
                Text(
                  land.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Row 3: Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${land.location}, ${land.state}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Section: Contact Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => _showContactDialog(land.ownerPhone),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Contact Owner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
}