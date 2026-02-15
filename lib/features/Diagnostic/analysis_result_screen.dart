import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Required for beautiful AI text

class AnalysisResultScreen extends StatelessWidget {
  // We replaced the generic 'Map result' with specific fields
  // so we can display the actual image and formatted text.
  final File imageFile;
  final String analysisText;
  final bool isPestMode;

  const AnalysisResultScreen({
    super.key,
    required this.imageFile,
    required this.analysisText,
    required this.isPestMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Dynamic title based on what the user selected
        title: Text(isPestMode ? "Pest Analysis Result" : "Nutrient Analysis Result"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SECTION 1: The Image ---
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: DecorationImage(
                    image: FileImage(imageFile),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // --- SECTION 2: The AI Analysis ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diagnosis Report:',
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 10),
                    
                    // MarkdownBody renders the AI's bold text and lists beautifully
                    MarkdownBody(
                      data: analysisText,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        h2: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18),
                        h3: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
                        p: const TextStyle(fontSize: 16, height: 1.5),
                        listBullet: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // --- SECTION 3: The Back Button ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Home'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}