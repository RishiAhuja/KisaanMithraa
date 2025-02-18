import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/hive/hive_storage_service.dart';
import '../../domain/models/cooperative_model.dart';

class MyCooperativesController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _storageService = Get.find<UserStorageService>();

  final isLoading = true.obs;
  final error = Rxn<String>();
  final cooperatives = <CooperativeWithRole>[].obs;

  Stream<List<CooperativeWithRole>> get cooperativesStream async* {
    final user = await _storageService.getUser();
    if (user == null) {
      yield [];
      return;
    }

    yield* _firestore
        .collection('cooperatives')
        .where('members', arrayContains: user.id)
        .snapshots()
        .asyncMap((snapshot) async {
      final coops = <CooperativeWithRole>[];

      for (var doc in snapshot.docs) {
        final coop = CooperativeModel.fromMap(doc.data());
        final role = doc.data()['createdBy'] == user.id ? 'admin' : 'member';
        coops.add(CooperativeWithRole(cooperative: coop, role: role));
      }

      return coops;
    });
  }

  @override
  void onInit() {
    super.onInit();
    setupStream();
  }

  void setupStream() {
    cooperativesStream.listen((coops) {
      cooperatives.value = coops;
      isLoading.value = false;
    }, onError: (error) {
      this.error.value = error.toString();
      isLoading.value = false;
    });
  }
}

class CooperativeWithRole {
  final CooperativeModel cooperative;
  final String role;

  CooperativeWithRole({
    required this.cooperative,
    required this.role,
  });
}
