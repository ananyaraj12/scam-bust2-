import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:scam_burst/localization/translator.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/background_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Translator.load();
  
  // Request necessary permissions early
  await [Permission.notification, Permission.sms].request();
  await SystemAlertWindow.requestPermissions();

  // Initialize the background service
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

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen()
  ));
}