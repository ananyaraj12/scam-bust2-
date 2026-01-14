import 'dart:convert';
import 'package:http/http.dart' as http;

class ScamProcessor {
  // Replace this with your actual FastAPI server URL
  // Use 10.0.2.2 if testing on an Android Emulator
  final String _apiUrl = "http://YOUR_SERVER_IP:8000/analyze";

  Future<void> init() async {
    // No local assets to load anymore! 
    // The Gemini Pro core logic is now managed on the server[cite: 6].
    print("FastAPI Scam Processor Initialized");
  }

  Future<double> checkScamProbability(String text) async {
    try {
      // Check if API URL is properly configured
      if (_apiUrl.contains('YOUR_SERVER_IP')) {
        print("[ScamProcessor] API URL not configured. Update YOUR_SERVER_IP in scam_processor.dart");
        return 0.0;
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"text": text}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // The server returns a Structured JSON Output.
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Return the probability score from the API response
        double score = (data['probability'] ?? 0.0).toDouble();
        print("[ScamProcessor] Analysis result: $score");
        return score;
      } else {
        print("[ScamProcessor] Server Error: ${response.statusCode}");
        return 0.0;
      }
    } catch (e) {
      print("[ScamProcessor] Network Error: $e");
      return 0.0;
    }
  }
}