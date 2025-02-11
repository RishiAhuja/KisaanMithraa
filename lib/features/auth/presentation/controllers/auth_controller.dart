import 'package:cropconnect/features/auth/domain/model/user_model.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import '../../domain/repositories/auth_repo.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final phoneNumber = ''.obs;
  final isLoading = false.obs;
  final name = ''.obs;
  final error = Rx<String?>(null);
  final verificationId = ''.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  AuthController(this._authRepository);

  Future<bool> initializeAuth() async {
    try {
      AppLogger.info('Initializing authentication state...');
      final isLoggedIn = await _authRepository.isUserLoggedIn();
      if (isLoggedIn) {
        AppLogger.info('User is logged in, navigating to home screen');
        await Get.offAllNamed('/home');
        return true;
      } else {
        AppLogger.info('User is not logged in, navigating to register screen');
        await Get.offAllNamed('/register');
        return false;
      }
    } catch (e) {
      AppLogger.error('Failed to initialize auth state', e);
      await Get.offAllNamed('/register');
      return false;
    }
  }

  Future<void> registerWithPhone() async {
    try {
      if (phoneNumber.value.isEmpty) {
        throw Exception('Phone number cannot be empty');
      }
      if (name.value.isEmpty) {
        throw Exception('Name cannot be empty');
      }

      isLoading.value = true;
      error.value = null;

      // Get the verification ID from the repository
      final verId = await _authRepository.registerWithPhone(phoneNumber.value,
          name.value // Use name.value instead of name.toString()
          );

      verificationId.value = verId;
      Get.toNamed('/otp');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(String otp) async {
    try {
      isLoading.value = true;
      error.value = null;

      final userData = await _authRepository.verifyOTP(
          otp,
          verificationId.value,
          name.value // Use name.value instead of name.toString()
          );

      user.value = userData;
      AppLogger.info('redirecting to home');
      Get.offAllNamed('/home');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    error.value = null;
  }
}
