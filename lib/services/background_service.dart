import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // REQUIRED for Android Foreground Service
  // REQUIRED for Android Foreground Service
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();

    service.setForegroundNotificationInfo(
      title: "Scam Bust Active",
      content: "Monitoring notifications for scams...",
    );
  }

  // Keep service alive (small timer)
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      final isForeground = await service.isForegroundService();
      if (!isForeground) {
        service.setAsForegroundService();
      }
    }
  });

  // Receive message from UI isolate
  service.on("analyze_notification").listen((event) async {
    final message = (event?["message"] ?? "").toString();

    if (message.trim().isEmpty) return;

    // For now just show alert (demo)
    service.invoke("show_scam_alert", {
      "message": message,
    });
  });
}

// //
// // Background service runs in isolate; handles the Agent Workflow
// //import 'dart:ui';
// //import 'package:flutter/widgets.dart';
// //import 'package:flutter_background_service/flutter_background_service.dart';
// //import 'scam_processor.dart';

// //@pragma('vm:entry-point')
// //void onStart(ServiceInstance service) async {
// // Step 1: Input & Preprocessing preparation [cite: 24]
// //DartPluginRegistrant.ensureInitialized();
// ///WidgetsFlutterBinding.ensureInitialized();

// // Step 2: Initialize the Remote Agent Controller [cite: 13]
// //final processor = ScamProcessor();
// // await processor.init();

// // Listen for data from the Notification Listener (Main Isolate)
// //service.on('analyze_notification').listen((event) async {
// // final String? messageText = event?['message'];

// // if (messageText != null && messageText.isNotEmpty) {
// // Step 3: Logical Routing via FastAPI [cite: 26]
// // The processor now performs Intent Detection remotely [cite: 25]
// //  double riskScore = await processor.checkScamProbability(messageText);

// // IF "Action" required: Trigger the UI Overlay via the main isolate [cite: 28, 29]
// //  if (riskScore > 0.7) {
// // service.invoke('show_scam_alert', {
// //   "message": messageText,
// //   "score": riskScore,
// // });
// //   }
// // }
// // });

// //service.on('stopService').listen((event) {
// //  service.stopSelf();
// // });
// // Background service runs in isolate; handles the Agent Workflow
// import 'dart:ui';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'scam_processor.dart';

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // Step 1: Input & Preprocessing preparation [cite: 24]
//   DartPluginRegistrant.ensureInitialized();
//   WidgetsFlutterBinding.ensureInitialized();

//   // Step 2: Initialize the Remote Agent Controller [cite: 13]
//   final processor = ScamProcessor();
//   await processor.init();

//   // Listen for data from the Notification Listener (Main Isolate)
//   service.on('analyze_notification').listen((event) async {
//     try {
//       final String? messageText = event?['message'];

//       if (messageText != null && messageText.isNotEmpty) {
//         print('[BackgroundService] Analyzing: $messageText');
//         // Step 3: Logical Routing via FastAPI [cite: 26]
//         // The processor now performs Intent Detection remotely [cite: 25]
//         double riskScore =
//             await processor.checkScamProbability(messageText).timeout(
//           const Duration(seconds: 10),
//           onTimeout: () {
//             print('[BackgroundService] FastAPI timeout');
//             return 0.0;
//           },
//         );

//         print('[BackgroundService] Risk score: $riskScore');
//         // IF "Action" required: Trigger the UI Overlay via the main isolate [cite: 28, 29]
//         if (riskScore > 0.7) {
//           service.invoke('show_scam_alert', {
//             "message": messageText,
//             "score": riskScore,
//           });
//         }
//       }
//     } catch (e, stacktrace) {
//       print('[BackgroundService] Error: $e');
//       print('[BackgroundService] Stack: $stacktrace');
//     }
//   });

//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
// }
