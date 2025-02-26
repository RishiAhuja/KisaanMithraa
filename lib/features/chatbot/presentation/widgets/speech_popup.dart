import 'package:cropconnect/features/chatbot/presentation/widgets/sound_animation.dart';
import 'package:flutter/material.dart';

class SpeechRecognitionPopup extends StatelessWidget {
  final bool isListening;
  final VoidCallback onCancel;
  final Stream<double> volumeStream;

  const SpeechRecognitionPopup({
    Key? key,
    required this.isListening,
    required this.onCancel,
    required this.volumeStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Don't use Visibility inside AnimatedOpacity as it can cause issues
    if (!isListening) {
      return const SizedBox.shrink(); // Return empty widget when not listening
    }

    return AnimatedOpacity(
      opacity: isListening ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Use StreamBuilder directly to debug the volume stream
              StreamBuilder<double>(
                stream: volumeStream,
                initialData: 0.0,
                builder: (context, snapshot) {
                  // Log data for debugging
                  print('Speech popup volume: ${snapshot.data}');

                  return SoundWaveAnimation(
                    volumeStream: volumeStream,
                    color: Colors.white,
                    height: 32,
                    numberOfBars: 5,
                  );
                },
              ),
              const SizedBox(width: 12),
              const Text(
                'Listening...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    print('Speech popup cancel button pressed');
                    onCancel();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
