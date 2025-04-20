import 'package:flutter/material.dart';
import 'dart:math' as math;

class SoundWaveAnimation extends StatelessWidget {
  final Stream<double> volumeStream;
  final Color color;
  final double height;
  final int numberOfBars;

  const SoundWaveAnimation({
    Key? key,
    required this.volumeStream,
    required this.color,
    this.height = 36,
    this.numberOfBars = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: volumeStream,
      initialData: 0.5,
      builder: (context, snapshot) {
        final volume = snapshot.hasData ? (snapshot.data ?? 0.5) : 0.5;

        return SizedBox(
          height: height,
          width: numberOfBars * 6.0,
          child: CustomSoundWaves(
            height: height,
            amplitude: volume,
            color: color,
            numberOfBars: numberOfBars,
          ),
        );
      },
    );
  }
}

class CustomSoundWaves extends StatefulWidget {
  final double amplitude;
  final Color color;
  final int numberOfBars;
  final double height;

  const CustomSoundWaves({
    Key? key,
    required this.amplitude,
    required this.color,
    this.numberOfBars = 5,
    required this.height,
  }) : super(key: key);

  @override
  _CustomSoundWavesState createState() => _CustomSoundWavesState();
}

class _CustomSoundWavesState extends State<CustomSoundWaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _randomOffsets = [];

  @override
  void initState() {
    super.initState();

    _randomOffsets.clear();
    for (int i = 0; i < widget.numberOfBars; i++) {
      _randomOffsets.add(math.Random().nextDouble() * 0.4);
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            widget.numberOfBars,
            (index) {
              final animationValue = math.sin(
                  (_controller.value * math.pi * 2) +
                      (index * 0.5) +
                      _randomOffsets[index]);

              final heightFactor =
                  widget.amplitude * (0.6 + animationValue * 0.4);
              final actualHeight = math.max(3.0, heightFactor * widget.height);

              return Container(
                width: 3.0,
                height: actualHeight,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
