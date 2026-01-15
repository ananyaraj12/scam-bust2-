
import 'package:flutter_test/flutter_test.dart';
import 'package:scam_burst/localization/translator.dart';
import 'package:scam_burst/localization/app_strings.dart';

void main() {
  group('Translator Tests', () {
    test('Defaults to English', () {
      expect(Translator.currentLang, 'en');
    });

    test('Translation works for English', () {
      Translator.currentLang = 'en';
      expect(Translator.t('app_title'), 'Scam Bust');
      expect(Translator.t('status_active'), 'Protection Active');
    });

    test('Translation works for Hindi', () {
      Translator.currentLang = 'hi';
      expect(Translator.t('status_active'), 'सुरक्षा चालू है');
    });

    test('Translation works for Bengali', () {
      Translator.currentLang = 'bn';
      expect(Translator.t('status_active'), 'সুরক্ষা চালু আছে');
    });

    test('Translation works for Odia', () {
      Translator.currentLang = 'or';
      expect(Translator.t('status_active'), 'ସୁରକ୍ଷା ସକ୍ରିୟ ଅଛି');
    });

    test('Returns key if key is missing', () {
      Translator.currentLang = 'en';
      expect(Translator.t('non_existent_key'), 'non_existent_key');
    });

    test('Returns key if language is known but key is missing', () {
      Translator.currentLang = 'hi';
      expect(Translator.t('non_existent_key'), 'non_existent_key');
    });
  });

  group('AppStrings Consistency Tests', () {
    test('All languages have same keys as English', () {
      final enKeys = AppStrings.values['en']!.keys.toSet();
      final languages = ['hi', 'bn', 'or'];

      for (var lang in languages) {
        final langKeys = AppStrings.values[lang]!.keys.toSet();
        
        final missingInLang = enKeys.difference(langKeys);
        final extraInLang = langKeys.difference(enKeys);

        if (missingInLang.isNotEmpty) {
          print('Missing keys in $lang: $missingInLang');
        }
        if (extraInLang.isNotEmpty) {
          print('Extra keys in $lang: $extraInLang');
        }

        expect(missingInLang, isEmpty, reason: 'Language $lang is missing keys present in English');
        // We might allow extra keys, but consistency is better. 
        // For now, let's just warn or strictly check. 
        // Strict check:
        // expect(extraInLang, isEmpty, reason: 'Language $lang has extra keys not in English');
      }
    });
  });
}
