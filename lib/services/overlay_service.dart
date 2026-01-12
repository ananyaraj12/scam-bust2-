import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class OverlayService {
  static const MethodChannel _channel = MethodChannel('scam_overlay');

  /// Request SYSTEM_ALERT_WINDOW permission
  static Future<bool> requestOverlayPermission() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.systemAlertWindow.status;
    if (status.isGranted) return true;

    final result = await Permission.systemAlertWindow.request();
    if (result.isGranted) return true;

    // If permission not granted, open system overlay settings so user can grant manually
    try {
      const MethodChannel('scam_overlay').invokeMethod('openOverlaySettings');
    } catch (e) {
      print('Could not open overlay settings: $e');
    }

    return false;
  }

  /// Show native Android overlay (Truecaller-style)
  static Future<void> showScamOverlay(String message) async {
    try {
      // Try to start native overlay; native will return false if permission missing
      final res = await _channel.invokeMethod<bool>('showOverlay', {
        'msg': message,
      });

      if (res != true) {
        print('Native overlay refused (permission?). Opening settings.');
        await requestOverlayPermission();
      }
    } catch (e) {
      print('Native overlay error: $e');
    }
  }
}
