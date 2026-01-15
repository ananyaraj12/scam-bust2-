import 'dart:convert';
import 'package:flutter/services.dart';

class LanguageService {
  static Map<String, String> _strings = {};
  static String currentLang = "en";

  static Future<void> load(String langCode) async {
    currentLang = langCode;

    final data =
        await rootBundle.loadString("assets/localization/$langCode.json");

    final Map<String, dynamic> jsonMap = json.decode(data);

    _strings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  static String t(String key) {
    return _strings[key] ?? key;
  }
}
