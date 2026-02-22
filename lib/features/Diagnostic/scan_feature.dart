import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// Make sure this import path matches your folder structure exactly!
import 'package:kita_agro/features/Diagnostic/analysis_result_screen.dart';
import 'package:kita_agro/core/services/gemini_api_service.dart';

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
    'AIzaSyAONXuYRzzHalWMopx82Zalefaa2-w5lmU',
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

    // Call the API
    String? result = await _apiService.analyzeImage(pickedFile.path, mode);

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              imageFile: pickedFile,
              analysisText: result,
              isPestMode: userWantsPestDetection,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Diagnostics')),
      body: _isAnalyzing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 20),
                  Text("Agro AI is analyzing..."),
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
                        label: const Text('Gallery'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
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
                      child: const Text('Identify Pests 🐞'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () =>
                          _processImageForAnalysis(_selectedImage!, false),
                      child: const Text('Identify Nutrients 🍃'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
