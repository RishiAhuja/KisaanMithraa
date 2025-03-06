import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends GetxService {
  static const String _kLocaleKey = 'locale';
  final _prefs = Get.find<SharedPreferences>();
  final RxString currentLocale = 'en'.obs;

  final List<Locale> supportedLocales = const [
    Locale('en'),
    Locale('hi'),
  ];

  @override
  void onInit() {
    super.onInit();
    currentLocale.value = _prefs.getString(_kLocaleKey) ?? 'en';
  }

  Future<void> changeLocale(String languageCode) async {
    currentLocale.value = languageCode;
    await _prefs.setString(_kLocaleKey, languageCode);
    await Get.updateLocale(Locale(languageCode));
  }

  // New helper method to get the current locale object
  Locale get locale => Locale(currentLocale.value);
}
