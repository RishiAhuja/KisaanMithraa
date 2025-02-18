import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/cooperative_model.dart';
import '../../../auth/domain/model/user/user_model.dart';

class CooperativeDetailsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final cooperative = Rxn<CooperativeModel>();
  final members = <UserModel>[].obs;
  final isLoading = true.obs;
  final error = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    cooperative.value = Get.arguments.cooperative;
    loadMembers();
  }

  Future<void> loadMembers() async {
    try {
      isLoading.value = true;
      error.value = null;

      final memberDocs = await Future.wait(
        cooperative.value!.members.map((memberId) async {
          final doc = await _firestore.collection('users').doc(memberId).get();
          return doc;
        }),
      );

      members.value = memberDocs
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromMap(doc.data()!, doc.id))
          .toList();
    } catch (e) {
      error.value = 'Failed to load members';
      AppLogger.error('Error loading members: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
