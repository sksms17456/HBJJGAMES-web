import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Full-screen overlay shown while the game is paused but the pause dialog
/// isn't currently on-screen (edge cases: dismissed dialog, lifecycle
/// transitions). Tapping anywhere fires [onTap] so the parent can start
/// the resume countdown.
class GamePauseOverlay extends StatelessWidget {
  const GamePauseOverlay({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Semantics(
        button: true,
        label: '일시정지. 탭하여 재개',
        excludeSemantics: true,
        child: Container(
          color: AppColors.background,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('일시정지', style: AppTextStyles.resultLabel),
              const SizedBox(height: 12),
              Text(
                '탭하여 재개',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.subText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
