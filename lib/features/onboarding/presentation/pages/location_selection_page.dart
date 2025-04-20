import 'package:cropconnect/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LocationSelectionPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;

  const LocationSelectionPage({
    super.key,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onboardingController = Get.find<OnboardingController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, theme.scaffoldBackgroundColor],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.97, end: 1.0),
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
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
                        'assets/animations/location.json',
                        width: 160,
                        height: 160,
                        frameRate: FrameRate(60),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Container(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'Where are you from?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Better label for state dropdown
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Select your state',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.primaryColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(11),
                                  bottomLeft: Radius.circular(11),
                                ),
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 0,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.map_outlined,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Obx(() => DropdownButton<String>(
                                    value: onboardingController
                                            .selectedState.value.isEmpty
                                        ? null
                                        : onboardingController
                                            .selectedState.value,
                                    hint: Text(
                                      'Select State',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    isExpanded: true,
                                    underline: const SizedBox.shrink(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    borderRadius: BorderRadius.circular(12),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: theme.primaryColor,
                                    ),
                                    items: onboardingController.stateCities.keys
                                        .map((String state) {
                                      return DropdownMenuItem<String>(
                                        value: state,
                                        child: Text(
                                          state,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        onboardingController.setState(newValue);
                                      }
                                    },
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Select your city/district',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.primaryColor.withOpacity(0.8),
                        ),
                      ),
                    ),

                    Obx(() {
                      final isStateEmpty =
                          onboardingController.selectedState.value.isEmpty;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isStateEmpty
                                ? theme.disabledColor.withOpacity(0.2)
                                : theme.primaryColor.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color:
                              isStateEmpty ? Colors.grey.shade50 : Colors.white,
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isStateEmpty
                                      ? theme.disabledColor.withOpacity(0.1)
                                      : theme.primaryColor.withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(11),
                                    bottomLeft: Radius.circular(11),
                                  ),
                                  border: Border.all(
                                    color: Colors.transparent,
                                    width: 0,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.location_city_outlined,
                                    color: isStateEmpty
                                        ? theme.disabledColor
                                        : theme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: onboardingController
                                          .selectedCity.value.isEmpty
                                      ? null
                                      : onboardingController.selectedCity.value,
                                  hint: Text(
                                    isStateEmpty
                                        ? 'Select state first'
                                        : 'Select City/District',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isStateEmpty
                                          ? theme.disabledColor
                                          : theme.hintColor,
                                    ),
                                  ),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  borderRadius: BorderRadius.circular(12),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: isStateEmpty
                                        ? theme.disabledColor
                                        : theme.primaryColor,
                                  ),
                                  items: onboardingController
                                      .getCitiesForState(onboardingController
                                          .selectedState.value)
                                      .map((String city) {
                                    return DropdownMenuItem<String>(
                                      value: city,
                                      child: Text(
                                        city,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: isStateEmpty
                                      ? null
                                      : (String? newValue) {
                                          if (newValue != null) {
                                            onboardingController
                                                .setCity(newValue);
                                          }
                                        },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
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

                  // Next button with visual feedback based on selection state
                  Obx(() {
                    final isComplete =
                        onboardingController.selectedState.value.isNotEmpty &&
                            onboardingController.selectedCity.value.isNotEmpty;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isComplete
                            ? [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: isComplete ? onNext : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: isComplete ? 2 : 0,
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Next',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
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
    );
  }
}
