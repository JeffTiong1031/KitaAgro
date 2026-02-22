import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:typed_data';

class PestDistributionMapScreen extends StatefulWidget {
  const PestDistributionMapScreen({super.key});

  @override
  State<PestDistributionMapScreen> createState() =>
      _PestDistributionMapScreenState();
}

class _PestDistributionMapScreenState extends State<PestDistributionMapScreen> {
  final Stream<QuerySnapshot> _pestStream = FirebaseFirestore.instance
      .collection('pest_reports')
      .snapshots();

  GoogleMapController? _mapController;
  bool _hasLocationPermission = false;

  static final CameraTargetBounds _malaysiaBounds = CameraTargetBounds(
    LatLngBounds(
      southwest: const LatLng(0.8, 99.6),
      northeast: const LatLng(7.5, 119.3),
    ),
  );

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(4.2105, 101.9758),
    zoom: 14,
  );

  // Store raw bytes instead of BitmapDescriptor to avoid the type mismatch
  Uint8List? customWindArrowBytes;

  @override
  void initState() {
    super.initState();
    _loadWindArrow();
    _requestPermissionOnLoad();
  }

  // The bulletproof image loader
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> _loadWindArrow() async {
    try {
      final Uint8List markerIcon = await getBytesFromAsset('assets/images/wind_arrow.png', 200);
      setState(() {
        customWindArrowBytes = markerIcon;
      });
    } catch (e) {
      print("Error loading custom arrow bytes: $e");
    }
  }

  Future<void> _requestPermissionOnLoad() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      if (mounted) {
        setState(() {
          _hasLocationPermission = true;
        });
      }
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (!_hasLocationPermission) return;
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error getting location for map: $e");
    }
  }

  // 👉 THE FIX: Adjusted the rotation math to spin Clockwise like a Map Compass!
  List<LatLng> _createWindEllipse(LatLng center, double radiusY, double radiusX, double windAngleDegrees) {
    List<LatLng> points = [];
    const double earthRadius = 6378137.0;
    final double radAngle = windAngleDegrees * (math.pi / 180);

    for (int i = 0; i <= 360; i += 10) {
      final double t = i * (math.pi / 180);
      final double x = radiusX * math.cos(t);
      final double y = radiusY * math.sin(t);
      
      // Clockwise rotation matrix to fix the crisscrossing shapes
      final double xRotated = x * math.cos(radAngle) + y * math.sin(radAngle);
      final double yRotated = -x * math.sin(radAngle) + y * math.cos(radAngle);
      
      final double dLat = yRotated / earthRadius;
      final double dLng = xRotated / (earthRadius * math.cos(math.pi * center.latitude / 180));
      points.add(LatLng(
          center.latitude + (dLat * 180 / math.pi),
          center.longitude + (dLng * 180 / math.pi)));
    }
    return points;
  }

  LatLng _calculateArrowPosition(LatLng center, double distanceInMeters, double bearingDegrees) {
    const double earthRadius = 6378137.0;
    final double radBearing = bearingDegrees * (math.pi / 180.0);
    final double dx = distanceInMeters * math.sin(radBearing);
    final double dy = distanceInMeters * math.cos(radBearing);
    final double dLat = dy / earthRadius;
    final double dLng = dx / (earthRadius * math.cos(center.latitude * math.pi / 180.0));
    return LatLng(
        center.latitude + (dLat * 180.0 / math.pi),
        center.longitude + (dLng * 180.0 / math.pi));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pest Distribution Map')),
      body: Column(
        children: [
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
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Network error.", style: TextStyle(color: Colors.red)),
                      );
                    }

                    Set<Polygon> polygons = {};
                    Set<Marker> markers = {};
                    Set<GroundOverlay> groundOverlays = {};

                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        try {
                          var data = doc.data() as Map<String, dynamic>;
                          GeoPoint? loc = data['location'];
                          num windSpeedNum = data['windSpeed'] ?? 0;
                          num windAngleNum = data['windAngle'] ?? 0;
                          double windSpeed = windSpeedNum.toDouble();
                          double windAngle = windAngleNum.toDouble();
                          String pestName = data['pestName'] ?? 'Unknown Pest';

                          if (loc != null) {
                            LatLng center = LatLng(loc.latitude, loc.longitude);
                            String docId = doc.id;
                            double windStretch = windSpeed * 20.0;

                            // 👉 THE FIX: Weather APIs say where wind comes FROM. 
                            // We flip it 180 degrees to show where pests are blowing TO.
                            double downwindAngle = (windAngle + 180) % 360;

                            // 1. Draw Polygons using downwindAngle
                            polygons.add(Polygon(
                              polygonId: PolygonId("${docId}_safe"),
                              points: _createWindEllipse(center, 500 + windStretch, 500, downwindAngle),
                              strokeWidth: 0,
                              fillColor: Colors.green.withOpacity(0.2),
                            ));
                            polygons.add(Polygon(
                              polygonId: PolygonId("${docId}_warning"),
                              points: _createWindEllipse(center, 200 + (windStretch * 0.5), 200, downwindAngle),
                              strokeWidth: 0,
                              fillColor: Colors.orange.withOpacity(0.5),
                            ));
                            polygons.add(Polygon(
                              polygonId: PolygonId("${docId}_danger"),
                              points: _createWindEllipse(center, 50 + (windStretch * 0.1), 50, downwindAngle),
                              strokeWidth: 0,
                              fillColor: Colors.red.withOpacity(0.8),
                            ));

                            // 2. Add Red Pin Marker
                            markers.add(Marker(
                              markerId: MarkerId("${docId}_pin"),
                              position: center,
                              infoWindow: InfoWindow(
                                title: '🚨 $pestName',
                                snippet: 'Reported Outbreak Center',
                              ),
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                            ));

                            // 3. Add Wind Arrow using downwindAngle
                            if (windSpeed > 0 && customWindArrowBytes != null) {
                              LatLng arrowPosition = _calculateArrowPosition(center, 300, downwindAngle);

                              groundOverlays.add(GroundOverlay.fromPosition(
                                groundOverlayId: GroundOverlayId("${docId}_arrow_overlay"),
                                image: BytesMapBitmap(
                                  customWindArrowBytes!,
                                  bitmapScaling: MapBitmapScaling.none, 
                                ), 
                                position: arrowPosition,
                                width: 600, 
                                bearing: downwindAngle, // Rotated properly to match the heatmap
                                anchor: const Offset(0.5, 0.5), 
                                transparency: 0.2, 
                                zIndex: 1, 
                              ));
                            }
                          }
                        } catch (e) {
                          print("Error parsing data: $e");
                        }
                      }
                    }

                    return GoogleMap(
                      initialCameraPosition: _initialPosition,
                      polygons: polygons,
                      markers: markers,
                      groundOverlays: groundOverlays,
                      cameraTargetBounds: _malaysiaBounds,
                      minMaxZoomPreference: const MinMaxZoomPreference(5, 18),
                      myLocationEnabled: _hasLocationPermission,
                      myLocationButtonEnabled: _hasLocationPermission,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _goToCurrentLocation();
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

  Widget _buildPestAlert(
    String name,
    String region,
    String severity,
    Color color,
    IconData icon,
  ) {
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
