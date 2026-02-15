import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PestDistributionMapScreen extends StatefulWidget {
  const PestDistributionMapScreen({super.key});

  @override
  State<PestDistributionMapScreen> createState() => _PestDistributionMapScreenState();
}

class _PestDistributionMapScreenState extends State<PestDistributionMapScreen> {
  final Stream<QuerySnapshot> _pestStream =
      FirebaseFirestore.instance.collection('pest_reports').snapshots();

  GoogleMapController? _mapController;

  // 1. DEFINE MALAYSIA BOUNDS
  // This box covers everything from Peninsular to Sabah/Sarawak
  static final CameraTargetBounds _malaysiaBounds = CameraTargetBounds(
    LatLngBounds(
      southwest: const LatLng(0.8, 99.6), // Near Singapore/Indonesia
      northeast: const LatLng(7.5, 119.3), // Tip of Sabah
    ),
  );

  // Default view centered on Malaysia
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(4.2105, 101.9758), 
    zoom: 6,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pest Distribution Map')),
      body: Column(
        children: [
          // --- SECTION 1: Pest Alerts List (Unchanged) ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Pest Alerts in Malaysia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200, 
                  child: ListView(
                    children: [
                      _buildPestAlert('Fall Armyworm', 'Selangor, Perak', 'High', Colors.red, Icons.bug_report),
                      _buildPestAlert('Brown Planthopper', 'Kedah, Perlis', 'Medium', Colors.orange, Icons.pest_control),
                      _buildPestAlert('Citrus Leaf Miner', 'Johor, Pahang', 'Low', Colors.yellow, Icons.nature),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- SECTION 2: The Gradient Map ---
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect( 
                borderRadius: BorderRadius.circular(8),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _pestStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 2. BUILD THE GRADIENT CIRCLES
                    Set<Circle> circles = {};
                    
                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        try {
                          var data = doc.data() as Map<String, dynamic>;
                          GeoPoint? loc = data['location'];
                          
                          if (loc != null) {
                            LatLng center = LatLng(loc.latitude, loc.longitude);
                            String docId = doc.id;

                            // LAYER 1: Outer Green Circle (Safe Zone - 20km)
                            circles.add(Circle(
                              circleId: CircleId("${docId}_outer"),
                              center: center,
                              radius: 20000, 
                              strokeWidth: 0,
                              fillColor: Colors.green.withOpacity(0.3), 
                            ));

                            // LAYER 2: Middle Yellow Circle (Warning Zone - 10km)
                            circles.add(Circle(
                              circleId: CircleId("${docId}_middle"),
                              center: center,
                              radius: 10000, 
                              strokeWidth: 0,
                              fillColor: Colors.yellow.withOpacity(0.4), 
                            ));

                            // LAYER 3: Inner Red Circle (Outbreak Center - 5km)
                            circles.add(Circle(
                              circleId: CircleId("${docId}_inner"),
                              center: center,
                              radius: 5000, 
                              strokeWidth: 1,
                              strokeColor: Colors.red,
                              fillColor: Colors.red.withOpacity(0.6), 
                            ));
                          }
                        } catch (e) {
                          print("Error parsing: $e");
                        }
                      }
                    }

                    return GoogleMap(
                      initialCameraPosition: _initialPosition,
                      circles: circles,
                      
                      // 3. APPLY MALAYSIA CONSTRAINTS
                      cameraTargetBounds: _malaysiaBounds, 
                      minMaxZoomPreference: const MinMaxZoomPreference(5, 18), // Prevent zooming out to world view
                      
                      myLocationEnabled: true, 
                      myLocationButtonEnabled: true,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPestAlert(String name, String region, String severity, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(region),
        trailing: Chip(
          label: Text(severity),
          backgroundColor: color.withOpacity(0.2),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
