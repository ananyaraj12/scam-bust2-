import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  /// Request overlay permission (opens settings on Android).
  static Future<bool> requestOverlayPermission() async {
    try {
      final granted = await FlutterOverlayWindow.isPermissionGranted();
      if (granted) return true;
      final bool? result = await FlutterOverlayWindow.requestPermission();
      return result == true;
    } catch (e) {
      print('Overlay permission request error: $e');
      return false;
    }
  }

  /// Ensure overlay permission is granted and show a simple overlay
  /// with the provided [content]. Returns true when the overlay was
  /// requested successfully.
  static Future<bool> showScamOverlay(String content) async {
    try {
      final granted = await FlutterOverlayWindow.isPermissionGranted();
      if (!granted) {
        final bool ok = await requestOverlayPermission();
        if (!ok) return false;
      }

      // Provide a simple content string; plugin will render it in overlay.
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
      print('showScamOverlay error: $e');
      return false;
    }
  }

  static Future<void> closeOverlay() async {
    try {
      await FlutterOverlayWindow.closeOverlay();
    } catch (e) {
      print('closeOverlay error: $e');
    }
  }
}
