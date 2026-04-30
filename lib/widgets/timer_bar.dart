import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

class TimerBar extends StatelessWidget {
  const TimerBar({
    super.key,
    required this.remainingSeconds,
    required this.maxSeconds,
  });

  final double remainingSeconds;
  final double maxSeconds;

  Color get _barColor {
    if (remainingSeconds >= timerWarningGreenThreshold) {
      return AppColors.timerGreen;
    } else if (remainingSeconds >= timerWarningGoldThreshold) {
      return AppColors.timerGold;
    }
    return AppColors.timerRed;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = maxSeconds > 0
        ? (remainingSeconds / maxSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: AppColors.cardDefault,
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${remainingSeconds.toStringAsFixed(1)}s',
          style: AppTextStyles.timerBarRemaining,
        ),
      ],
    );
  }
}
