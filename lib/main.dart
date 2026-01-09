import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Import your files correctly
// Background service integration disabled during development.
import 'screens/home_screen.dart'; 

void main() async {
  // 1. Flutter engine initialize
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Sari permissions ek saath maango (Senior Citizens ke liye easy rahega)
  await _requestAllPermissions();

  // 3. Background Service configure aur start karo
  // Background service causes runtime crashes on some devices because
  // of foreground notification configuration. Disabled for now so the
  // app stays stable during development. Re-enable after implementing
  // a proper notification channel and icon.
  // await _initializeScamShield();

  runApp(const ScamBurstApp());
}

// Background service initialization was removed during development
// because foreground notification setup needs proper implementation.

// Permissions handling logic
Future<void> _requestAllPermissions() async {
  // SMS aur Notifications permission
  await [
    Permission.sms,
    Permission.notification,
  ].request();
}

class ScamBurstApp extends StatelessWidget {
  const ScamBurstApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scam Burst AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        // Font size thoda bada rakha hai Senior Citizens ke liye
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      home: const HomeScreen(), // Tumhara HomeScreen.dart wala widget
    );
  }
}