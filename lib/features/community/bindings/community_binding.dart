import 'package:get/get.dart';
import '../presentation/controllers/community_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CommunityController(Get.find<FirebaseFirestore>()));
  }
}
