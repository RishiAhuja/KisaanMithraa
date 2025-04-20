import 'package:cropconnect/features/onboarding/domain/models/crop_model.dart';
import 'package:cropconnect/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:cropconnect/features/onboarding/presentation/widgets/crop_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CropSelectionPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;

  const CropSelectionPage({
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              const SizedBox(height: 16),

              // Title with decoration
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'What crops do you grow?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Obx(() {
                final hasRecommended =
                    onboardingController.selectedState.isNotEmpty &&
                        onboardingController.getRecommendedCrops().isNotEmpty;

                if (!hasRecommended) return const SizedBox.shrink();

                return Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Recommended tab
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onboardingController
                                .showRecommended.value = true,
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color:
                                    onboardingController.showRecommended.value
                                        ? theme.primaryColor
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow:
                                    onboardingController.showRecommended.value
                                        ? [
                                            BoxShadow(
                                              color: theme.primaryColor
                                                  .withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.recommend,
                                      size: 16,
                                      color: onboardingController
                                              .showRecommended.value
                                          ? Colors.white
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Local Crops',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: onboardingController
                                                .showRecommended.value
                                            ? Colors.white
                                            : Colors.grey[700],
                                        fontWeight: onboardingController
                                                .showRecommended.value
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // All crops tab
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onboardingController
                                .showRecommended.value = false,
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color:
                                    !onboardingController.showRecommended.value
                                        ? theme.primaryColor
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow:
                                    !onboardingController.showRecommended.value
                                        ? [
                                            BoxShadow(
                                              color: theme.primaryColor
                                                  .withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.grid_view_rounded,
                                      size: 16,
                                      color: !onboardingController
                                              .showRecommended.value
                                          ? Colors.white
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'All Crops',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: !onboardingController
                                                .showRecommended.value
                                            ? Colors.white
                                            : Colors.grey[700],
                                        fontWeight: !onboardingController
                                                .showRecommended.value
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Row(
                  children: [
                    // Wrap the text in a container with centered alignment
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select crops to grow:",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    // Badge with proper alignment
                    Obx(() {
                      final selectedCount =
                          onboardingController.selectedCrops.length;
                      final hasSelections = selectedCount > 0;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasSelections
                              ? theme.primaryColor
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: hasSelections
                              ? [
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Center align icon and text
                          children: [
                            // Icon that matches the selection state
                            Icon(
                              hasSelections
                                  ? Icons.check_circle
                                  : Icons.crop_square_outlined,
                              size: 16,
                              color: hasSelections
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),

                            const SizedBox(width: 6),

                            // Counter text
                            Text(
                              hasSelections
                                  ? '$selectedCount ${selectedCount == 1 ? 'crop' : 'crops'}'
                                  : 'None',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: hasSelections
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Crop grid container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Obx(() {
                  final List<CropModel> cropsToShow =
                      onboardingController.showRecommended.value &&
                              onboardingController.selectedState.isNotEmpty
                          ? onboardingController.getRecommendedCrops()
                          : onboardingController.availableCrops;

                  if (cropsToShow.isEmpty) {
                    return Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey[400],
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No recommended crops found',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => onboardingController
                                .showRecommended.value = false,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'View all crops',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Break into pairs for two-column layout
                  final int itemCount = (cropsToShow.length / 2).ceil();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      final int firstIndex = index * 2;
                      final int secondIndex = firstIndex + 1;

                      // First crop in the row
                      final firstCrop = cropsToShow[firstIndex];
                      final hasSecondCrop = secondIndex < cropsToShow.length;
                      final secondCrop =
                          hasSecondCrop ? cropsToShow[secondIndex] : null;

                      return Row(
                        children: [
                          // First crop card (always present)
                          Expanded(
                            child: Obx(() {
                              final isSelected = onboardingController
                                  .selectedCrops
                                  .contains(firstCrop.id);
                              final isRecommended = onboardingController
                                      .selectedState.isNotEmpty &&
                                  firstCrop.isGrownIn(
                                      onboardingController.selectedState.value);

                              return CropCard(
                                crop: firstCrop,
                                isSelected: isSelected,
                                isRecommended: isRecommended &&
                                    !onboardingController.showRecommended.value,
                                onTap: () => onboardingController
                                    .toggleCropSelection(firstCrop.id),
                              );
                            }),
                          ),

                          const SizedBox(width: 8),

                          // Second crop card (may not exist for odd number of crops)
                          Expanded(
                            child: hasSecondCrop
                                ? Obx(() {
                                    final isSelected = onboardingController
                                        .selectedCrops
                                        .contains(secondCrop!.id);
                                    final isRecommended = onboardingController
                                            .selectedState.isNotEmpty &&
                                        secondCrop.isGrownIn(
                                            onboardingController
                                                .selectedState.value);

                                    return CropCard(
                                      crop: secondCrop,
                                      isSelected: isSelected,
                                      isRecommended: isRecommended &&
                                          !onboardingController
                                              .showRecommended.value,
                                      onTap: () => onboardingController
                                          .toggleCropSelection(secondCrop.id),
                                    );
                                  })
                                : const SizedBox(), // Empty placeholder for balance
                          ),
                        ],
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Navigation buttons
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
                  Obx(() {
                    final isEnabled =
                        onboardingController.selectedCrops.isNotEmpty;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isEnabled
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
                        onPressed: isEnabled ? onNext : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: isEnabled ? 2 : 0,
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
                            const Icon(
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
