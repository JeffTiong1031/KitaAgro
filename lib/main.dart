import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import the Login Screen
import 'features/auth/login_screen'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      debugShowCheckedModeBanner: false, // Removes the "Debug" banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Forest Green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // START HERE: Send user to Login Screen first
      home: const LoginScreen(), 
    );
  } 
}