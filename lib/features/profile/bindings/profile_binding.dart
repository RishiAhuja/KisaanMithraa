import 'package:cropconnect/features/profile/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/hive/hive_storage_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController(
          Get.find<UserStorageService>(),
          Get.find<FirebaseFirestore>(),
        ));
  }
}
