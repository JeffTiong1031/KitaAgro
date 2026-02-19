import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiApiService {
  final String apiKey;

  GeminiApiService(this.apiKey);

  Future<String?> analyzeImage(String imagePath, String mode) async {
    // ⚠️ FIX: We found "gemini-2.5-flash" in your browser JSON list.
    // We must use that EXACT name.
    final String urlString = 
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';
    
    final Uri url = Uri.parse(urlString);

    // 1. Prepare the Image
    final File imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      return "Error: Image file not found.";
    }
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // 2. Set the Prompt
    String prompt;
    if (mode.contains("pest")) {
      prompt = "Analyze this plant image. Identify any pest or disease. Format output in Markdown with Diagnosis, Symptoms, and Solutions.";
    } else {
      prompt = "Analyze this plant image. Identify nutrient deficiencies. Format output in Markdown with Diagnosis, Symptoms, and Fertilizer Recommendations.";
    }

    // 3. Build the JSON Body
    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ]
    };

    // 4. Send Request
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? "Error: No text in response.";
      } else {
        return "Server Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Connection Error: $e";
    }
  }

  /// Generate location-aware plant growing advice using Gemini AI
  /// Returns a map with: localScore, growingContext, todayTasks, carbonReduction
  Future<Map<String, dynamic>?> getLocalizedAdvice({
    required String plantName,
    required String scientificName,
    required String category,
    required String location,
    required double temperature,
    required String weatherCondition,
  }) async {
    final String urlString = 
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';
    
    final Uri url = Uri.parse(urlString);

    // Build comprehensive prompt for location-aware advice
    final String prompt = '''
Analyze growing conditions for $plantName ($scientificName) in $location.

Current conditions:
- Temperature: $temperature°C
- Weather: $weatherCondition
- Location: $location
- Category: $category

Provide ONLY a valid JSON response with exactly these 4 fields:
{
  "localMatchScore": <integer 0-100 representing how well this plant matches local climate>,
  "growingContext": "<2-3 sentences about how local $location climate (humidity, rainfall, temperature) specifically affects this plant. Be specific about the location. Example: 'In Kluang's humid tropical climate, this plant thrives with 15% faster growth due to consistent rainfall patterns.'>",
  "growingTips": {
    "sunlight": "<Location-specific sunlight advice. Example: 'In your tropical climate, provide 6 hours morning sun to avoid afternoon heat stress.'>",
    "watering": "<Location-specific watering advice based on current $weatherCondition. Example: 'During rainy season, reduce watering to twice weekly.'>",
    "soil": "<Location-specific soil recommendation. Example: 'Add more drainage in $location due to high rainfall.'>"
  },
  "carbonReduction": "<1 sentence calculating CO2 reduction. Example: 'Growing this saves approximately 2.3 kg CO2/month compared to store-bought produce.'>"
}

Keep responses concise and actionable. Focus on $location-specific advice.
''';

    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 1024,
      }
    };

    try {
      print('📡 Sending request to Gemini API...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final text = jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (text == null) {
          print('⚠️ No text in Gemini response');
          return null;
        }

        print('📝 Raw AI response: ${text.substring(0, text.length > 200 ? 200 : text.length)}...');

        // Extract JSON from response (handle markdown code blocks)
        String jsonText = text.trim();
        if (jsonText.startsWith('```json')) {
          jsonText = jsonText.substring(7);
        } else if (jsonText.startsWith('```')) {
          jsonText = jsonText.substring(3);
        }
        if (jsonText.endsWith('```')) {
          jsonText = jsonText.substring(0, jsonText.length - 3);
        }
        jsonText = jsonText.trim();

        print('🔍 Parsing JSON...');
        // Parse the AI response
        final aiData = jsonDecode(jsonText);
        final growingTipsData = aiData['growingTips'] as Map<String, dynamic>?;
        
        print('✅ Successfully parsed AI data');
        return {
          'localMatchScore': aiData['localMatchScore'] ?? 75,
          'growingContext': aiData['growingContext'] ?? 'This plant adapts well to local conditions.',
          'growingTips': {
            'sunlight': growingTipsData?['sunlight'] ?? 'Provide adequate sunlight as needed.',
            'watering': growingTipsData?['watering'] ?? 'Water regularly.',
            'soil': growingTipsData?['soil'] ?? 'Use well-draining soil.',
          },
          'carbonReduction': aiData['carbonReduction'] ?? 
              'Growing this plant helps reduce your carbon footprint.',
        };
      } else {
        print('❌ Gemini API Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ AI Advice Error: $e');
      return null;
    }
  }
}