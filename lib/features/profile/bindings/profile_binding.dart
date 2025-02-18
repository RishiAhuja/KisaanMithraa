import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/hive/hive_storage_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileController(
      Get.find<UserStorageService>(),
      Get.find<FirebaseFirestore>(),
    ));
  }
}
