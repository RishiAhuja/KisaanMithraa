// lib/features/auth/data/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // RecaptchaVerifier? _recaptchaVerifier;

  User? get currentUser => _auth.currentUser;

  Future<String> verifyPhone(String phoneNumber) async {
    AppLogger.info('Initiating phone verification for: $phoneNumber');
    Completer<String> completer = Completer<String>();

    try {
      if (kIsWeb) {
        // For web platform, use the pre-configured reCAPTCHA from index.html
        AppLogger.debug('Using web implementation for phone verification');

        // // Access the window.recaptchaVerifier that was set up in index.html
        // final recaptchaVerifier = js.context.hasProperty('recaptchaVerifier')
        //     ? js.context['recaptchaVerifier']
        //     : null;

        // if (recaptchaVerifier == null) {
        //   AppLogger.error('reCAPTCHA verifier not found in window object');
        //   throw Exception('reCAPTCHA configuration missing');
        // }

        // await _auth.verifyPhoneNumber(
        //   phoneNumber: phoneNumber,
        //   verificationCompleted: (PhoneAuthCredential credential) async {
        //     AppLogger.success('Auto verification completed for: $phoneNumber');
        //     await _auth.signInWithCredential(credential);
        //   },
        //   verificationFailed: (FirebaseAuthException e) {
        //     AppLogger.error('Phone verification failed', e, e.stackTrace);
        //     completer.completeError(e);
        //   },
        //   codeSent: (String verificationId, int? resendToken) {
        //     AppLogger.success('Verification code sent to: $phoneNumber');
        //     completer.complete(verificationId);
        //   },
        //   codeAutoRetrievalTimeout: (String verificationId) {
        //     if (!completer.isCompleted) {
        //       AppLogger.warning('Auto retrieval timeout for: $phoneNumber');
        //       completer.complete(verificationId);
        //     }
        //   },
        // );
      } else {
        // Mobile-specific implementation (existing code)
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            AppLogger.success('Auto verification completed for: $phoneNumber');
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            AppLogger.error('Phone verification failed', e, e.stackTrace);
            completer.completeError(e);
          },
          codeSent: (String verificationId, int? resendToken) {
            AppLogger.success(
                'Verification code sent successfully to: $phoneNumber');
            completer.complete(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (!completer.isCompleted) {
              AppLogger.warning('Auto retrieval timeout for: $phoneNumber');
              completer.complete(verificationId);
            }
          },
          forceResendingToken: null,
        );
      }

      final result = await completer.future;
      AppLogger.debug('Phone verification process completed');
      return result;
    } catch (e) {
      AppLogger.error('Unexpected error during phone verification', e);
      throw Exception('Phone verification failed: ${e.toString()}');
    }
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    try {
      AppLogger.info('Starting OTP verification process');

      if (verificationId.isEmpty || otp.isEmpty) {
        AppLogger.error('Invalid verification parameters',
            'VerificationId or OTP is empty');
        throw FirebaseAuthException(
            code: 'invalid-verification-parameters',
            message: 'VerificationId or OTP cannot be empty');
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      AppLogger.debug('Attempting to sign in with credential');
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        AppLogger.success('OTP verification successful');
        return userCredential;
      } else {
        throw FirebaseAuthException(
            code: 'null-user-credential',
            message: 'Failed to get user credentials after sign in');
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase Auth Exception', e, e.stackTrace);
      throw Exception('OTP verification failed: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Unexpected error during OTP verification', e, stackTrace);
      throw Exception('OTP verification failed: $e');
    }
  }
}
