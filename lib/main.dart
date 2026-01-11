import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _requestAllPermissions();

  runApp(const ScamBurstApp());
}

Future<void> _requestAllPermissions() async {
  await [Permission.sms, Permission.notification].request();
}

class ScamBurstApp extends StatelessWidget {
  const ScamBurstApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scam Burst AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HomeScreen(),
    );
  }
}