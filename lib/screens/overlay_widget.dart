
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class OverlayWidget extends StatelessWidget {
  final String scamContent;
  const OverlayWidget({super.key, required this.scamContent});

  Future<void> _callFamily(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to get family phone number from local storage
      // Adjust the key name based on how you store it in your app
      final familyPhone = prefs.getString('family_phone') ?? 
                         prefs.getString('emergency_contact') ??
                         prefs.getString('family_contact_phone');
      
      if (familyPhone == null || familyPhone.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No family contact saved. Please add one in Family Circle.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Format the phone number (remove spaces, dashes, etc.)
      final cleanNumber = familyPhone.replaceAll(RegExp(r'[^0-9+]'), '');
      
      // Create the tel: URI
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
      
      // Launch the phone dialer
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open phone dialer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.danger.withAlpha(242),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                "🚨 SCAM DETECTED 🚨",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Warning: The message you just received is a known fraud attempt.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _scamPreview(scamContent),
              const SizedBox(height: 32),
              
              // CALL FAMILY BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  onPressed: () => _callFamily(context),
                  icon: const Icon(Icons.phone, size: 22),
                  label: const Text(
                    "CALL FAMILY",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // I UNDERSTAND BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "I UNDERSTAND",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scamPreview(String content) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      );
}



// import 'package:flutter/material.dart';
// import '../utils/constants.dart';

// class OverlayWidget extends StatelessWidget {
//   final String scamContent;
//   const OverlayWidget({super.key, required this.scamContent});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: AppColors.danger.withOpacity(0.95),
//       child: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.warning_rounded, size: 120, color: Colors.white),
//             const Text("🚨 SCAM DETECTED 🚨", 
//               style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 40),
//               child: Text(
//                 "Warning: The message you just received is a known fraud attempt.",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 18, color: Colors.white70),
//               ),
//             ),
//             const SizedBox(height: 30),
//             _scamPreview(scamContent),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
//               onPressed: () => Navigator.pop(context),
//               child: Text("I UNDERSTAND", style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _scamPreview(String content) => Container(
//     margin: const EdgeInsets.all(20),
//     padding: const EdgeInsets.all(15),
//     decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
//     child: Text(content, style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
//   );
// }
