import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import 'number_card.dart';

/// A 5x5 grid of [NumberCard]s representing the game board.
///
/// Each cell has a front number and a back number. The board tracks which
/// cells have been flipped and which currently show feedback. All state is
/// driven by the parent — this widget is purely presentational.
class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.frontNumbers,
    required this.backNumbers,
    required this.flippedCells,
    required this.onCellTap,
    this.feedbackStates = const {},
    this.feedbackVersions = const {},
    this.useSmallFont = false,
    this.cardBaseColor = AppColors.cardDefault,
    this.cardBorderColor = AppColors.cardBorder,
    this.iconAsset = Icons.star_rounded,
  });

  /// Front-face numbers for each cell (length [totalCells]).
  final List<int> frontNumbers;

  /// Back-face numbers for each cell (length [totalCells]).
  final List<int> backNumbers;

  /// Set of cell indices that have been flipped (showing back number).
  final Set<int> flippedCells;

  /// Feedback state per cell index. Cells not in the map have no feedback.
  final Map<int, CardFeedback> feedbackStates;

  /// 각 셀의 feedback 재트리거 토큰. 부모가 탭 시마다 증가시켜 같은 feedback 값이어도
  /// 카드 애니를 다시 재생시키게 한다. (game_screen 의 Timer 청소 로직 제거를 위함)
  final Map<int, int> feedbackVersions;

  /// Called on touch-down. Passes the cell index and the currently
  /// visible number on that cell.
  final void Function(int cellIndex, int number) onCellTap;

  /// Use smaller font for 3-digit numbers (infinite mode).
  final bool useSmallFont;

  /// Base background color applied to every card.
  final Color cardBaseColor;

  /// Border color applied to every card. Cycles with [cardBaseColor].
  final Color cardBorderColor;

  /// Icon shown on the loop-advance cell. Infinite mode passes the per-loop
  /// icon; basic mode never shows the icon so the default is harmless.
  final IconData iconAsset;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: boardMaxSize),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            crossAxisSpacing: boardSpacing,
            mainAxisSpacing: boardSpacing,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final front = frontNumbers[index];
            final back = backNumbers[index];
            final isFlipped = flippedCells.contains(index);
            final feedback = feedbackStates[index] ?? CardFeedback.none;
            final feedbackVersion = feedbackVersions[index] ?? 0;
            final visibleNumber = isFlipped ? back : front;

            return NumberCard(
              frontNumber: front,
              backNumber: back,
              isFlipped: isFlipped,
              feedback: feedback,
              feedbackVersion: feedbackVersion,
              useSmallFont: useSmallFont,
              cardBaseColor: cardBaseColor,
              cardBorderColor: cardBorderColor,
              iconAsset: iconAsset,
              onTapDown: () => onCellTap(index, visibleNumber),
            );
          },
        ),
      ),
    );
  }
}
