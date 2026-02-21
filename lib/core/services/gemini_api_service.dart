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
        return "Server Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Connection Error: $e";
    }
  }
}
