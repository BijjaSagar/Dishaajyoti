import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app language/locale
/// Supports English and Hindi languages
/// Persists language preference using SharedPreferences
class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'app_language';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Initialize language from saved preference
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  /// Change app language
  /// Supported languages: 'en' (English), 'hi' (Hindi)
  Future<void> setLanguage(String languageCode) async {
    if (languageCode != _locale.languageCode) {
      _locale = Locale(languageCode);

      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      notifyListeners();
    }
  }

  /// Check if current language is English
  bool get isEnglish => _locale.languageCode == 'en';

  /// Check if current language is Hindi
  bool get isHindi => _locale.languageCode == 'hi';
}
