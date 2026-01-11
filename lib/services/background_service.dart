// Background service runs in isolate; avoid UI imports.
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'scam_processor.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Background isolate: initialize processor and set up minimal listeners
  WidgetsFlutterBinding.ensureInitialized();

  final processor = ScamProcessor();
  await processor.init();

  // The full notification listener and UI overlay are implemented
  // on the main isolate. Keep the background service lightweight
  // to avoid plugin usage in the isolate.

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}