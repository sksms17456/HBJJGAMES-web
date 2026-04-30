import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../models/game_state.dart';
import '../services/audio_service.dart';

/// Route arguments for the result screen.
///
/// Web 버전: 기록 저장/제출이 없으므로 isNewBest, previousBest*, clientPlayMs
/// 등 모바일용 필드는 모두 제거. mode + 결과치 + abort 사유만 보존.
class ResultArguments {
  const ResultArguments({
    required this.mode,
    this.score,
    this.time,
    this.loop,
    this.aborted = false,
    this.bgTimeout = false,
  });

  final GameMode mode;

  /// Total score (infinite mode).
  final int? score;

  /// Clear time in seconds (basic mode).
  final double? time;

  /// Loop count (infinite mode).
  final int? loop;

  /// True when the player chose to abort mid-run via the pause dialog.
  final bool aborted;

  /// Sub-reason for [aborted]: backgrounded past threshold and auto-aborted.
  final bool bgTimeout;
}

/// Displays game results — replay/home buttons. 기록 저장/베스트 비교 없음.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.args,
    required this.onReplay,
    required this.onHome,
    this.audioService,
  });

  final ResultArguments args;
  final VoidCallback onReplay;
  final VoidCallback onHome;
  final AudioService? audioService;

  AudioService get _audio => audioService ?? AudioService.instance;

  @override
  Widget build(BuildContext context) {
    final hideScore = args.aborted && args.mode == GameMode.basic;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModeHeader(
                mode: args.mode,
                aborted: args.aborted,
                bgTimeout: args.bgTimeout,
              ),
              const SizedBox(height: 24),
              if (!hideScore) ...[
                _ScoreDisplay(args: args),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 32),
              _ActionButtons(
                audio: _audio,
                onReplay: onReplay,
                onHome: onHome,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeHeader extends StatelessWidget {
  const _ModeHeader({
    required this.mode,
    this.aborted = false,
    this.bgTimeout = false,
  });

  final GameMode mode;
  final bool aborted;
  final bool bgTimeout;

  @override
  Widget build(BuildContext context) {
    final isBasic = mode == GameMode.basic;
    final headline = bgTimeout
        ? '장시간 중단'
        : (aborted ? '중단됨' : (isBasic ? '완료!' : '게임 오버'));
    return Column(
      children: [
        Text(isBasic ? '기본 1~50 모드' : '무한 모드', style: AppTextStyles.modeLabel),
        const SizedBox(height: 12),
        Text(headline, style: AppTextStyles.resultLabel),
      ],
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.args});

  final ResultArguments args;

  @override
  Widget build(BuildContext context) {
    if (args.mode == GameMode.basic) {
      final timeText = args.time != null
          ? '${args.time!.toStringAsFixed(basicModeTimeDecimalPlaces)}s'
          : '--';
      return Text(timeText, style: AppTextStyles.resultScore);
    }

    final loop = args.loop ?? 0;
    final total = args.score ?? 0;
    final formattedTotal = _formatWithComma(total);
    return Column(
      children: [
        Text('Loop $loop', style: AppTextStyles.resultLabel),
        const SizedBox(height: 8),
        Text('Total $formattedTotal', style: AppTextStyles.resultScore),
      ],
    );
  }
}

String _formatWithComma(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return buffer.toString();
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.audio,
    required this.onReplay,
    required this.onHome,
  });

  final AudioService audio;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonMain,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
            ),
            onPressed: () {
              audio.playButtonTap();
              onReplay();
            },
            child: const Text('다시 하기', style: AppTextStyles.button),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.buttonMain),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
            ),
            onPressed: () {
              audio.playButtonTap();
              onHome();
            },
            child: Text(
              '홈으로',
              style: AppTextStyles.button.copyWith(color: AppColors.buttonMain),
            ),
          ),
        ),
      ],
    );
  }
}
