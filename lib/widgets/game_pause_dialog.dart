import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Pause dialog with "재시작" and "중단하기" actions.
///
/// Returns:
///   - `true` if the player picked 중단하기 (abort run)
///   - `false` if they picked 재시작 (resume via countdown)
///   - `null` if the dialog was dismissed externally (route pop, etc.)
Future<bool?> showGamePauseDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    // GoRouter ShellRoute 의 inner navigator 에 push 한다. root navigator 에
    // 띄우면 dialog pop 과 inner navigator 라우트 변경이 별개 navigator 에서
    // 동시에 일어나며 GoRouter delegate assertion (흰 화면) 발생.
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.cardDefault,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      title: const Text(
        '일시정지',
        style: AppTextStyles.resultLabel,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            '재시작',
            style: AppTextStyles.button.copyWith(color: AppColors.titleAccent),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            '중단하기',
            style: AppTextStyles.button.copyWith(
              color: AppColors.wrongFeedback,
            ),
          ),
        ),
      ],
    ),
  );
}
