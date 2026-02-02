import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool animated;

  const AppLogo({super.key, this.size = 120, this.animated = false});

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.favorite_border,
          size: size * 0.5,
          color: AppColors.primaryColor,
        ),
      ),
    );

    if (animated) {
      // For animated version, wrap in AnimatedBuilder
      // This would require AnimationController, so for now return static
      // The splash screen can handle its own animation
      return logo;
    }

    return logo;
  }
}
