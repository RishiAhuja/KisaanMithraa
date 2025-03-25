import 'dart:convert';

import 'package:cropconnect/features/chatbot/domain/models/chat_message_model.dart';
import 'package:cropconnect/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class ChatbotRepositoryImpl implements ChatbotRepository {
  final String _apiUrl = 'http://13.232.133.58:8005/api/v1/chat';
  static const String _userId = 'user123';

  @override
  Future<ChatMessageModel> sendMessage(String message,
      {String language = 'en'}) async {
    try {
      AppLogger.debug(
          'Sending message to chatbot: $message (language: $language)');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'message': message,
          'language': language,
          'user_id': _userId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get response: ${response.statusCode}');
      }

      // Log raw response for debugging
      AppLogger.debug('Raw API response: ${response.body}');

      // Decode the main response
      final responseBody = utf8.decode(response.bodyBytes);
      dynamic data;

      try {
        // First try to parse as direct JSON
        data = jsonDecode(responseBody);
        AppLogger.debug('First level parsed JSON: $data');

        // Check if we got a string that might be another JSON
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          final messageContent = data['message'];

          // If message content appears to be another JSON string, try to parse it
          if (messageContent is String &&
              (messageContent.trim().startsWith('{') &&
                  messageContent.trim().endsWith('}'))) {
            try {
              // Try to parse the nested JSON
              final messageJson = jsonDecode(messageContent);
              AppLogger.debug('Nested JSON detected and parsed: $messageJson');

              // Extract the actual message from nested JSON
              if (messageJson is Map<String, dynamic> &&
                  messageJson.containsKey('message')) {
                data['message'] = messageJson['message'];

                // Also update tags if available in nested JSON
                if (messageJson.containsKey('tags')) {
                  data['tags'] = messageJson['tags'];
                }

                AppLogger.debug(
                    'Updated message from nested JSON: ${data['message']}');
              }
            } catch (e) {
              // If nested parsing fails, keep the original message
              AppLogger.debug(
                  'Failed to parse nested JSON, using original message: $e');
            }
          }
        }
      } catch (e) {
        AppLogger.error('Error parsing JSON: $e');
        throw Exception('Error parsing response JSON: $e');
      }

      // Now extract message from the parsed data
      String botMessage = 'Sorry, I couldn\'t process that response.';

      if (data is Map<String, dynamic> && data.containsKey('message')) {
        final messageValue = data['message'];
        if (messageValue is String) {
          botMessage = messageValue;
        }
      }

      // Extract navigation suggestions
      List<String> navigations = [];
      if (data is Map<String, dynamic> &&
          data.containsKey('navigations') &&
          data['navigations'] is List) {
        navigations = List<String>.from(data['navigations']);
      }

      // Extract language info
      String? responseLanguage = language;
      String? sourceLanguage = 'en';

      if (data is Map<String, dynamic>) {
        if (data.containsKey('language')) {
          responseLanguage = data['language'] as String?;
        }
        if (data.containsKey('source_language')) {
          sourceLanguage = data['source_language'] as String?;
        }
      }

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: botMessage,
        timestamp: DateTime.now(),
        isUser: false,
        navigations: navigations,
        language: responseLanguage,
        sourceLanguage: sourceLanguage,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error communicating with chatbot: $e');
      AppLogger.error('Stack trace: $stackTrace');
      throw Exception('Error communicating with chatbot: $e');
    }
  }
}
