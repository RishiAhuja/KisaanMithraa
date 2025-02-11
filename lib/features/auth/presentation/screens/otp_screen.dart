import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../controllers/auth_controller.dart';

class OTPScreen extends GetView<AuthController> {
  // ignore: use_super_parameters
  const OTPScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _pinController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verify Phone',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the code sent to ${controller.phoneNumber.value}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),
              Pinput(
                length: 6,
                onCompleted: (pin) => controller.verifyOTP(pin),
                onChanged: (_) => controller.clearError(),
              ),
              const SizedBox(height: 8),
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
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            // Get the current PIN value and verify it
                            final pin =
                                _pinController.text; // Add this controller
                            if (pin.length == 6) {
                              controller.verifyOTP(pin);
                            }
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Verify'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
