import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:cropconnect/core/utils/platform_helper.dart';

class SpeechService extends GetxService {
  // Singleton pattern
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  // Reactive variables to track state
  final RxBool isListening = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxBool isInitialized = false.obs;

  // Stream for volume levels that will drive the animation
  final _volumeStreamController = StreamController<double>.broadcast();
  Stream<double> get volumeStream => _volumeStreamController.stream;

  // Timer for simulating wave patterns during speech
  Timer? _volumeSimulationTimer;

  // Check if speech recognition is available
  Future<bool> isSpeechAvailable() async {
    if (!isInitialized.value) {
      await initializeSpeech();
    }
    return speech.isAvailable;
  }

  // Language settings
  static const Map<String, String> languageCodes = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'pa': 'pa-IN',
  };

  // Initialize TTS and STT
  Future<void> initializeSpeech() async {
    try {
      // Check if running on web
      if (PlatformHelper.isWeb) {
        // Web-specific initialization
        isInitialized.value = true;
        return;
      }

      // Mobile-specific initialization
      await speech.initialize(
        onStatus: (status) {
          if (status == 'notListening') {
            isListening.value = false;
            _volumeStreamController.add(0.0);
          }
        },
        onError: (error) {
          isListening.value = false;
          _volumeStreamController.add(0.0);
        },
      );

      // Initialize text-to-speech
      await flutterTts.setVolume(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(1.0);

      flutterTts.setStartHandler(() {
        isSpeaking.value = true;
        _startVolumeSimulation();
      });

      flutterTts.setCompletionHandler(() {
        isSpeaking.value = false;
        _stopVolumeSimulation();
        _volumeStreamController.add(0.0);
      });

      flutterTts.setErrorHandler((error) {
        isSpeaking.value = false;
        _stopVolumeSimulation();
        _volumeStreamController.add(0.0);
      });

      _volumeStreamController.add(0.0);
      isInitialized.value = true;
    } catch (e) {
      AppLogger.error('Error initializing speech service: $e');
    }
  }

  // Simulate changing volume patterns for the wave animation during speech
  void _startVolumeSimulation() {
    _stopVolumeSimulation();

    final random = math.Random();
    int counter = 0;

    _volumeSimulationTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      counter++;

      // Create a more dynamic pattern
      final baseAmplitude = 0.5 + 0.5 * math.sin(counter / 8);
      final jitter = random.nextDouble() * 0.3;
      final volume = math.max(0.3, math.min(1.0, baseAmplitude + jitter));

      _volumeStreamController.add(volume);
    });
  }

  void _stopVolumeSimulation() {
    _volumeSimulationTimer?.cancel();
    _volumeSimulationTimer = null;
  }

  // Set language for TTS and STT based on app language
  Future<void> setLanguage(String languageCode) async {
    if (!isInitialized.value) {
      await initializeSpeech();
    }

    try {
      final localeCode = languageCodes[languageCode] ?? 'en-US';
      await flutterTts.setLanguage(localeCode);
    } catch (e) {
      print('SpeechService: Error setting language: $e');
    }
  }

  // Set speech rate
  Future<void> setSpeechRate(double rate) async {
    await flutterTts.setSpeechRate(rate);
  }

  // Set speech pitch
  Future<void> setPitch(double pitch) async {
    await flutterTts.setPitch(pitch);
  }

  // Text-to-Speech functionality
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    if (isListening.value) {
      await stopListening();
    }

    if (isSpeaking.value) {
      await stop();
    }

    isSpeaking.value = true;
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    if (isSpeaking.value) {
      isSpeaking.value = false;
      await flutterTts.stop();
      _stopVolumeSimulation();
      _volumeStreamController.add(0.0);
    }
  }

  // Speech-to-Text functionality with proper error handling
  Future<bool> startListening(Function(String) onResult) async {
    print('SpeechService: startListening called');

    if (PlatformHelper.isWeb) {
      // Web-specific implementation or show unsupported message
      Get.snackbar(
        'Not Supported',
        'Voice input is not supported in web version',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!isInitialized.value) {
      print('SpeechService: Not initialized, cannot start listening');
      return false;
    }

    if (isSpeaking.value) {
      print('SpeechService: Stopping ongoing speech before listening');
      await stop();
    }

    // Always start volume simulation immediately for visual feedback
    isListening.value = true;
    _startVolumeSimulation();

    try {
      String localeId = 'en-US'; // Default fallback
      try {
        final systemLocale = await speech.systemLocale();
        if (systemLocale != null) {
          final langCode = systemLocale.localeId.split('_')[0];
          localeId = languageCodes[langCode] ?? 'en-US';
        }
      } catch (e) {
        print('SpeechService: Error getting system locale: $e');
      }

      print(
          'SpeechService: Starting speech recognition with locale: $localeId');

      bool started = false;
      try {
        started = await speech.listen(
          onResult: (result) {
            print(
                'SpeechService: Got result with final status: ${result.finalResult}');

            // Handle intermediate results
            if (!result.finalResult) {
              final interimText = result.recognizedWords;

              if (interimText.isNotEmpty) {
                // Update volume based on text length
                final volume =
                    math.min(1.0, 0.6 + (interimText.length % 30) / 30.0);
                _volumeStreamController.add(volume);
              }
            }
            // Handle final result
            else {
              print('SpeechService: Final result: "${result.recognizedWords}"');

              // Ensure we have a clean stop
              isListening.value = false;

              // Add a brief delay for animation to complete visually
              Future.delayed(Duration(milliseconds: 300), () {
                _stopVolumeSimulation();
                _volumeStreamController.add(0.0);
              });

              // Deliver the result
              onResult(result.recognizedWords);
            }
          },
          listenFor: const Duration(
              seconds: 10), // Shorter duration for better response
          pauseFor: const Duration(seconds: 3),
          localeId: localeId,
        );
      } catch (e) {
        print('SpeechService: Error in speech.listen: $e');
        started = false;
      }

      if (!started) {
        print('SpeechService: Failed to start listening operation');
        isListening.value = false;
        _stopVolumeSimulation();
        _volumeStreamController.add(0.0);

        // Handle failed start by still returning a valid bool
        return false;
      }

      return true; // Explicitly return true for success
    } catch (e) {
      print('SpeechService: Error starting speech recognition: $e');
      isListening.value = false;
      _stopVolumeSimulation();
      _volumeStreamController.add(0.0);

      // Always return false for errors, never null
      return false;
    }
  }

  Future<void> stopListening() async {
    if (isListening.value) {
      isListening.value = false;
      await speech.stop();
      _stopVolumeSimulation();
      _volumeStreamController.add(0.0);
    }
  }

  // Access to the volume stream for animations
  Stream<double> get volumeController => _volumeStreamController.stream;

  @override
  void onClose() {
    dispose();
    super.onClose();
  }

  void dispose() {
    flutterTts.stop();
    speech.stop();
    _stopVolumeSimulation();
    _volumeStreamController.close();
  }
}
