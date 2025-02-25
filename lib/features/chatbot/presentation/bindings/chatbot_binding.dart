import 'package:cropconnect/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:cropconnect/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:cropconnect/features/chatbot/presentation/controllers/chatbot_controller.dart';
import 'package:get/get.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatbotRepository>(() => ChatbotRepositoryImpl());
    Get.lazyPut(() => ChatbotController(Get.find()));
  }
}
