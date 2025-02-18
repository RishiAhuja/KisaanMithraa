import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/controllers/create_cooperative_controller.dart';

class CreateCooperativeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CreateCooperativeController(
      Get.find<FirebaseFirestore>(),
    ));
  }
}
