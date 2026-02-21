import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kita_agro/core/services/weather_service.dart';

class PestReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final WeatherService _weatherService = WeatherService();

  Future<void> reportPestOutbreak(String pestName, String severity) async {
    // 1. Get current GPS Location
    Position position = await _determinePosition();

    // 2. Fetch Live Wind Data for that location
    final windData = await _weatherService.getWindData(
      position.latitude, 
      position.longitude
    );

    // 3. Create the Data Package
    final report = {
      "pestName": pestName,
      "severity": severity, // e.g., "High", "Medium"
      "location": GeoPoint(position.latitude, position.longitude),
      "timestamp": FieldValue.serverTimestamp(),
      "windSpeed": windData['speed'],
      "windAngle": windData['deg'],
    };

    // 4. Save to Firebase
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
      if (permission == LocationPermission.denied)
        return Future.error('Location permissions are denied');
    }
    return await Geolocator.getCurrentPosition();
  }
}
