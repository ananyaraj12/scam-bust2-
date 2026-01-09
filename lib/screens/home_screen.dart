import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/overlay_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Quick test trigger for the overlay
          await OverlayService.showScamOverlay('Test scam message detected — be careful.');
        },
        child: const Icon(Icons.play_arrow),
      ),
      appBar: AppBar(
        title: const Text("SCAM BURST PROTECT"),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 30),
            _buildNavigationGrid(context),
            const Spacer(),
            _buildSOSButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(Icons.shield, size: 80, color: AppColors.primary),
          const SizedBox(height: 15),
          Text("SYSTEM ACTIVE", 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const Text("Scanning for fraud in real-time", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context) {
    return Row(
      children: [
        _menuItem(context, "Scam Log", Icons.history, Colors.blue),
        const SizedBox(width: 15),
        _menuItem(context, "Safe List", Icons.verified_user, Colors.orange),
      ],
    );
  }

  Widget _menuItem(context, title, icon, color) => Expanded(
    child: Card(
      child: InkWell(
        onTap: () {}, // Navigate to specific screens
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildSOSButton() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: () {}, // Trigger emergency call
        icon: const Icon(Icons.phone_android, color: Colors.white),
        label: const Text("SOS: ALERT FAMILY", style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }
}