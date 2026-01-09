import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// system_alert_window removed from runtime code here; replace with device-specific alerting as needed
import 'scam_processor.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  final processor = ScamProcessor();
  await processor.init();

  // The original app used an external SMS receiver package. To keep
  // analysis and builds working in this environment (and because the
  // package was unavailable on pub.dev), use a placeholder stream.
  // Replace this with a proper SMS listener (e.g., `telephony`) when
  // integrating on device.
  final Stream<String?> smsStream = const Stream.empty();

  smsStream.listen((String? body) async {
    if (body != null) {
      double score = await processor.checkScamProbability(body);

      if (score > 0.8) {
        _triggerAlert(body);
      }
    }
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

void _triggerAlert(String msg) {
  // Placeholder alert for environments where `system_alert_window` API
  // is not available (e.g., during analysis or unit tests).
  debugPrint('🚨 SCAM ALERT: $msg');
}