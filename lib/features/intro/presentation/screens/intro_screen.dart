import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildPageViewModel(
        title: "Welcome to KisaanMithraa",
        description: "Empowering farmers with smart solutions.",
        backgroundColor: AppColors.splashGreen,
      ),
      buildPageViewModel(
        title: "AI-Powered Assistance",
        description: "Get expert farming insights at your fingertips.",
        backgroundColor: AppColors.splashYellow,
      ),
      buildPageViewModel(
        title: "Connect & Collaborate",
        description: "Join cooperatives and grow together.",
        backgroundColor: AppColors.splashOrange,
      ),
      buildPageViewModel(
        title: "Marketplace at Fingertips",
        description: "Buy, sell and trade agriculture essentials easily.",
        backgroundColor: AppColors.splashLightGreen,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IntroductionScreen(
        pages: pages,
        showSkipButton: true,
        skip: Text("Skip",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        next: Text("Next",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        done: Text("Next",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        onDone: () => Get.offAllNamed('/auth-choice'),
        onSkip: () => Get.offAllNamed('/auth-choice'),
        dotsDecorator: DotsDecorator(
          size: const Size.square(8.0),
          activeSize: const Size(20.0, 8.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          activeColor: Colors.green,
          color: Colors.grey.withOpacity(0.5),
          spacing: const EdgeInsets.symmetric(horizontal: 4.0),
        ),
        controlsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        globalFooter: const SizedBox(height: 16),
      ),
    );
  }

  PageViewModel buildPageViewModel({
    required String title,
    required String description,
    required Color backgroundColor,
  }) {
    return PageViewModel(
      titleWidget: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      bodyWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black54,
          ),
        ),
      ),
      image: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            height: 420,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 72.0),
                child: SvgPicture.asset(
                  "assets/logo/logo_white.svg",
                  height: 25,
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  "assets/splash/farmer.png",
                  height: 283,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ],
          ),
        ],
      ),
      decoration: const PageDecoration(
        fullScreen: false,
        contentMargin: EdgeInsets.only(top: 16),
        titlePadding: EdgeInsets.only(top: 24, bottom: 8),
        bodyPadding: EdgeInsets.symmetric(horizontal: 20),
        pageColor: AppColors.backgroundLight,
        bodyFlex: 1,
        imageFlex: 3,
        bodyAlignment: Alignment.center,
        imageAlignment: Alignment.topCenter,
      ),
    );
  }
}
