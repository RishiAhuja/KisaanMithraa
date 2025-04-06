import 'package:cropconnect/features/auth/presentation/controllers/debug_auth_controller.dart';
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
    final RxBool useBackDoor = false.obs;

    final authController = controller;
    final debugController = Get.put(DebugAuthController());

    return Column(
      children: [
        LinearProgressIndicator(
          value: 1.0,
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
                              debugController.phoneNumberController.text =
                                  value;
                              controller.clearError();
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        Obx(() {
                          final error = useBackDoor.value
                              ? debugController.error.value
                              : authController.error.value;

                          return error != null
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
                                          error,
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink();
                        }),

                        Obx(() => Transform.scale(
                              scale: 0.7,
                              child: Switch(
                                value: useBackDoor.value,
                                activeColor: Colors.amber,
                                activeTrackColor: Colors.amber.shade200,
                                onChanged: (value) {
                                  useBackDoor.value = value;
                                  if (value) {
                                    Get.snackbar(
                                      'Debug Mode',
                                      'Debug authentication enabled',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.amber,
                                      colorText: Colors.black,
                                      duration: const Duration(seconds: 1),
                                    );
                                  }
                                },
                              ),
                            )),

                        const Spacer(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                              onPressed:
                                  onBack ?? () => Get.toNamed('/auth-choice'),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Go Back'),
                            ),
                            Obx(() {
                              final isLoading = useBackDoor.value
                                  ? debugController.isLoading.value
                                  : authController.isLoading.value;

                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (useBackDoor.value) {
                                          await debugController
                                              .debugDirectLogin(debugController
                                                  .phoneNumberController.text);
                                        } else {
                                          await authController
                                              .registerWithPhone();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor:
                                      useBackDoor.value ? Colors.amber : null,
                                ),
                                child: isLoading
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
                                    : Text(
                                        useBackDoor.value
                                            ? 'Debug Login'
                                            : 'Verify Phone',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: useBackDoor.value
                                                  ? Colors.black
                                                  : null,
                                            ),
                                      ),
                              );
                            }),
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
