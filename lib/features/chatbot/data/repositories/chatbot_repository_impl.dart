import 'dart:convert';

import 'package:cropconnect/features/chatbot/domain/models/chat_message_model.dart';
import 'package:cropconnect/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatbotRepositoryImpl implements ChatbotRepository {
  final String _apiUrl = dotenv.env['LANGFLOW_API_URL'] ?? '';
  final String _apiKey = dotenv.env['LANGFLOW_API_KEY'] ?? '';

  @override
  Future<ChatMessageModel> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'input_value': message,
          'output_type': 'chat',
          'input_type': 'chat',
          'tweaks': {
            'Agent-85JfP': {},
            'ChatInput-t2ae8': {},
            'ChatOutput-a4Sqi': {}
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get response: ${response.statusCode}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final botMessage = data['outputs'][0]['outputs'][0]['results']['message'];

      final messageText = botMessage['text'];

      AppLogger.debug('Extracted message text: $messageText');

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: messageText,
        timestamp: DateTime.parse(botMessage['timestamp']),
        isUser: false,
      );
    } catch (e) {
      AppLogger.error('Error communicating with chatbot: $e');
      throw Exception('Error communicating with chatbot: $e');
    }
  }
}
