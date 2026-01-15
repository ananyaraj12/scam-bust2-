import 'app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Translator {
  static String currentLang = "en"; // default

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    currentLang = prefs.getString('language_code') ?? 'en';
  }

  static Future<void> setLang(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    currentLang = languageCode;
  }

  static String t(String key) {
    return AppStrings.values[currentLang]?[key] ?? key;
  }
}
