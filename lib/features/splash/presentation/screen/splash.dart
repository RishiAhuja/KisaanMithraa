import 'package:cropconnect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeApp();
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> initializeApp() async {
    try {
      final authController = Get.find<AuthController>();
      await authController.initializeAuth();
    } catch (e) {
      AppLogger.error('Initialization error: $e');
    }
  }
}
