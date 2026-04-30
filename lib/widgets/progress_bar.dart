import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final ratio = (current / basicModeMaxNumber).clamp(0.0, 1.0);

    return SizedBox(
      width: double.infinity,
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: ratio),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, value, child) => LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.cardDefault,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.correctFeedback,
            ),
          ),
        ),
      ),
    );
  }
}
