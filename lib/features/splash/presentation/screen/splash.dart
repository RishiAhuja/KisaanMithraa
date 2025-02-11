import 'package:cropconnect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<void>(
          future: initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error initializing app: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> initializeApp() async {
    try {
      final controller = Get.find<AuthController>();
      await controller.initializeAuth();
    } catch (e) {
      print('Initialization error: $e');
      await Future.delayed(
          const Duration(seconds: 1)); // Add small delay before navigation
      Get.offAllNamed('/register');
    }
  }
}
