import 'package:get/get.dart';

class MitraHelperService extends GetxController {
  final RxBool isVisible = false.obs;
  final RxString currentMessage = ''.obs;
  final RxBool isTyping = false.obs;

  Future<void> showMessage(String message) async {
    isVisible.value = true;
    isTyping.value = true;

    // Simulate typing effect
    currentMessage.value = '';
    for (int i = 0; i < message.length; i++) {
      currentMessage.value += message[i];
      await Future.delayed(const Duration(milliseconds: 50));
    }

    isTyping.value = false;
  }

  void hide() {
    isVisible.value = false;
    currentMessage.value = '';
  }
}
