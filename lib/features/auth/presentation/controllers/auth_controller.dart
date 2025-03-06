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
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../domain/repositories/auth_repo.dart';
import '../../data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  late final ProfileController _profileController;
  final _firestore = FirebaseFirestore.instance;
  final _storageService = Get.find<UserStorageService>();
  final _auth = FirebaseAuth.instance;
  late final FirebaseAuthService authService;
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
    authService = FirebaseAuthService();
    phoneNumberController.addListener(() {
      phoneNumber.value = phoneNumberController.text;
    });
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    // Dispose reCAPTCHA if on web
    // if (kIsWeb) {
    //   authService.dispose();
    // }
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
        await Get.offAllNamed('/intro');
        return false;
      }
    } catch (e) {
      AppLogger.error('Failed to initialize auth state', e);
      await Get.offAllNamed('/intro');
      return false;
    }
  }

  Future<void> registerWithPhone() async {
    try {
      isLoading.value = true;
      error.value = null;

      if (phoneNumber.value.isEmpty) {
        error.value = 'Please enter a phone number';
        isLoading.value = false;
        return;
      }

      // Format phone number with India country code
      final formattedPhoneNumber = '+91${phoneNumber.value}';

      // For web platform, ensure reCAPTCHA is properly set up
      if (kIsWeb) {
        AppLogger.debug('Web platform detected, showing reCAPTCHA');
        // WebRecaptcha.showRecaptcha();

        // // Check if reCAPTCHA is available
        // if (!WebRecaptcha.isRecaptchaAvailable()) {
        //   error.value = 'reCAPTCHA is not properly initialized';
        //   isLoading.value = false;
        //   return;
        // }

        // try {
        //   // Use the enhanced web-specific auth service
        //   final verId = await authService.verifyPhone(formattedPhoneNumber);
        //   verificationId.value = verId;
        //   _verificationId = verId;

        //   // Hide reCAPTCHA after verification
        //   WebRecaptcha.hideRecaptcha();

        //   Get.toNamed('/otp');
        // } catch (e) {
        //   AppLogger.error('Web phone verification failed', e);
        //   error.value = 'Verification failed: ${e.toString()}';

        //   // If error occurs, reset reCAPTCHA
        //   WebRecaptcha.resetRecaptcha();
        // }
      } else {
        // Original mobile-specific implementation
        await _auth.verifyPhoneNumber(
          phoneNumber: formattedPhoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (credential) async {
            await _handleVerificationCompleted(credential);
          },
          verificationFailed: (e) {
            error.value = 'Verification failed: ${e.message}';
            isLoading.value = false;
          },
          codeSent: (String verId, int? resendToken) {
            verificationId.value = verId;
            _verificationId = verId;
            Get.toNamed('/otp');
          },
          codeAutoRetrievalTimeout: (String verId) {
            verificationId.value = verId;
            _verificationId = verId;
          },
        );
      }
    } catch (e) {
      AppLogger.error('Error in registerWithPhone: ${e.toString()}');
      error.value = e.toString();
    } finally {
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

      if (kIsWeb) {
        // Use the enhanced web auth service for OTP verification
        final userCredential =
            await authService.verifyOTP(verificationId.value, otp);
        if (userCredential.user != null) {
          await _handleVerifiedUser(userCredential.user!);
        } else {
          throw Exception('Failed to get user after OTP verification');
        }
      } else {
        // Original implementation
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId.value,
          smsCode: otp,
        );
        await _handleVerificationCompleted(credential);
      }
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

      await _handleVerifiedUser(firebaseUser);
    } catch (e) {
      AppLogger.error('Error in verification: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Extracted common user handling logic to avoid code duplication
  Future<void> _handleVerifiedUser(User firebaseUser) async {
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
      AppLogger.info('Navigating to join a coop screen');
      await Get.delete<NearbyCooperativesController>(force: true);
      Get.put(NearbyCooperativesController());
      Get.offAllNamed('/nearby-cooperatives');
    }
  }

  void clearError() {
    error.value = null;
  }
}
