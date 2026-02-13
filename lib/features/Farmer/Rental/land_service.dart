import 'package:http/http.dart' as http;
import 'land_model.dart';

/// Service to fetch and parse land data from Google Sheets CSV
class LandService {
  static const String kLandCsvUrl =
      'https://docs.google.com/spreadsheets/d/e/2PACX-1vQCLpkeZkMDvEBZz4L9Qq8kSwAVAxKbUkANgyR5QLKiq82-wKyVxM35B_l925nkgIVkmBs8toWPXGAi/pub?output=csv';

  /// Fetches lands from Google Sheets CSV
  /// Skips the first row (header) and parses each subsequent row as a Land object
  Future<List<Land>> fetchLands() async {
    try {
      final response = await http.get(Uri.parse(kLandCsvUrl));

      if (response.statusCode == 200) {
        // Parse CSV manually
        final lines = response.body.split('\n');
        final List<List<dynamic>> rows = [];

        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          // Simple CSV parsing - split by comma
          final values = _parseCsvLine(line);
          rows.add(values);
        }

        // Skip header row (first row)
        if (rows.isEmpty) {
          return [];
        }

        final lands = rows
            .skip(1)
            .where((row) => row.isNotEmpty && row.length >= 9)
            .map((row) => Land.fromCsv(row))
            .toList();

        return lands;
      } else {
        throw Exception(
            'Failed to fetch lands: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching lands: $e');
    }
  }

  /// Helper method to parse a CSV line, handling quoted fields
  List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    String current = '';
    bool insideQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        insideQuotes = !insideQuotes;
      } else if (char == ',' && !insideQuotes) {
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }

    // Add the last field
    result.add(current.trim());
    return result;
  }
}