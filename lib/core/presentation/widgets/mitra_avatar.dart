import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MitraAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const MitraAvatar({
    super.key,
    this.size = 60,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        child: Lottie.asset(
          'assets/animations/mitra_avatar.json',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
