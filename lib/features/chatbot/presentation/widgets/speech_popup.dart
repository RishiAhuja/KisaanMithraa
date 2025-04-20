import 'package:flutter/material.dart';
import 'package:cropconnect/features/chatbot/presentation/widgets/sound_animation.dart';

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
    if (!isListening) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: isListening ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 80),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SoundWaveAnimation(
                volumeStream: volumeStream,
                color: Colors.white,
                height: 28,
                numberOfBars: 5,
              ),
              const SizedBox(width: 10),
              Text(
                'Listening...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onCancel,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
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
