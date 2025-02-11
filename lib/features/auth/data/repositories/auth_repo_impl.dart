import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/features/auth/data/services/auth_service.dart';
import 'package:cropconnect/features/auth/domain/model/user_model.dart';
import 'package:cropconnect/features/auth/domain/repositories/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String KEY_IS_LOGGED_IN = 'is_logged_in';

  final FirebaseAuthService _authService;
  final FirebaseFirestore _firestore;
  final UserStorageService _storageService;
  final SharedPreferences _prefs;

  // ignore: unused_field
  String? _verificationId;

  AuthRepositoryImpl(
      this._authService, this._firestore, this._storageService, this._prefs);

  @override
  Future<String> registerWithPhone(String phoneNumber, String name) async {
    try {
      final verificationId = await _authService.verifyPhone(phoneNumber);
      _verificationId = verificationId; // Store it locally if needed
      return verificationId;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> verifyOTP(
      String otp, String verificationId, String name) async {
    try {
      final UserCredential userCredential = await _authService.verifyOTP(
        verificationId,
        otp,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('User registration failed: No user data received');
      }

      final userData = UserModel(
        id: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        createdAt: DateTime.now(),
        name: name,
      );

      await _firestore.collection('users').doc(user.uid).set(userData.toMap());
      await _storageService.saveUser(userData);
      await _prefs.setBool(KEY_IS_LOGGED_IN, true);

      return userData;
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  @override
  bool isUserLoggedIn() {
    return _prefs.getBool(KEY_IS_LOGGED_IN) ?? false;
  }
}
