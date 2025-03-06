// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Kisan Mitra`
  String get appTitle {
    return Intl.message('Kisan Mitra', name: 'appTitle', desc: '', args: []);
  }

  /// `Welcome back,`
  String get welcome {
    return Intl.message('Welcome back,', name: 'welcome', desc: '', args: []);
  }

  /// `Create Cooperative`
  String get createCooperative {
    return Intl.message(
      'Create Cooperative',
      name: 'createCooperative',
      desc: '',
      args: [],
    );
  }

  /// `Personal Information`
  String get personalInfo {
    return Intl.message(
      'Personal Information',
      name: 'personalInfo',
      desc: '',
      args: [],
    );
  }

  /// `Farm Details`
  String get farmDetails {
    return Intl.message(
      'Farm Details',
      name: 'farmDetails',
      desc: '',
      args: [],
    );
  }

  /// `Ask Mitra`
  String get askMitra {
    return Intl.message('Ask Mitra', name: 'askMitra', desc: '', args: []);
  }

  /// `Soil Type`
  String get soilType {
    return Intl.message('Soil Type', name: 'soilType', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Crops`
  String get crops {
    return Intl.message('Crops', name: 'crops', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Member since`
  String get memberSince {
    return Intl.message(
      'Member since',
      name: 'memberSince',
      desc: '',
      args: [],
    );
  }

  /// `Location not set`
  String get locationNotSet {
    return Intl.message(
      'Location not set',
      name: 'locationNotSet',
      desc: '',
      args: [],
    );
  }

  /// `No crops specified`
  String get noCrops {
    return Intl.message(
      'No crops specified',
      name: 'noCrops',
      desc: '',
      args: [],
    );
  }

  /// `Not specified`
  String get notSpecified {
    return Intl.message(
      'Not specified',
      name: 'notSpecified',
      desc: '',
      args: [],
    );
  }

  /// `Ask me anything about farming`
  String get askAnything {
    return Intl.message(
      'Ask me anything about farming',
      name: 'askAnything',
      desc: '',
      args: [],
    );
  }

  /// `Start Speaking`
  String get startSpeaking {
    return Intl.message(
      'Start Speaking',
      name: 'startSpeaking',
      desc: '',
      args: [],
    );
  }

  /// `Initializing...`
  String get initializing {
    return Intl.message(
      'Initializing...',
      name: 'initializing',
      desc: '',
      args: [],
    );
  }

  /// `Best crops for this season`
  String get bestCrops {
    return Intl.message(
      'Best crops for this season',
      name: 'bestCrops',
      desc: '',
      args: [],
    );
  }

  /// `What are the best crops to plant this season?`
  String get bestCropsQuestion {
    return Intl.message(
      'What are the best crops to plant this season?',
      name: 'bestCropsQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Pest control tips`
  String get pestControl {
    return Intl.message(
      'Pest control tips',
      name: 'pestControl',
      desc: '',
      args: [],
    );
  }

  /// `How can I deal with common pests?`
  String get pestControlQuestion {
    return Intl.message(
      'How can I deal with common pests?',
      name: 'pestControlQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Water conservation`
  String get waterConservation {
    return Intl.message(
      'Water conservation',
      name: 'waterConservation',
      desc: '',
      args: [],
    );
  }

  /// `How can I conserve water?`
  String get waterConservationQuestion {
    return Intl.message(
      'How can I conserve water?',
      name: 'waterConservationQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Organic farming`
  String get organicFarming {
    return Intl.message(
      'Organic farming',
      name: 'organicFarming',
      desc: '',
      args: [],
    );
  }

  /// `Tips for organic farming?`
  String get organicFarmingQuestion {
    return Intl.message(
      'Tips for organic farming?',
      name: 'organicFarmingQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Ask anything about farming...`
  String get askFarmingQuestion {
    return Intl.message(
      'Ask anything about farming...',
      name: 'askFarmingQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition is initializing. Please wait...`
  String get speechInitializing {
    return Intl.message(
      'Speech recognition is initializing. Please wait...',
      name: 'speechInitializing',
      desc: '',
      args: [],
    );
  }

  /// `Recognized: "`
  String get recognized {
    return Intl.message(
      'Recognized: "',
      name: 'recognized',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition error: `
  String get speechError {
    return Intl.message(
      'Speech recognition error: ',
      name: 'speechError',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
