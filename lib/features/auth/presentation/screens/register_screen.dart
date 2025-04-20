import 'package:cropconnect/features/auth/presentation/controllers/debug_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends GetView<AuthController> {
  final VoidCallback? onBack;
  final bool isPartOfOnboarding;

  const RegisterScreen({
    Key? key,
    this.onBack,
    this.isPartOfOnboarding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RxBool useBackDoor = false.obs;
    final theme = Theme.of(context);
    final authController = controller;
    final debugController = Get.put(DebugAuthController());

    return Column(
      children: [
        if (!isPartOfOnboarding)
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.primaryColor,
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Mitra animation with styled container
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.primaryColor.withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Lottie.asset(
                              'assets/animations/mitra_avatar.json',
                              width: 140,
                              height: 140,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title with decoration - matches onboarding styling
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Column(
                            children: [
                              Text(
                                'One Last Step!',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'We\'ll send a verification code to this number',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Phone input field with matching styling
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CustomTextField(
                            label: 'Phone Number',
                            hint: 'Enter your phone number',
                            controller: controller.phoneNumberController,
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

                        // Error message with consistent styling
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
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
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

                        // More subtle debug switch
                        Obx(() => Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Debug',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    Transform.scale(
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
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: Colors.amber,
                                              colorText: Colors.black,
                                              duration:
                                                  const Duration(seconds: 1),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),

                        const Spacer(),

                        // Navigation buttons - already consistent with onboarding
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed:
                                  onBack ?? () => Get.toNamed('/auth-choice'),
                              icon: const Icon(Icons.arrow_back_rounded,
                                  size: 18),
                              label: Text(
                                'Back',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                side: BorderSide(
                                  color: theme.primaryColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            Obx(() {
                              final isLoading = useBackDoor.value
                                  ? debugController.isLoading.value
                                  : authController.isLoading.value;

                              final isEnabled = authController
                                      .phoneNumberController.text.length >=
                                  10;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: isEnabled && !isLoading
                                      ? [
                                          BoxShadow(
                                            color: (useBackDoor.value
                                                    ? Colors.amber
                                                    : theme.primaryColor)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading || !isEnabled
                                      ? null
                                      : () async {
                                          if (useBackDoor.value) {
                                            await debugController
                                                .debugDirectLogin(
                                                    debugController
                                                        .phoneNumberController
                                                        .text);
                                          } else {
                                            await authController
                                                .registerWithPhone();
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: isEnabled && !isLoading ? 2 : 0,
                                    backgroundColor: useBackDoor.value
                                        ? Colors.amber
                                        : theme.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isLoading)
                                        SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              useBackDoor.value
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      else
                                        Text(
                                          useBackDoor.value
                                              ? 'Debug Login'
                                              : 'Verify Phone',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                            color: useBackDoor.value
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      if (!isLoading) const SizedBox(width: 8),
                                      if (!isLoading)
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                          color: useBackDoor.value
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                    ],
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
