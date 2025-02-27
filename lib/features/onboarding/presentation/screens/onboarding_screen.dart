import 'package:cropconnect/core/services/locale/locale_service.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/auth/presentation/screens/register_screen.dart';
import 'package:cropconnect/features/onboarding/domain/models/crop_model.dart';
import 'package:cropconnect/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final PageController _pageController = PageController();
  final onboardingController = Get.put(OnboardingController());

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onLanguageSelected(String language) {
    Get.find<LocaleService>().changeLocale(language);
    onboardingController.setLanguage(language);
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => LinearProgressIndicator(
                  value: onboardingController.progress.value,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                )),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _LanguageSelectionPage(
                    onLanguageSelected: _onLanguageSelected,
                  ),
                  _NameInputPage(
                    onNext: () {
                      _pageController.animateToPage(
                        2,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    onBack: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                      onboardingController.resetLanguage();
                    },
                  ),
                  _LocationSelectionPage(
                    onBack: () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    onNext: () {
                      _pageController.animateToPage(
                        3,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  _CropSelectionPage(
                    onBack: () {
                      _pageController.animateToPage(
                        2,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    onNext: () {
                      _pageController.animateToPage(
                        4,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  RegisterScreen(
                    onBack: () {
                      _pageController.animateToPage(
                        3,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                      onboardingController.progress.value = 0.8;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelectionPage extends StatelessWidget {
  final Function(String) onLanguageSelected;

  const _LanguageSelectionPage({
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/mitra_avatar.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 32),
            Text(
              'Choose Your Language',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _LanguageCard(
                    title: 'English',
                    subtitle: 'I speak English',
                    icon: '🇬🇧',
                    onTap: () => onLanguageSelected('en'),
                  ),
                  const SizedBox(height: 16),
                  _LanguageCard(
                    title: 'हिंदी',
                    subtitle: 'मैं हिंदी बोलता/बोलती हूं',
                    icon: '🇮🇳',
                    onTap: () => onLanguageSelected('hi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameInputPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final onboardingController = Get.find<OnboardingController>();
  final _formKey = GlobalKey<FormState>();

  _NameInputPage({required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/mitra_avatar.json',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 32),
              Text(
                'What should I call you?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                  onChanged: (value) => onboardingController.setName(value),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    errorStyle: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        onBack();
                        onboardingController.resetLanguage();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go back'),
                    ),
                    Obx(() => ElevatedButton(
                          onPressed:
                              onboardingController.name.value.trim().isEmpty
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        onNext();
                                      }
                                    },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Next'),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward,
                                  size: 16, color: AppColors.backgroundLight),
                            ],
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSelectionPage extends StatelessWidget {
  final VoidCallback onBack;
  final onboardingController = Get.find<OnboardingController>();
  final VoidCallback onNext;
  _LocationSelectionPage({
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/location.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 32),
            Text(
              'Where are you from?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Obx(() => DropdownButton<String>(
                          value:
                              onboardingController.selectedState.value.isEmpty
                                  ? null
                                  : onboardingController.selectedState.value,
                          hint: Text('Select State'),
                          isExpanded: true,
                          underline: SizedBox(),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: BorderRadius.circular(16),
                          items: onboardingController.stateCities.keys
                              .map((String state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Text(state),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              onboardingController.setState(newValue);
                            }
                          },
                        )),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButton<String>(
                          value: onboardingController.selectedCity.value.isEmpty
                              ? null
                              : onboardingController.selectedCity.value,
                          hint: Text('Select City'),
                          isExpanded: true,
                          underline: SizedBox(),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: BorderRadius.circular(16),
                          items: onboardingController
                              .getCitiesForState(
                                  onboardingController.selectedState.value)
                              .map((String city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged:
                              onboardingController.selectedState.value.isEmpty
                                  ? null
                                  : (String? newValue) {
                                      if (newValue != null) {
                                        onboardingController.setCity(newValue);
                                      }
                                    },
                        ),
                      )),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Change Name'),
                      ),
                      Obx(() => ElevatedButton(
                            onPressed: onboardingController
                                        .selectedState.value.isNotEmpty &&
                                    onboardingController
                                        .selectedCity.value.isNotEmpty
                                ? onNext
                                : null,
                            child: Text('Next'),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropSelectionPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final onboardingController = Get.find<OnboardingController>();

  _CropSelectionPage({
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Lottie.asset(
              'assets/animations/mitra_avatar.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 32),
            Text(
              'What crops do you grow?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Select all that apply',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: MediaQuery.of(context).size.height * 0.4,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: onboardingController.availableCrops.length,
                itemBuilder: (context, index) {
                  final crop = onboardingController.availableCrops[index];
                  return Obx(() {
                    final isSelected =
                        onboardingController.selectedCrops.contains(crop.id);
                    return _CropCard(
                      crop: crop,
                      isSelected: isSelected,
                      onTap: () {
                        print(onboardingController.selectedCrops);
                        onboardingController.toggleCropSelection(crop.id);
                      },
                    );
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Change Location'),
                  ),
                  Obx(() => ElevatedButton(
                        onPressed: onboardingController.selectedCrops.isNotEmpty
                            ? onNext
                            : null,
                        child: Text('Next'),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final CropModel crop;
  final bool isSelected;
  final VoidCallback onTap;

  const _CropCard({
    required this.crop,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(75),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    crop.imageUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                  if (isSelected)
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              crop.name,
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
