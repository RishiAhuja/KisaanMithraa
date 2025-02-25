import 'package:cropconnect/features/chatbot/domain/models/chat_message_model.dart';
import 'package:cropconnect/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:get/get.dart';

class ChatbotController extends GetxController {
  final ChatbotRepository _repository;
  final messages = <ChatMessageModel>[].obs;
  final isLoading = false.obs;

  ChatbotController(this._repository);

  Future<void> sendMessage(String text) async {
    try {
      if (text.trim().isEmpty) return;

      // Add user message
      messages.add(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          timestamp: DateTime.now(),
          isUser: true,
        ),
      );

      isLoading.value = true;

      // Get bot response
      final response = await _repository.sendMessage(text);
      messages.add(response);
    } catch (e) {
      messages.add(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Error getting response',
          timestamp: DateTime.now(),
          isUser: false,
          error: e.toString(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
