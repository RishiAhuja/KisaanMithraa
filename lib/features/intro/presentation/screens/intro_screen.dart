import 'package:cropconnect/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends GetView<AuthController> {
  final List<PageViewModel> pages = [
    PageViewModel(
      title: "Welcome to Kisan Mitra",
      body:
          "Your AI-powered farming assistant that helps you make better farming decisions",
      image: Center(
        child: Image.asset("assets/images/intro/welcome.png", height: 250.0),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
        ),
        bodyTextStyle: TextStyle(fontSize: 16.0),
        pageColor: Colors.white,
      ),
    ),
    PageViewModel(
      title: "Smart Farming Advice",
      body:
          "Get personalized recommendations for crops, pest control, and more in your language",
      image: Center(
        child: Image.asset("assets/images/intro/advice.png", height: 250.0),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
        ),
        bodyTextStyle: TextStyle(fontSize: 16.0),
        pageColor: Colors.white,
      ),
    ),
    PageViewModel(
      title: "Voice Enabled",
      body: "Simply speak to your assistant in Hindi, Punjabi, or English",
      image: Center(
        child: Image.asset("assets/images/intro/voice.png", height: 250.0),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
        ),
        bodyTextStyle: TextStyle(fontSize: 16.0),
        pageColor: Colors.white,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: pages,
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Text("Next"),
      done: const Text("Get Started"),
      onDone: () {
        Get.offAllNamed('/auth-choice');
      },
      onSkip: () {
        Get.offAllNamed('/auth-choice');
      },
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
