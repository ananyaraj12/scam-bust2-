import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ScamBurstApp());
}

class ScamBurstApp extends StatelessWidget {
  const ScamBurstApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
