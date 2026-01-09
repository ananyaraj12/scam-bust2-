import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ScamProcessor {
  Interpreter? _interpreter;
  Map<String, dynamic>? _vocab;

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      final String vocabData = await rootBundle.loadString('assets/vocab.json');
      _vocab = json.decode(vocabData) as Map<String, dynamic>?;
    } catch (e) {
      print("AI Processor Error: $e");
    }
  }

  Future<double> checkScamProbability(String text) async {
    if (_interpreter == null || _vocab == null) return 0.0;

    // Tokenization -> numeric indices
    List<double> input = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .map<double>((word) => ((_vocab![word] ?? 1) as num).toDouble())
        .toList();

    // Padding/truncation to fixed length (50)
    if (input.length < 50) {
      input.addAll(List.filled(50 - input.length, 0.0));
    } else if (input.length > 50) {
      input = input.sublist(0, 50);
    }

    // Prepare nested output buffer [[0.0]]
    var output = List.generate(1, (_) => List.filled(1, 0.0));
    _interpreter!.run([input], output);
    return (output[0][0] as num).toDouble();
  }
}