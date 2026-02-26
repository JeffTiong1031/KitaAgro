import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// Make sure this import path matches your folder structure exactly!
import 'package:kita_agro/features/Diagnostic/analysis_result_screen.dart';
import 'package:kita_agro/core/services/gemini_api_service.dart';
import 'package:kita_agro/core/services/app_localizations.dart';

class ScanFeature extends StatefulWidget {
  const ScanFeature({super.key});

  @override
  State<ScanFeature> createState() => _ScanFeatureState();
}

class _ScanFeatureState extends State<ScanFeature> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  // Initialize the service with your API Key
  final GeminiApiService _apiService = GeminiApiService(
    'AIzaSyDPR3Y8gUYHKEqK8EuPyyXMouGLddBHb5E',
  );

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _processImageForAnalysis(
    File pickedFile,
    bool userWantsPestDetection,
  ) async {
    setState(() {
      _isAnalyzing = true;
    });

    String mode = userWantsPestDetection ? "pest" : "nutrient";

    // Get the current language code
    final langCode = LanguageServiceProvider.of(context).currentLanguage.code;

    // Call the API with language
    String? result = await _apiService.analyzeImage(
      pickedFile.path,
      mode,
      languageCode: langCode,
    );

    // 👉 SANITIZER 1: They wanted Pests, but AI gave Nutrients
    if (userWantsPestDetection && result != null) {
      final low = result.toLowerCase();
      if (low.contains('deficiency name') || low.contains('nutrient')) {
        result =
            '''**Pest Name:** None detected\n\n**Threat:** Low\n\n**Symptoms:** No visible pest symptoms\n\n**Solutions:** No treatment needed\n\n**Short Advice:** No pests found''';
      }
    } 
    // 👉 SANITIZER 2: They wanted Nutrients, but AI gave Pests (The new fix!)
    else if (!userWantsPestDetection && result != null) {
      final low = result.toLowerCase();
      if (low.contains('pest name') ||
          (!low.contains('deficiency name') && low.contains('pest'))) {
        result =
            '''**Deficiency Name:** None detected\n\n**Threat:** Low\n\n**Symptoms:** No visible nutrient deficiencies. Plant appears nutritionally healthy.\n\n**Solutions:** Maintain current care routine.\n\n**Short Advice:** Nutrition looks good.''';
      }
    }

    setState(() {
      _isAnalyzing = false;
    });

    if (result != null && mounted) {
      // If result starts with "Error", show a Snackbar instead of the new screen
      if (result.startsWith("Error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        // Success! Go to results.
        final String analysis = result;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              imageFile: pickedFile,
              analysisText: analysis,
              isPestMode: userWantsPestDetection,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.aiDiagnostics)),
      body: _isAnalyzing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 20),
                  Text(loc.analyzing),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedImage != null)
                    Image.file(
                      _selectedImage!,
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    )
                  else
                    const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo),
                        label: Text(loc.gallery),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: Text(loc.camera),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (_selectedImage != null) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () =>
                          _processImageForAnalysis(_selectedImage!, true),
                      child: Text(loc.identifyPests),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () =>
                          _processImageForAnalysis(_selectedImage!, false),
                      child: Text(loc.identifyNutrients),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
