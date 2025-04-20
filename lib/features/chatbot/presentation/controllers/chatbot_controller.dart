import 'dart:convert';
import 'package:cropconnect/features/chatbot/data/service/speech_service.dart';
import 'package:cropconnect/features/chatbot/domain/models/chat_message_model.dart';
import 'package:cropconnect/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:cropconnect/core/services/locale/locale_service.dart';
import 'package:get/get.dart';

class ChatbotController extends GetxController {
  final ChatbotRepository _repository;
  final LocaleService _localeService = Get.find<LocaleService>();
  final messages = <ChatMessageModel>[].obs;
  final isLoading = false.obs;
  final currentLanguage = 'en'.obs;
  final isListeningToSpeech = false.obs;
  final isReadingResponse = false.obs;

  final Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिंदी',
    'pa': 'ਪੰਜਾਬੀ',
  };

  ChatbotController(this._repository);

  @override
  void onInit() {
    super.onInit();
    _initializeLanguage();
  }

  void _initializeLanguage() {
    final savedLocale = _localeService.currentLocale.value;

    if (supportedLanguages.containsKey(savedLocale)) {
      currentLanguage.value = savedLocale;
    } else {
      currentLanguage.value = 'en';
    }
  }

  void toggleLanguage() {
    String newLanguage;

    switch (currentLanguage.value) {
      case 'en':
        newLanguage = 'hi';
        break;
      case 'hi':
        newLanguage = 'pa';
        break;
      case 'pa':
        newLanguage = 'en';
        break;
      default:
        newLanguage = 'en';
    }

    currentLanguage.value = newLanguage;
    _localeService.changeLocale(newLanguage);

    Get.snackbar(
      'Language Changed',
      'Now using ${supportedLanguages[newLanguage]}',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(
      ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.trim(),
        timestamp: DateTime.now(),
        isUser: true,
      ),
    );

    try {
      isLoading.value = true;
      final response =
          await _repository.sendMessage(text, language: currentLanguage.value);

      AppLogger.debug('Received response with text: ${response.text}');

      // Process the response to handle inconsistent format
      final processedResponse = _processResponse(response);

      // Add bot response after processing
      messages.add(processedResponse);
    } catch (e, stackTrace) {
      AppLogger.error('Error in sendMessage: $e');
      AppLogger.error('Stack trace: $stackTrace');

      messages.add(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Sorry, I encountered an error. Please try again.',
          timestamp: DateTime.now(),
          isUser: false,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // New method to process inconsistent response formats
  ChatMessageModel _processResponse(ChatMessageModel originalResponse) {
    String processedText = originalResponse.text;
    List<String>? navigations = originalResponse.navigations;

    // Try to parse the text as JSON to handle nested response format
    try {
      if (processedText.trim().startsWith('{') &&
          processedText.trim().endsWith('}')) {
        // Fix JSON formatting issues before parsing
        // This handles unescaped newlines and other control characters
        String sanitizedJson = _sanitizeJsonString(processedText);

        final Map<String, dynamic> parsedJson = json.decode(sanitizedJson);

        // Check if response has the nested 'message' field
        if (parsedJson.containsKey('message')) {
          final dynamic messageContent = parsedJson['message'];

          // Handle message field - could be a string or another object
          if (messageContent is String) {
            processedText = messageContent;
          } else if (messageContent is Map) {
            processedText = messageContent.toString();
          }
        }

        // Extract any navigation tags if available
        if (parsedJson.containsKey('tags') && parsedJson['tags'] is Map) {
          final tags = parsedJson['tags'] as Map<String, dynamic>;

          // Extract topics or other relevant data for navigation
          if (tags.containsKey('topics') && tags['topics'] is List) {
            final topics = (tags['topics'] as List).cast<String>();
            navigations = _mapTopicsToNavigations(topics);
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error parsing response JSON: $e');

      // Fallback: Try to extract message content using regex
      final messageRegex = RegExp(
          r'"message"\s*:\s*"([\s\S]*?)"(?=\s*,\s*"|\s*})',
          dotAll: true);
      final match = messageRegex.firstMatch(processedText);

      if (match != null && match.groupCount >= 1) {
        processedText = match.group(1)?.replaceAll(r'\"', '"') ?? processedText;
      }
    }

    // Create a new message with the processed text
    return ChatMessageModel(
      id: originalResponse.id,
      text: processedText,
      timestamp: originalResponse.timestamp,
      isUser: false,
      navigations: navigations,
      language: originalResponse.language,
    );
  }

  // Helper method to map topics to navigation routes
  List<String>? _mapTopicsToNavigations(List<String> topics) {
    final Map<String, String> topicToRouteMap = {
      'organic farming': '/resources',
      'fertilizers': '/marketplace',
      'pest management': '/resources',
      'crop rotation': '/resources',
      'water conservation': '/resources',
      'biodiversity': '/resources',
      'seasons': '/weather-details',
      'weather': '/weather-details',
      'soil health': '/resources',
      'podcast': '/podcasts',
      'community': '/cooperatives',
    };

    final Set<String> routes = {};

    for (final topic in topics) {
      final String? route = topicToRouteMap[topic.toLowerCase()];
      if (route != null) {
        routes.add(route);
      }
    }

    return routes.isNotEmpty ? routes.toList() : null;
  }

  String getCurrentLanguageName() {
    return supportedLanguages[currentLanguage.value] ?? 'English';
  }

  void handleSpeechRecognitionResult(String recognizedText) {
    if (recognizedText.isNotEmpty) {
      sendMessage(recognizedText);
    }
    isListeningToSpeech.value = false;
  }

  // Method to stop any ongoing speech
  Future<void> stopSpeech() async {
    if (Get.isRegistered<SpeechService>()) {
      final speechService = Get.find<SpeechService>();
      await speechService.stop();
      if (isListeningToSpeech.value) {
        await speechService.stopListening();
        isListeningToSpeech.value = false;
      }
      isReadingResponse.value = false;
    }
  }

  void resetConversation() {
    stopSpeech();
    messages.clear();
  }

  @override
  void onClose() {
    stopSpeech();
    super.onClose();
  }

  // Add this helper method to sanitize the JSON string
  String _sanitizeJsonString(String jsonString) {
    // First, let's try to handle the most common case - a JSON string with
    // unescaped newlines and control characters in string values

    // Regex to find all string values in the JSON
    final stringValueRegex = RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"');

    // Replace each string value with a sanitized version
    return jsonString.replaceAllMapped(stringValueRegex, (match) {
      String value = match.group(0) ?? '';

      // Escape newlines and other control characters
      value = value
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r')
          .replaceAll('\t', '\\t');

      return value;
    });
  }
}
