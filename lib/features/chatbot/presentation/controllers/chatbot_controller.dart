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
      AppLogger.debug('Response language: ${response.language}');
      AppLogger.debug('Response navigations: ${response.navigations}');

      // Add bot response directly without additional modifications
      messages.add(response);
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
}
