import 'package:flutter/material.dart';
import '../utils/constants.dart';

class OverlayWidget extends StatelessWidget {
  final String scamContent;
  const OverlayWidget({super.key, required this.scamContent});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.danger.withOpacity(0.95),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_rounded, size: 120, color: Colors.white),
            const Text("🚨 SCAM DETECTED 🚨", 
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Warning: The message you just received is a known fraud attempt.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 30),
            _scamPreview(scamContent),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
              onPressed: () => Navigator.pop(context),
              child: Text("I UNDERSTAND", style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _scamPreview(String content) => Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
    child: Text(content, style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
  );
}
