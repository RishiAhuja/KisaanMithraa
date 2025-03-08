import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/onboarding/presentation/controller/nearby_cooperatives_controller.dart';
import 'package:cropconnect/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:cropconnect/features/profile/controller/profile_controller.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DebugAuthController extends GetxController {
  late final ProfileController _profileController;
  final _firestore = FirebaseFirestore.instance;
  final _storageService = Get.find<UserStorageService>();
  final phoneNumberController = TextEditingController();
  final phoneNumber = ''.obs;
  final isLoading = false.obs;
  final name = ''.obs;
  final _onboardingController = Get.find<OnboardingController>();
  final error = Rx<String?>(null);
  final verificationId = ''.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  DebugAuthController() {
    _profileController = Get.find<ProfileController>();
  }

  Future<void> debugDirectLogin(String phoneNumber) async {
    try {
      isLoading.value = true;
      error.value = null;

      if (phoneNumber.isEmpty) {
        error.value = 'Please enter a phone number';
        isLoading.value = false;
        return;
      }

      AppLogger.info(
          '[DEBUG] Bypassing OTP verification for number: $phoneNumber');

      final formattedPhoneNumber =
          phoneNumber.startsWith('+91') ? phoneNumber : '+91$phoneNumber';

      final testUserId = 'debug-${formattedPhoneNumber.replaceAll('+', '')}';

      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber.replaceAll('+91', ''))
          .limit(1)
          .get();

      String userId = testUserId;
      if (querySnapshot.docs.isNotEmpty) {
        userId = querySnapshot.docs.first.id;
      }

      await _handleDebugUser(userId, phoneNumber.replaceAll('+91', ''));
    } catch (e) {
      AppLogger.error('[DEBUG] Error in debug login: ${e.toString()}');
      error.value = '[DEBUG] ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleDebugUser(String userId, String phoneNumber) async {
    AppLogger.debug('[DEBUG] Querying for existing user');

    final userDoc = await _firestore.collection('users').doc(userId).get();

    UserModel user;

    if (userDoc.exists) {
      user = UserModel.fromMap(userDoc.data()!, userDoc.id);
      AppLogger.info('[DEBUG] Existing user logged in: ${user.name}');
    } else {
      final currentLocation = await _profileController.getCurrentLocation();
      user = UserModel(
        id: userId,
        name: _onboardingController.name.value,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        cooperatives: [],
        pendingInvites: [],
        city: _onboardingController.selectedCity.value,
        state: _onboardingController.selectedState.value,
        crops: _onboardingController.selectedCrops.toList(),
        latitude: currentLocation?.latitude,
        longitude: currentLocation?.longitude,
      );
      await _firestore.collection('users').doc(user.id).set(user.toMap());

      AppLogger.info('[DEBUG] New debug user created: ${user.name}');
    }

    await _storageService.setHasLoggedIn(true);
    await _storageService.saveUser(user);
    AppLogger.debug('[DEBUG] User saved to storage');
    name.value = '';
    phoneNumber = '';

    if (userDoc.exists) {
      Get.offAllNamed('/home');
    } else {
      AppLogger.info('[DEBUG] Navigating to join a coop screen');
      await Get.delete<NearbyCooperativesController>(force: true);
      Get.put(NearbyCooperativesController());
      Get.offAllNamed('/nearby-cooperatives');
    }
  }

  Future<DocumentSnapshot?> debugCheckUserExists(String phoneNumber) async {
    try {
      final cleanPhone = phoneNumber.replaceAll('+91', '');

      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: cleanPhone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userId = querySnapshot.docs.first.id;
        return await _firestore.collection('users').doc(userId).get();
      }
      return null;
    } catch (e) {
      AppLogger.error('[DEBUG] Error checking user existence: $e');
      return null;
    }
  }
}
