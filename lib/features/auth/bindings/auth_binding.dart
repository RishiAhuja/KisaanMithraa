import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:cropconnect/features/auth/data/services/auth_service.dart';
import 'package:cropconnect/features/auth/domain/repositories/auth_repo.dart';
import 'package:cropconnect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cropconnect/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:cropconnect/features/profile/controller/profile_controller.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    try {
      // 1. Core Services
      Get.put(FirebaseAuthService(), permanent: true);
      Get.put(FirebaseFirestore.instance, permanent: true);
      Get.put(UserStorageService(), permanent: true);
      Get.put(OnboardingController(), permanent: true);

      // 2. Initialize Shared Preferences
      final prefs = await Get.putAsync(() => SharedPreferences.getInstance());
      final firestore = Get.find<FirebaseFirestore>();
      final userStorage = Get.find<UserStorageService>();

      // 3. Register Profile Controller first
      Get.put(
        ProfileController(userStorage, firestore),
        permanent: true,
      );

      // 4. Initialize Auth Repository
      final authRepo = AuthRepositoryImpl(
        Get.find<FirebaseAuthService>(),
        firestore,
        userStorage,
        prefs,
      );
      Get.put<AuthRepository>(authRepo, permanent: true);

      // 5. Initialize Auth Controller last
      Get.put<AuthController>(
        AuthController(authRepo),
        permanent: true,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error in AuthBinding: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}
