import 'package:flutter/material.dart';

import '../config/theme.dart';

/// "찾아라!" + next target number (or bonus star for infinite icon taps).
class GameTargetDisplay extends StatelessWidget {
  const GameTargetDisplay({
    super.key,
    required this.target,
    this.awaitingIcon = false,
    this.iconAsset = Icons.star_rounded,
  });

  /// The number the player should tap next. Ignored when [awaitingIcon] is
  /// true.
  final int target;

  /// True when infinite mode is waiting on a bonus-star tap.
  final bool awaitingIcon;

  /// Icon shown while [awaitingIcon] is true. Matches the current loop's
  /// bonus icon in infinite mode; irrelevant in basic mode.
  final IconData iconAsset;

  @override
  Widget build(BuildContext context) {
    // Screen reader 에게 "찾아라!" 와 숫자/별이 따로따로 읽히지 않도록
    // 하나의 라벨로 병합. 시각 장식 텍스트("찾아라!") 는 label 로 흡수.
    final semanticsLabel = awaitingIcon ? '찾아라! 보너스 아이콘' : '찾아라! 다음 숫자 $target';

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('찾아라!', style: AppTextStyles.subtitle.copyWith(fontSize: 26)),
          const SizedBox(height: 4),
          awaitingIcon
              ? Icon(iconAsset, color: AppColors.recordHighlight, size: 73)
              : Text('$target', style: AppTextStyles.targetNumber),
        ],
      ),
    );
  }
}
