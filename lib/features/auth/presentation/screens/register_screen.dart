import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Register',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your phone number to create an account',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Name',
                hint: 'Enter your name',
                controller: TextEditingController(),
                isPhone: false,
                onChanged: (value) {
                  controller.name.value = value;
                  controller.clearError();
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Phone Number',
                hint: 'Enter your phone number',
                controller: TextEditingController(),
                isPhone: true,
                onChanged: (value) {
                  controller.phoneNumber.value = value;
                  controller.clearError();
                },
              ),
              const SizedBox(height: 8),
              // Obx only for error message
              Obx(() => controller.error.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        controller.error.value!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : const SizedBox()),
              const SizedBox(height: 24),
              // Obx only for loading button
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.registerWithPhone,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Continue'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
