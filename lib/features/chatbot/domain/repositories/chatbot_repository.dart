import 'package:cropconnect/features/chatbot/domain/models/chat_message_model.dart';

abstract class ChatbotRepository {
  Future<ChatMessageModel> sendMessage(String message);
}
