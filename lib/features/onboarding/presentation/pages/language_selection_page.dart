import 'package:cropconnect/core/services/locale/locale_service.dart';
import 'package:cropconnect/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:cropconnect/features/onboarding/presentation/widgets/language_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionPage extends StatelessWidget {
  final Function(String) onLanguageSelected;

  const LanguageSelectionPage({
    Key? key,
    required this.onLanguageSelected,
  }) : super(key: key);

  void _handleLanguageSelection(String language) {
    Get.find<LocaleService>().changeLocale(language);
    Get.find<OnboardingController>().setLanguage(language);
    onLanguageSelected(language);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Theme.of(context).scaffoldBackgroundColor],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation with background
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                padding: const EdgeInsets.all(20),
                child: Lottie.asset(
                  'assets/animations/mitra_avatar.json',
                  width: 160,
                  height: 160,
                ),
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
                child: Text(
                  appLocalizations?.chooseLanguage ?? 'Choose Your Language',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),

              const SizedBox(height: 40),

              Column(
                children: [
                  LanguageCard(
                    title: 'English',
                    subtitle: 'I speak English',
                    icon: '🇬🇧',
                    onTap: () => _handleLanguageSelection('en'),
                  ),
                  const SizedBox(height: 16),
                  LanguageCard(
                    title: 'हिंदी',
                    subtitle: 'मैं हिंदी बोलता/बोलती हूं',
                    icon: '🇮🇳',
                    onTap: () => _handleLanguageSelection('hi'),
                  ),
                  const SizedBox(height: 16),
                  LanguageCard(
                    title: 'ਪੰਜਾਬੀ',
                    subtitle: 'ਮੈਂ ਪੰਜਾਬੀ ਬੋਲਦਾ/ਬੋਲਦੀ ਹਾਂ',
                    icon: '🇮🇳',
                    onTap: () => _handleLanguageSelection('pa'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
