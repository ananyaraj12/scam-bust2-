import 'dart:async';
import 'package:flutter/services.dart';

class NotificationListenerService {
  static const EventChannel _eventChannel =
      EventChannel('com.example.scam_burst/notifications');

  static const MethodChannel _methodChannel =
      MethodChannel('com.example.scam_burst/notifications_method');

  /// 🔥 STATIC stream (this fixes your error)
  static Stream<Map<String, dynamic>> get notifications {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }

  /// Open notification access settings
  static Future<void> openNotificationSettings() async {
    await _methodChannel.invokeMethod('openNotificationSettings');
  }
}
