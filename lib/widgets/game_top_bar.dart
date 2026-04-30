import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../logic/basic_mode_controller.dart';
import '../logic/infinite_mode_controller.dart';

/// Top bar for Basic mode: pause button on the left, elapsed time centered.
/// [controller] may be null before the controller is wired up — the bar
/// shows `0.000s` in that window.
class GameBasicTopBar extends StatelessWidget {
  const GameBasicTopBar({
    super.key,
    required this.controller,
    required this.onPauseTap,
  });

  final BasicModeController? controller;
  final VoidCallback onPauseTap;

  // 플랫폼 monospace fallback — Android 는 Roboto Mono, iOS 는 Menlo.
  // GoogleFonts.robotoMono 는 allowRuntimeFetching=false 환경에서 throw.
  // BasicModeController 는 60Hz Timer.periodic 으로 notifyListeners 를 쏘고
  // ListenableBuilder 가 매 frame Text 만 rebuild 하므로, TextStyle 은 클래스
  // 레벨 static const 로 한 번만 만든다 (loopTotalInfo.copyWith 회피).
  static const TextStyle _monoStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 21,
    color: AppColors.numberText,
  );

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _PauseIconButton(onTap: onPauseTap),
          ),
          Center(
            child: c == null
                ? const Text('0.000s', style: _monoStyle)
                : ListenableBuilder(
                    listenable: c,
                    builder: (_, _) =>
                        Text('${c.formattedTime}s', style: _monoStyle),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Top bar for Infinite mode: pause button on the left, "Loop N / Total N"
/// centered.
class GameInfiniteTopBar extends StatelessWidget {
  const GameInfiniteTopBar({
    super.key,
    required this.controller,
    required this.onPauseTap,
  });

  final InfiniteModeController controller;
  final VoidCallback onPauseTap;

  // ListenableBuilder 가 controller notify 마다 Row 를 rebuild 하므로 두 스타일을
  // 클래스 레벨 static const 로 끌어올려 매 tick TextStyle 신규 할당을 제거.
  static const TextStyle _loopStyle = TextStyle(
    fontSize: 21,
    color: AppColors.numberText,
  );
  static const TextStyle _totalStyle = TextStyle(
    fontSize: 21,
    color: AppColors.subText,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _PauseIconButton(onTap: onPauseTap),
          ),
          Center(
            // ListenableBuilder scope — controller notify 시 Row 만 rebuild.
            // 감싸지 않으면 _GameScreenState.build 가 tap 마다 setState 로
            // 호출되는 부수효과에만 의존해 갱신되므로, 페널티 롤오버 같은
            // 비탭 경로에서 Loop/Total 표시가 드리프트할 수 있음.
            child: ListenableBuilder(
              listenable: controller,
              builder: (_, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Loop ${controller.currentLoop}', style: _loopStyle),
                  const SizedBox(width: 16),
                  Text('Total ${controller.totalScore}', style: _totalStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseIconButton extends StatelessWidget {
  const _PauseIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.pause_rounded, color: AppColors.numberText),
      iconSize: 31,
      tooltip: '일시정지',
      onPressed: onTap,
    );
  }
}
