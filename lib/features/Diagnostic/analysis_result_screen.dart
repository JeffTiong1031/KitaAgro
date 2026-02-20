import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// 1. Import your new service
import 'package:kita_agro/core/services/pest_report_service.dart';

class AnalysisResultScreen extends StatefulWidget {
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
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  bool _isReporting = false;

  // Helper to extract the pest name from the AI text (Simple logic)
  String _extractPestName(String text) {
    // We look for the line starting with "## Diagnosis" or similar
    // This is a basic parser; you can make it smarter later.
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.contains("Diagnosis") || line.contains("##")) {
        return line.replaceAll("#", "").replaceAll("Diagnosis:", "").trim();
      }
    }
    return "Unknown Pest";
  }

  // The function to handle the button click
  void _handleReportOutbreak() async {
    setState(() {
      _isReporting = true;
    });

    try {
      final pestName = _extractPestName(widget.analysisText);
      final PestReportService _reportService = PestReportService();

      // Call the service we created in Phase 2
      await _reportService.reportPestOutbreak(
        pestName,
        "High",
      ); // Defaulting to High for now

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Outbreak Reported! location added to Heatmap."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to report: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isPestMode
              ? "Pest Analysis Result"
              : "Nutrient Analysis Result",
        ),
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
                    image: FileImage(widget.imageFile),
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

                    MarkdownBody(
                      data: widget.analysisText,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            h2: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            p: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                    ),
                  ],
                ),
              ),

              // --- SECTION 3: The Report Button (Only for Pests) ---
              if (widget.isPestMode) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: const Text(
                    "Is this a serious outbreak? Help other farmers by reporting it.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: ElevatedButton.icon(
                    onPressed: _isReporting ? null : _handleReportOutbreak,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isReporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.warning_amber_rounded),
                    label: Text(
                      _isReporting
                          ? "Reporting Location..."
                          : "REPORT OUTBREAK 🚨",
                    ),
                  ),
                ),
              ],

              // Back Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back to Scan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
