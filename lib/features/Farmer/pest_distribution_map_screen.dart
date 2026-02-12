import 'package:flutter/material.dart';

class PestDistributionMapScreen extends StatelessWidget {
  const PestDistributionMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pest Distribution Map')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Pest Alerts in Malaysia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildPestAlert(
                  pestName: 'Fall Armyworm',
                  region: 'Selangor, Perak',
                  severity: 'High',
                  severityColor: Colors.red,
                  icon: Icons.bug_report,
                ),
                _buildPestAlert(
                  pestName: 'Brown Planthopper',
                  region: 'Kedah, Perlis',
                  severity: 'Medium',
                  severityColor: Colors.orange,
                  icon: Icons.pest_control,
                ),
                _buildPestAlert(
                  pestName: 'Citrus Leaf Miner',
                  region: 'Johor, Pahang',
                  severity: 'Low',
                  severityColor: Colors.yellow,
                  icon: Icons.nature,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Interactive Map Coming Soon',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.location_on),
                      label: const Text('Report Pest Sighting'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPestAlert({
    required String pestName,
    required String region,
    required String severity,
    required Color severityColor,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: severityColor, size: 32),
        title: Text(pestName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(region),
        trailing: Chip(
          label: Text(severity),
          backgroundColor: severityColor.withOpacity(0.3),
          labelStyle: TextStyle(color: severityColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
