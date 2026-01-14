import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'services/background_service.dart';
import 'services/notification_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Step 1: Input & Preprocessing - Request necessary permissions [cite: 24]
  await [Permission.notification, Permission.sms].request();
  await SystemAlertWindow.requestPermissions();

  // 2. Initialize the background service (The Agent Controller bridge) [cite: 13]
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'scam_shield_v3',
      initialNotificationTitle: 'Scam Burst Active',
      initialNotificationContent: 'Monitoring for fraud intent...',
    ),
    iosConfiguration: IosConfiguration(),
  );

  runApp(const MaterialApp(home: ScamBurstApp()));
}

class ScamBurstApp extends StatefulWidget {
  const ScamBurstApp({super.key});

  @override
  State<ScamBurstApp> createState() => _ScamBurstAppState();
}

class _ScamBurstAppState extends State<ScamBurstApp> {
  late StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _setupServiceListeners();
    _setupNotificationListener();
  }

  // 3. Setup the Notification Listener to capture incoming notifications
  void _setupNotificationListener() {
    _notificationSubscription = NotificationListenerService.notifications.listen((event) {
      // Send the captured notification text to the background service for FastAPI analysis
      try {
        if (event['text'] != null && event['text']!.isNotEmpty) {
          print('[Main] Notification received: ${event['text']}');
          FlutterBackgroundService().invoke('analyze_notification', {
            "message": event['text'],
          });
        }
      } catch (e) {
        print('[Main] Error handling notification: $e');
      }
    }, onError: (error) {
      print('[Main] Notification stream error: $error');
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // 4. Step 4: Structured Delivery - Listen for the "Action" request from the Agent [cite: 29]
  void _setupServiceListeners() {
    FlutterBackgroundService().on('show_scam_alert').listen((event) {
      final String message = event?['message'] ?? "Unknown Threat";
      _showRedAlertOverlay(message);
    });
  }

  // UI Component: The Interactive Action Card [cite: 33]
  void _showRedAlertOverlay(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🚨 SCAM DETECTED"),
        content: Text("Risk Message: $msg"),
        backgroundColor: Colors.red.shade900,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        contentTextStyle: const TextStyle(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scam Burst AI"), backgroundColor: Colors.red),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 100, color: Colors.green),
            const Text("Agentic Shield is Monitoring Notifications"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Open notification access settings
                NotificationListenerService.openNotificationSettings();
              },
              child: const Text("Check Notification Access"),
            ),
          ],
        ),
      ),
    );
  }
}