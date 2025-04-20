import 'dart:convert';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cropconnect/features/home/domain/models/tip_model.dart';

class FarmingTipService extends GetxService {
  static const String _kCacheTipKey = 'cached_farming_tips';
  static const String _kCacheTipTimestampKey = 'cached_farming_tips_timestamp';

  final _prefs = Get.find<SharedPreferences>();

  final tipModels = <TipModel>[].obs;
  final isLoading = false.obs;
  final currentTipIndex = 0.obs;
  bool hasFetchedTips = false;

  String get _baseUrl =>
      dotenv.env['LANGFLOW_API_BASE_URL'] ??
      'https://api.langflow.astra.datastax.com';
  String get _authToken => dotenv.env['LANGFLOW_API_TOKEN'] ?? '';
  String get _flowId => dotenv.env['LANGFLOW_FLOW_ID'] ?? '';
  String get _apiEndpoint => dotenv.env['LANGFLOW_API_ENDPOINT'] ?? '';

  @override
  void onInit() {
    super.onInit();
    loadCachedTips();
    fetchTips();
  }

  String _getLanguageSuffix() {
    final locale = Get.locale?.languageCode.toLowerCase() ?? 'en';
    return locale == 'en' ? 'English' : 'Hindi';
  }

  Future<void> fetchTips() async {
    try {
      isLoading.value = true;

      if (_authToken.isEmpty) {
        AppLogger.error('Langflow API token not set');
        _setDefaultTips();
        return;
      }

      final languageSuffix = _getLanguageSuffix();
      final currentLanguage =
          languageSuffix.toLowerCase() == 'english' ? 'en' : 'hi';
      final url = '$_baseUrl$_apiEndpoint$_flowId?stream=false';

      final body = {
        'input_value': 'Tip+$languageSuffix',
        'output_type': 'chat',
        'input_type': 'chat'
      };

      AppLogger.info('Fetching farming tips in $languageSuffix');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        AppLogger.debug('Raw API response: $responseBody');
        final data = jsonDecode(responseBody);

        try {
          if (data != null &&
              data['outputs'] != null &&
              data['outputs'].isNotEmpty &&
              data['outputs'][0]['outputs'] != null &&
              data['outputs'][0]['outputs'].isNotEmpty) {
            String tipText = '';

            var outputData = data['outputs'][0]['outputs'][0];
            if (outputData['results'] != null &&
                outputData['results']['message'] != null) {
              if (outputData['results']['message']['data'] != null &&
                  outputData['results']['message']['data']['text'] != null) {
                tipText = outputData['results']['message']['data']['text'];
              } else if (outputData['results']['message']['text'] != null) {
                tipText = outputData['results']['message']['text'];
              }
            } else if (outputData['artifacts'] != null &&
                outputData['artifacts']['message'] != null) {
              tipText = outputData['artifacts']['message'];
            }

            if (tipText.isNotEmpty) {
              tipText = tipText.replaceFirst('🤖 KisanMitra: ', '');

              final tipsMatch = RegExp(r'\[([\s\S]*?)\]').firstMatch(tipText);

              if (tipsMatch != null) {
                String arrayContent = tipsMatch.group(1) ?? '';

                final regexTips = RegExp(r'"([^"\\]*(?:\\.[^"\\]*)*)"')
                    .allMatches(arrayContent)
                    .map((match) => match.group(1) ?? '')
                    .where((tip) => tip.isNotEmpty)
                    .toList();

                if (regexTips.isNotEmpty) {
                  tipModels.clear();
                  for (var tip in regexTips) {
                    tipModels.add(TipModel(
                      content: tip,
                      language: currentLanguage,
                    ));
                  }
                  _cacheTips();
                  return;
                }
              }
            }
          }

          AppLogger.error('Could not parse tips from response');
          _setDefaultTips();
        } catch (parseError) {
          AppLogger.error('Error parsing tip response: $parseError');
          _setDefaultTips();
        }
      } else {
        AppLogger.error(
            'Failed to get tips. Status code: ${response.statusCode}');
        _setDefaultTips();
      }
    } catch (e) {
      AppLogger.error('Error fetching farming tips: $e');
      _setDefaultTips();
    } finally {
      isLoading.value = false;
    }
  }

  void _cacheTips() {
    try {
      final tipsList = tipModels.map((tip) => tip.toJson()).toList();
      _prefs.setString(_kCacheTipKey, jsonEncode(tipsList));
      _prefs.setInt(
          _kCacheTipTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      AppLogger.error('Error caching tips: $e');
    }
  }

  void _setDefaultTips() {
    tipModels.clear();
    final locale = Get.locale?.languageCode.toLowerCase() ?? 'en';

    if (locale == 'hi') {
      tipModels.addAll([
        TipModel(
          content: 'मिट्टी की उर्वरता बढ़ाने के लिए जैविक खाद का उपयोग करें।',
          category: 'soil',
          language: 'hi',
        ),
        TipModel(
          content: 'फसलों को कीड़ों से बचाने के लिए नीम के तेल का प्रयोग करें।',
          category: 'pest',
          language: 'hi',
        ),
        TipModel(
          content: 'खेत में वर्षा जल संचयन का प्रबंध करें।',
          category: 'water',
          language: 'hi',
        ),
      ]);
    } else {
      tipModels.addAll([
        TipModel(
          content: 'Use organic fertilizers to improve soil fertility.',
          category: 'soil',
          language: 'en',
        ),
        TipModel(
          content: 'Use neem oil as a natural pesticide to protect crops.',
          category: 'pest',
          language: 'en',
        ),
        TipModel(
          content: 'Implement rainwater harvesting in your farm.',
          category: 'water',
          language: 'en',
        ),
      ]);
    }
  }

  Future<void> loadCachedTips() async {
    try {
      final cachedTipsJson = _prefs.getString(_kCacheTipKey);
      final timestamp = _prefs.getInt(_kCacheTipTimestampKey) ?? 0;

      // Check if we have cached tips and they're less than 24 hours old
      final isExpired = DateTime.now().millisecondsSinceEpoch - timestamp >
          24 * 60 * 60 * 1000;

      if (cachedTipsJson != null && !isExpired) {
        final List<dynamic> decoded = jsonDecode(cachedTipsJson);

        tipModels.clear();
        for (var item in decoded) {
          tipModels.add(TipModel.fromJson(item));
        }

        if (tipModels.isNotEmpty) {
          return;
        }
      }

      // If no valid cached tips, set defaults
      _setDefaultTips();
    } catch (e) {
      AppLogger.error('Error loading cached tips: $e');
      _setDefaultTips();
    }
  }
}
