import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import necessary screens
import 'core/widgets/auth_wrapper.dart';

// 👉 NEW: Import the Pest Alert Service. 
// (Note: Adjust this path if you saved pest_alert_service.dart inside a specific folder like 'core/services/')
import 'core/services/pest_alert_service.dart'; 

// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Reverted: Team convenience

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // await dotenv.load(fileName: ".env"); // Reverted: Team convenience

  // Cleanly initialized Firebase without conflict markers
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 👉 NEW: Start the Alert Engine to listen for new pest reports globally
  final pestAlertService = PestAlertService();
  await pestAlertService.initialize();

  runApp(const KitaAgroApp());
}

class KitaAgroApp extends StatelessWidget {
  const KitaAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kita Agro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Forest Green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // 4. The Magic Switcher
      home: const AuthWrapper(),
    );
  }
}
