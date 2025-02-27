import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends GetView<AuthController> {
  final VoidCallback? onBack;

  const RegisterScreen({
    Key? key,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator at top
        LinearProgressIndicator(
          value: 1.0, // Final step
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mitra animation
                        Lottie.asset(
                          'assets/animations/mitra_avatar.json',
                          height: 180,
                        ),

                        // Title text
                        Text(
                          'One Last Step!',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),
                        Text(
                          'Let me know your phone number to verify you',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Phone input with animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CustomTextField(
                            label: 'Phone Number',
                            hint: 'Enter your phone number',
                            controller: controller
                                .phoneNumberController, // Use the controller from AuthController
                            isPhone: true,
                            prefixIcon: Icons.phone_outlined,
                            onChanged: (value) {
                              print(controller.phoneNumberController.text);
                              controller.clearError();
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Error message
                        Obx(() => controller.error.value != null
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red[700], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        controller.error.value!,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink()),

                        const Spacer(),

                        // Navigation buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                              onPressed:
                                  onBack ?? () => Get.toNamed('/auth-choice'),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Go Back'),
                            ),
                            Obx(() => ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.registerWithPhone,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Verify Phone',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
