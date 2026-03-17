import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Supported app locales
const List<Locale> appSupportedLocales = [
  Locale('en'), // English
  Locale('hi'), // Hindi
  Locale('gu'), // Gujarati
];

const Map<String, String> localeDisplayNames = {
  'en': 'English',
  'hi': 'हिन्दी',
  'gu': 'ગુજરાતી',
};

/// Riverpod state notifier for locale
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefLanguageCode);
    if (saved != null) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLanguageCode, languageCode);
    state = Locale(languageCode);
  }

  String get currentLanguageCode => state.languageCode;

  String get currentDisplayName =>
      localeDisplayNames[state.languageCode] ?? 'English';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
