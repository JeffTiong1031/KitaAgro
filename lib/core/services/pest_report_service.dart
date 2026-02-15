import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class PestReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> reportPestOutbreak(String pestName, String severity) async {
    // 1. Get current GPS Location
    Position position = await _determinePosition();

    // 2. Create the Data Package
    final report = {
      "pestName": pestName,
      "severity": severity, // e.g., "High", "Medium"
      "location": GeoPoint(position.latitude, position.longitude),
      "timestamp": FieldValue.serverTimestamp(),
    };

    // 3. Save to Firebase
    await _db.collection('pest_reports').add(report);
  }

  // Standard generic permission helper for Geolocator
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    return await Geolocator.getCurrentPosition();
  }
}