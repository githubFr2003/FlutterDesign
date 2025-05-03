import 'package:flutter/material.dart';
import 'package:flutter_activity/screens/auth/login_screen.dart';
import 'package:flutter_activity/utils/app_theme.dart'; // Import the theme


void main() {
  // WidgetsFlutterBinding.ensureInitialized(); // Needed for Firebase, etc.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: AppTheme.lightTheme, // Use the defined theme
      debugShowCheckedModeBanner: false, // Disable debug banner
      home: const LoginScreen(), 
    );
  }
}