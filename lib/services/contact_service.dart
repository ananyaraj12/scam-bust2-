import 'package:url_launcher/url_launcher.dart';
import 'family_service.dart';

class ContactService {
  static Future<void> contactFamily(String scamMessage) async {
    final members = await FamilyService.getFamilyMembers();

    for (var member in members) {
      try {
        // Create SMS message
        final message = Uri.encodeComponent(
            '⚠️ ALERT: I received a potential scam message.\n\nScam Alert: $scamMessage\n\nPlease verify with me before I take any action.');

        final smsUrl = 'sms:${member.phoneNumber}?body=$message';

        if (await canLaunchUrl(Uri.parse(smsUrl))) {
          await launchUrl(Uri.parse(smsUrl));
          print(
              '[ContactService] Contacting ${member.name} at ${member.phoneNumber}');
        }
      } catch (e) {
        print('[ContactService] Error contacting ${member.name}: $e');
      }
    }
  }
}
