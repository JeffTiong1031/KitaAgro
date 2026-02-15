import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import necessary screens
import 'features/auth/login_screen.dart';
import 'main_layout.dart'; 
import 'core/widgets/auth_wrapper.dart';

// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Reverted: Team convenience

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  // await dotenv.load(fileName: ".env"); // Reverted: Team convenience
  
  // Cleanly initialized Firebase without conflict markers
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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