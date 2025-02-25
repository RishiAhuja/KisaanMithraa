import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:cropconnect/features/onboarding/presentation/controller/nearby_cooperatives_controller.dart';
import 'package:cropconnect/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:cropconnect/features/profile/controller/profile_controller.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repo.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  late final ProfileController _profileController;
  final _firestore = FirebaseFirestore.instance;
  final _storageService = Get.find<UserStorageService>();
  final _auth = FirebaseAuth.instance;
  final phoneNumberController = TextEditingController();
  final phoneNumber = ''.obs;
  final isLoading = false.obs;
  final name = ''.obs;
  final _onboardingController = Get.find<OnboardingController>();
  final error = Rx<String?>(null);
  final verificationId = ''.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  // ignore: unused_field
  String? _verificationId;

  AuthController(this._authRepository) {
    _profileController = Get.find<ProfileController>();
  }

  @override
  void onInit() {
    super.onInit();
    phoneNumberController.addListener(() {
      phoneNumber.value = phoneNumberController.text;
    });
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    super.onClose();
  }

  Future<bool> initializeAuth() async {
    try {
      AppLogger.info('Initializing authentication state...');

      final hasLoggedIn = await _storageService.getHasLoggedIn();

      if (hasLoggedIn) {
        AppLogger.info('User has previously logged in, navigating to home');
        await Get.offAllNamed('/home');
        return true;
      }

      final isLoggedIn = _authRepository.isUserLoggedIn();
      if (isLoggedIn) {
        AppLogger.info('User is logged in, navigating to home screen');
        await Get.offAllNamed('/home');
        return true;
      } else {
        AppLogger.info('User is not logged in, navigating to register screen');
        await Get.offAllNamed('/onboarding');
        return false;
      }
    } catch (e) {
      AppLogger.error('Failed to initialize auth state', e);
      await Get.offAllNamed('/onboarding');
      return false;
    }
  }

  Future<void> registerWithPhone() async {
    try {
      isLoading.value = true;

      if (phoneNumber.value.isEmpty) {
        error.value = 'Please enter a phone number';
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: '+91${phoneNumber.value}',
        verificationCompleted: (credential) async {
          await _handleVerificationCompleted(credential);
        },
        verificationFailed: (e) {
          error.value = 'Verification failed: ${e.message}';
          isLoading.value = false;
        },
        codeSent: (String verId, int? resendToken) {
          verificationId.value = verId;
          Get.toNamed('/otp');
          isLoading.value = false;
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
          isLoading.value = false;
        },
      );
    } catch (e) {
      AppLogger.error(e.toString());
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(String otp) async {
    try {
      isLoading.value = true;
      error.value = null;

      AppLogger.info(
          'Verifying OTP with verification ID: ${verificationId.value}');

      if (verificationId.value.isEmpty) {
        throw Exception('Verification ID not found');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );

      await _handleVerificationCompleted(credential);
    } catch (e) {
      AppLogger.error('Error verifying OTP: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleVerificationCompleted(
      PhoneAuthCredential credential) async {
    AppLogger.debug('Handling verification completed');
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase user not found');
      }

      AppLogger.debug('Querying for existing user');

      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      UserModel user;

      if (userDoc.exists) {
        user = UserModel.fromMap(userDoc.data()!, userDoc.id);
        AppLogger.info('Existing user logged in: ${user.name}');
      } else {
        final currentLocation = await _profileController.getCurrentLocation();
        user = UserModel(
          id: firebaseUser.uid,
          name: _onboardingController.name.value,
          phoneNumber: phoneNumber.value,
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

        AppLogger.info('New user created: ${user.name}');
      }

      await _storageService.setHasLoggedIn(true);
      await _storageService.saveUser(user);
      AppLogger.debug('User saved to storage');
      name.value = '';
      phoneNumber.value = '';
      _verificationId = null;

      if (userDoc.exists) {
        Get.offAllNamed('/home');
      } else {
        AppLogger.info('Navigating to jpin a coop screen');
        await Get.delete<NearbyCooperativesController>(force: true);
        Get.put(NearbyCooperativesController());
        Get.offAllNamed('/nearby-cooperatives');
      }
    } catch (e) {
      AppLogger.error('Error in verification: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    error.value = null;
  }
}
