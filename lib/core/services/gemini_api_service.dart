import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiApiService {
  final String apiKey;
  static DateTime? _quotaCooldownUntil;

  GeminiApiService(this.apiKey);

  bool get _isInQuotaCooldown {
    final until = _quotaCooldownUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  void _startQuotaCooldownFromBody(String responseBody) {
    final retrySeconds = _extractRetrySeconds(responseBody);
    final cooldownSeconds = retrySeconds > 0 ? retrySeconds : 60;
    _quotaCooldownUntil = DateTime.now().add(Duration(seconds: cooldownSeconds));
  }

  int _extractRetrySeconds(String responseBody) {
    final match = RegExp(r'Please retry in\s+([0-9]+(?:\.[0-9]+)?)s', caseSensitive: false)
        .firstMatch(responseBody);
    if (match == null) {
      return 0;
    }
    final value = double.tryParse(match.group(1) ?? '0') ?? 0;
    return value.ceil();
  }

  String _buildPhotoFallback(String mode) {
    if (mode.contains("pest")) {
      return '''
**Pest Name:** Unable to analyze now
**Symptoms:** AI quota is temporarily exceeded, so image diagnosis is paused.
**Solutions:** Retry after about one minute. Meanwhile, isolate affected leaves and avoid overwatering.

**Short Advice:** Retry soon; keep leaves dry.
''';
    }

    return '''
**Deficiency Name:** Unable to analyze now
**Symptoms:** AI quota is temporarily exceeded, so nutrient diagnosis is paused.
**Solutions:** Retry after about one minute. Meanwhile, check soil moisture and use balanced fertilizer carefully.

**Short Advice:** Retry soon; monitor leaf color.
''';
  }

  Future<String?> analyzeImage(String imagePath, String mode) async {
    if (_isInQuotaCooldown) {
      return _buildPhotoFallback(mode);
    }

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
      prompt = '''Analyze this plant image for pests or diseases. 
Provide a detailed, highly informative analysis using Markdown formatting (bullet points, bold text, paragraphs).
You MUST include these exact headers:
**Pest Name:** [Insert exact pest or disease name]
**Symptoms:** [Provide detailed symptoms]
**Solutions:** [Provide detailed treatment steps]

At the VERY END of your response, on a new line, you MUST add this exact text:
**Short Advice:** [Insert exactly ONE short sentence (max 10 words) of advice for a mobile push notification]''';
    } else {
      prompt = '''Analyze this plant image for nutrient deficiencies. 
Provide a detailed, highly informative analysis using Markdown formatting (bullet points, bold text, paragraphs).
You MUST include these exact headers:
**Deficiency Name:** [Insert exact nutrient deficiency]
**Symptoms:** [Provide detailed symptoms]
**Solutions:** [Provide detailed fertilizer recommendations]

At the VERY END of your response, on a new line, you MUST add this exact text:
**Short Advice:** [Insert exactly ONE short sentence (max 10 words) of advice for a mobile push notification]''';
    }

    // 3. Build the JSON Body
    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
            },
          ],
        },
      ],
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
        return jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            "Error: No text in response.";
      } else {
        if (response.statusCode == 429) {
          _startQuotaCooldownFromBody(response.body);
          return _buildPhotoFallback(mode);
        }
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
Growing conditions for $plantName ($scientificName) in $location. Temp: $temperature°C, Weather: $weatherCondition, Category: $category.

Return ONLY valid JSON with these fields (be VERY concise, max 8 words per field):
{
  "localMatchScore": <0-100>,
  "growingContext": "<suitable or not, 1 short sentence>",
  "growthTime": "<e.g. 60-75 days>",
  "difficulty": "<e.g. Easy - tropical>",
  "sunlight": "<e.g. Full sun 6-8 hours>",
  "watering": "<e.g. Water daily in heat>",
  "soil": "<e.g. Well-drained loamy soil>",
  "carbonReduction": "<1 short phrase about CO2 benefit>",
  "materialsNeeded": [{"item": "<material name>", "purpose": "<3-5 words>"}],
  "growthStages": [{"stage": "<name>", "startDay": <int>, "endDay": <int>, "description": "<under 6 words>"}]
}

Rules:
- materialsNeeded: 4-8 essential items (seeds, fertilizer, tools, pots, etc.).
- growthStages: 4-7 contiguous stages from day 1 to total growth days.
- ALL text fields: max 8 words. Be direct.
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
        "maxOutputTokens": 2048,
      }
    };

    try {
      print('📡 Sending request to Gemini API...');
      print('🌿 Plant: ${plantName} | 📍 Location: ${location} | 🌡️ Temp: ${temperature}°C');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          final text = jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'];
          
          if (text == null) {
            print('⚠️ No text in Gemini response');
            print('📊 Full response structure: ${jsonResponse.toString()}');
            return null;
          }

          print('📝 Raw AI response length: ${text.length} characters');
          print('📝 First 300 chars: ${text.substring(0, text.length > 300 ? 300 : text.length)}');

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

          print('🔍 Extracted JSON length: ${jsonText.length} characters');

          // Parse the AI response
          final aiData = jsonDecode(jsonText);
          
          print('✅ Successfully parsed AI data');
          print('🎯 Match Score: ${aiData['localMatchScore']}');
          print('📖 Growth Time: ${aiData['growthTime']}');
          print('💪 Difficulty: ${aiData['difficulty']}');
          
          // Return ONLY what AI provides - no defaults, no fallbacks
          return {
            'localMatchScore': aiData['localMatchScore'],
            'growingContext': aiData['growingContext'],
            'growthTime': aiData['growthTime'],
            'difficulty': aiData['difficulty'],
            'sunlight': aiData['sunlight'],
            'watering': aiData['watering'],
            'soil': aiData['soil'],
            'carbonReduction': aiData['carbonReduction'],
            'materialsNeeded': aiData['materialsNeeded'],
            'growthStages': aiData['growthStages'],
          };
        } catch (parseError) {
          print('❌ JSON parsing error: $parseError');
          print('📊 Failed to parse text: ${response.body}');
          return null;
        }
      } else {
        print('❌ Gemini API Error ${response.statusCode}');
        print('📋 Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ AI Advice Error: $e');
      return null;
    }
  }
  /// Generate today's suggested tasks for a specific plant based on its growth stage
  Future<List<Map<String, String>>?> generateDailyTasks({
    required String plantName,
    required String scientificName,
    required String category,
    required int daysPlanted,
    required int totalDays,
    required String location,
    required double temperature,
    required String weatherCondition,
  }) async {
    final String urlString =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';

    final Uri url = Uri.parse(urlString);

    final String prompt = '''
You are a smart farming assistant. Generate 3-5 practical daily tasks for TODAY for a user growing $plantName ($scientificName).

Context:
- Category: $category
- Day $daysPlanted of $totalDays total growing days
- Location: $location
- Temperature: $temperature°C
- Weather: $weatherCondition

Respond ONLY with a valid JSON array. Each task object has "task" (under 10 words) and "icon" (one of: water, sun, fertilizer, prune, inspect, harvest, protect, soil).

Example: [{"task":"Water in the morning","icon":"water"},{"task":"Check for pests","icon":"inspect"}]

Keep it SHORT. Return ONLY the JSON array.
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
        "temperature": 0.8,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 2048,
      }
    };

    try {
      print('📋 Generating daily tasks for $plantName (day $daysPlanted/$totalDays)...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          final text = jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'];

          if (text == null) return null;

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

          // Try to repair truncated JSON — close unclosed array
          if (!jsonText.endsWith(']')) {
            // Find last complete object (ends with })
            final lastBrace = jsonText.lastIndexOf('}');
            if (lastBrace > 0) {
              jsonText = '${jsonText.substring(0, lastBrace + 1)}]';
            } else {
              print('❌ Could not repair truncated JSON');
              return null;
            }
          }

          final List<dynamic> tasks = jsonDecode(jsonText);
          print('✅ Generated ${tasks.length} daily tasks');
          return tasks
              .where((t) => t is Map && t['task'] != null)
              .map<Map<String, String>>((t) => {
                    'task': (t['task'] as String?) ?? '',
                    'icon': (t['icon'] as String?) ?? 'inspect',
                  })
              .toList();
        } catch (parseError) {
          print('❌ Task parsing error: $parseError');
          return null;
        }
      } else {
        print('❌ Task API Error ${response.statusCode}');
        if (response.statusCode == 429) {
          throw Exception('API limit reached. Please try again later.');
        }
        return null;
      }
    } catch (e) {
      print('❌ Task generation error: $e');
      if (e.toString().contains('API limit reached')) throw e;
      return null;
    }
  }

  /// Analyze a plant photo and return a diagnosis + concise task suggestions
  Future<Map<String, dynamic>?> analyzeAndSuggestTasks({
    required String imagePath,
    required String plantName,
    required int daysPlanted,
    required int totalDays,
  }) async {
    final String urlString =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';

    final Uri url = Uri.parse(urlString);

    final File imageFile = File(imagePath);
    if (!await imageFile.exists()) return null;
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final String prompt = '''
You are a plant doctor. Analyze the photo of this $plantName (day $daysPlanted of $totalDays).

Return ONLY valid JSON:
{
  "status": "<Healthy / Needs Attention / Critical>",
  "diagnosis": "<1 sentence, max 15 words, what you see>",
  "tasks": [{"task":"<under 10 words>","icon":"<water|sun|fertilizer|prune|inspect|harvest|protect|soil>"}]
}

Rules:
- Give 2-4 tasks based on what you SEE in the photo.
- Be specific to the visual condition (yellowing, wilting, pests, healthy growth, etc.).
- Return ONLY the JSON.
''';

    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image,
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "maxOutputTokens": 2048,
      }
    };

    try {
      print('📸 Analyzing plant photo for $plantName...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          final text = jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'];
          if (text == null) return null;

          String jsonText = text.trim();
          if (jsonText.startsWith('```json')) jsonText = jsonText.substring(7);
          else if (jsonText.startsWith('```')) jsonText = jsonText.substring(3);
          if (jsonText.endsWith('```')) jsonText = jsonText.substring(0, jsonText.length - 3);
          jsonText = jsonText.trim();

          final data = jsonDecode(jsonText) as Map<String, dynamic>;
          print('✅ Photo analysis: ${data['status']}');
          return data;
        } catch (parseError) {
          print('❌ Photo analysis parse error: $parseError');
          return null;
        }
      } else {
        print('❌ Photo analysis API error: ${response.statusCode}');
        if (response.statusCode == 429) {
          throw Exception('API limit reached. Please try again later.');
        }
        return null;
      }
    } catch (e) {
      print('❌ Photo analysis error: $e');
      if (e.toString().contains('API limit reached')) throw e;
      return null;
    }
  }
}