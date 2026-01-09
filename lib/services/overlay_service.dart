import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  /// Ensure overlay permission is granted and show a simple overlay
  /// with the provided [content].
  static Future<bool> showScamOverlay(String content) async {
    try {
      final granted = await FlutterOverlayWindow.isPermissionGranted();
      if (!granted) {
        final bool? req = await FlutterOverlayWindow.requestPermission();
        if (req != true) return false;
      }

      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        height: 300,
        width: 350,
        alignment: OverlayAlignment.center,
        overlayTitle: 'Scam Alert',
        overlayContent: content,
        flag: OverlayFlag.defaultFlag,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> closeOverlay() async {
    try {
      await FlutterOverlayWindow.closeOverlay();
    } catch (_) {}
  }
}
