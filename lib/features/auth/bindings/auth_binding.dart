import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:cropconnect/features/auth/data/services/auth_service.dart';
import 'package:cropconnect/features/auth/domain/repositories/auth_repo.dart';
import 'package:cropconnect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // Register services
    Get.put(FirebaseAuthService(), permanent: true);
    Get.put(FirebaseFirestore.instance, permanent: true);
    Get.put(UserStorageService(), permanent: true);

    // SharedPreferences should already be initialized in main()
    final prefs = Get.find<SharedPreferences>();

    // Register repository
    final authRepo = AuthRepositoryImpl(
      Get.find<FirebaseAuthService>(),
      Get.find<FirebaseFirestore>(),
      Get.find<UserStorageService>(),
      prefs,
    );
    Get.put<AuthRepository>(authRepo, permanent: true);

    // Register controller
    Get.put<AuthController>(
      AuthController(Get.find<AuthRepository>()),
      permanent: true,
    );
  }
}
