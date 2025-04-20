import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends GetxService {
  static const String _kLocaleKey = 'locale';
  final _prefs = Get.find<SharedPreferences>();
  final RxString currentLocale = 'en'.obs;

  final Map<String, Map<String, String>> _translationCache = {};

  final List<Locale> supportedLocales = const [
    Locale('en'),
    Locale('hi'),
    Locale('pa'),
  ];

  @override
  void onInit() {
    super.onInit();
    loadSavedLocale();
  }

  void loadSavedLocale() {
    final savedLocale = _prefs.getString(_kLocaleKey);
    if (savedLocale != null &&
        supportedLocales.any((l) => l.languageCode == savedLocale)) {
      currentLocale.value = savedLocale;
      // Apply the saved locale immediately
      Get.updateLocale(Locale(savedLocale));
    } else {
      // If no saved locale or invalid locale, use device locale if supported
      final deviceLocale = Get.deviceLocale?.languageCode ?? 'en';
      if (supportedLocales.any((l) => l.languageCode == deviceLocale)) {
        currentLocale.value = deviceLocale;
        _prefs.setString(_kLocaleKey, deviceLocale);
        Get.updateLocale(Locale(deviceLocale));
      }
    }
  }

  Future<void> changeLocale(String languageCode) async {
    if (!supportedLocales.any((l) => l.languageCode == languageCode)) {
      return;
    }

    if (currentLocale.value != languageCode) {
      currentLocale.value = languageCode;
      await _prefs.setString(_kLocaleKey, languageCode);

      _translationCache.clear();

      await Get.updateLocale(Locale(languageCode));
    }
  }

  Locale get locale => Locale(currentLocale.value);

  void cacheTranslation(String key, String value) {
    final langCode = currentLocale.value;
    if (!_translationCache.containsKey(langCode)) {
      _translationCache[langCode] = {};
    }
    _translationCache[langCode]![key] = value;
  }

  String? getCachedTranslation(String key) {
    final langCode = currentLocale.value;
    return _translationCache[langCode]?[key];
  }
}
