import 'package:cropconnect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/cooperative_model.dart';

class CreateCooperativeController extends GetxController {
  final FirebaseFirestore _firestore;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final isLoading = false.obs;
  final selectedCropType = Rx<String?>(null);

  final cropTypes = [
    'Rice',
    'Wheat',
    'Corn',
    'Cotton',
    'Sugarcane',
    'Pulses',
    'Vegetables',
    'Fruits',
  ];

  CreateCooperativeController(this._firestore);

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> createCooperative() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final userId = Get.find<AuthController>().user.value?.id;
      if (userId == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      final cooperative = CooperativeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        description: descriptionController.text,
        adminName: userId,
        createdAt: DateTime.now(),
        location: 'Pending',
        cropTypes: [selectedCropType.value!],
        latitude: 0.0,
        longitude: 0.0,
        members: [userId],
        adminId: '',
        adminNumber: '',
      );

      await _firestore
          .collection('cooperatives')
          .doc(cooperative.id)
          .set(cooperative.toMap());

      Get.snackbar('Success', 'Cooperative created successfully');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create cooperative: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
