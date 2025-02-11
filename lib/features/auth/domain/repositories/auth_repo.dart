import 'package:cropconnect/features/auth/domain/model/user_model.dart';

abstract class AuthRepository {
  Future<String> registerWithPhone(String phoneNumber, String name);
  Future<UserModel> verifyOTP(String otp, String verificationId, String name);
  bool isUserLoggedIn();
}
