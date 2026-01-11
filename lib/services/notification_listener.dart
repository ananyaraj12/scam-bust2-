import 'dart:async';
import 'package:flutter/services.dart';

class NotificationListenerService {
  static const EventChannel _eventChannel = EventChannel('com.example.scam_burst/notifications');
  static const MethodChannel _methodChannel = MethodChannel('com.example.scam_burst/notifications_method');

  static Stream<Map<String, dynamic>> get notifications {
    return _eventChannel.receiveBroadcastStream().map((event) {
      final map = Map<String, dynamic>.from(event as Map);
      return map;
    });
  }

  static Future<void> openNotificationSettings() async {
    await _methodChannel.invokeMethod('openNotificationSettings');
  }
}
