import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

/// Visual feedback state for a card after tap.
enum CardFeedback { none, correct, wrong }

/// Duration of the feedback flash animation.
const Duration _feedbackDuration = Duration(milliseconds: 300);

/// A single card in the 5x5 game board.
///
/// Supports a 3D flip animation (front → back), correct/wrong visual
/// feedback, and touch-down detection. Input is always accepted, even
/// while a flip animation is playing (per spec: animation is visual only).
class NumberCard extends StatefulWidget {
  const NumberCard({
    super.key,
    required this.frontNumber,
    this.backNumber,
    required this.onTapDown,
    this.isFlipped = false,
    this.feedback = CardFeedback.none,
    this.feedbackVersion = 0,
    this.useSmallFont = false,
    this.cardBaseColor = AppColors.cardDefault,
    this.cardBorderColor = AppColors.cardBorder,
    this.iconAsset = Icons.star_rounded,
  });

  /// Number shown on the front face.
  final int frontNumber;

  /// Number shown after flip. When `-1`, displays a loop icon.
  final int? backNumber;

  /// Called on touch-down (instant response, per spec).
  final VoidCallback onTapDown;

  /// When set to `true`, triggers the flip animation.
  final bool isFlipped;

  /// Current feedback state — drives a brief color flash.
  final CardFeedback feedback;

  /// 같은 셀을 연속 탭할 때 `feedback` 값이 동일해도 재트리거되도록 부모가 증가시키는 토큰.
  /// 값이 바뀌면 내부 `_feedbackController` 가 `forward(from: 0.0)` 로 다시 재생된다.
  final int feedbackVersion;

  /// Use smaller font for 3-digit numbers (infinite mode).
  final bool useSmallFont;

  /// Base card background color. Infinite mode cycles this via
  /// [AppColors.cardPalette]; other callers can omit this.
  final Color cardBaseColor;

  /// Card border color. Cycles together with [cardBaseColor] in infinite mode.
  final Color cardBorderColor;

  /// Icon shown on the loop-advance cell (`backNumber == -1`). Infinite mode
  /// passes the per-loop icon; other callers keep the default star.
  final IconData iconAsset;

  @override
  State<NumberCard> createState() => _NumberCardState();
}

class _NumberCardState extends State<NumberCard> with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final CurvedAnimation _flipAnimation;
  late final AnimationController _feedbackController;
  late final AnimationController _baseColorController;
  // Tracked so `didUpdateWidget` can `.dispose()` the prior curve before
  // replacing it — otherwise each palette transition leaks a listener on
  // `_baseColorController` (noticeable in infinite mode where the palette
  // cycles every 25 taps).
  late CurvedAnimation _baseCurve;
  late Animation<Color?> _baseColorAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: flipAnimationDuration,
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    );

    _feedbackController = AnimationController(
      vsync: this,
      duration: _feedbackDuration,
    );

    _baseColorController = AnimationController(
      vsync: this,
      duration: cardColorTweenDuration,
      value: 1.0,
    );
    _baseCurve = CurvedAnimation(
      parent: _baseColorController,
      curve: Curves.easeOut,
    );
    _baseColorAnimation = ColorTween(
      begin: widget.cardBaseColor,
      end: widget.cardBaseColor,
    ).animate(_baseCurve);
    _borderColorAnimation = ColorTween(
      begin: widget.cardBorderColor,
      end: widget.cardBorderColor,
    ).animate(_baseCurve);

    if (widget.isFlipped) {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NumberCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFlipped && !oldWidget.isFlipped) {
      _flipController.forward(from: 0.0);
    }

    // feedback 값이 달라졌거나(none→correct 등), 값은 같지만 토큰이 바뀐(= 같은 셀을
    // 같은 판정으로 다시 탭한) 경우 애니메이션을 다시 재생. 부모 쪽 `Timer(350ms)+setState`
    // 로 상태를 청소하던 로직이 이 토큰 비교로 대체된다.
    final feedbackChanged = widget.feedback != oldWidget.feedback;
    final versionChanged = widget.feedbackVersion != oldWidget.feedbackVersion;
    if (feedbackChanged || versionChanged) {
      if (widget.feedback != CardFeedback.none) {
        _feedbackController.forward(from: 0.0);
      } else {
        _feedbackController.reset();
      }
    }

    if (widget.cardBaseColor != oldWidget.cardBaseColor ||
        widget.cardBorderColor != oldWidget.cardBorderColor) {
      _baseCurve.dispose();
      _baseCurve = CurvedAnimation(
        parent: _baseColorController,
        curve: Curves.easeOut,
      );
      _baseColorAnimation = ColorTween(
        begin: _baseColorAnimation.value ?? oldWidget.cardBaseColor,
        end: widget.cardBaseColor,
      ).animate(_baseCurve);
      _borderColorAnimation = ColorTween(
        begin: _borderColorAnimation.value ?? oldWidget.cardBorderColor,
        end: widget.cardBorderColor,
      ).animate(_baseCurve);
      _baseColorController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _flipAnimation.dispose();
    _baseCurve.dispose();
    _flipController.dispose();
    _feedbackController.dispose();
    _baseColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTapDown(),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _flipAnimation,
          _feedbackController,
          _baseColorController,
        ]),
        builder: (context, _) {
          final flipValue = _flipAnimation.value;
          final angle = flipValue * math.pi;
          // Scale pulse: 1.0 → 1.08 → 1.0 during flip via sin(πt). Peaks at
          // flipValue=0.5 and returns to 1.0 at rest, so a static card
          // (flipValue 0 or 1) stays at its natural size.
          final scale = 1.0 + 0.08 * math.sin(flipValue * math.pi);
          final showFront = flipValue < 0.5;

          final borderColor =
              _borderColorAnimation.value ?? widget.cardBorderColor;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle)
              ..scaleByDouble(scale, scale, scale, 1),
            child: showFront
                ? _CardFace(
                    number: widget.frontNumber,
                    backgroundColor: _currentBackgroundColor(),
                    borderColor: borderColor,
                    textStyle: _textStyle,
                    iconAsset: widget.iconAsset,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(
                      number: widget.backNumber ?? widget.frontNumber,
                      backgroundColor: _currentBackgroundColor(),
                      borderColor: borderColor,
                      textStyle: _textStyle,
                      iconAsset: widget.iconAsset,
                    ),
                  ),
          );
        },
      ),
    );
  }

  TextStyle get _textStyle => widget.useSmallFont
      ? AppTextStyles.boardNumberInfinite
      : AppTextStyles.boardNumberBasic;

  Color _currentBackgroundColor() {
    final base = _baseColorAnimation.value ?? widget.cardBaseColor;
    if (widget.feedback == CardFeedback.none) {
      return base;
    }
    final fadeOut = 1.0 - _feedbackController.value;
    if (widget.feedback == CardFeedback.correct) {
      return Color.lerp(base, AppColors.correctFeedback, 0.2 * fadeOut)!;
    }
    return Color.lerp(base, AppColors.wrongFeedback, 0.4 * fadeOut)!;
  }
}

/// The visual face of a card — number or icon centered in a styled box.
class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.number,
    required this.backgroundColor,
    required this.borderColor,
    required this.textStyle,
    required this.iconAsset,
  });

  final int number;
  final Color backgroundColor;
  final Color borderColor;
  final TextStyle textStyle;
  final IconData iconAsset;

  @override
  Widget build(BuildContext context) {
    final isIcon = number == -1;
    final isEmpty = number <= 0 && !isIcon;

    return Container(
      decoration: BoxDecoration(
        color: isEmpty ? borderColor : backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      alignment: Alignment.center,
      child: isIcon
          ? Icon(iconAsset, color: AppColors.recordHighlight, size: 28)
          : isEmpty
          ? const SizedBox.shrink()
          : Transform.translate(
              offset: const Offset(0, 2),
              child: Text(
                '$number',
                style: textStyle.copyWith(height: 1.0),
                textAlign: TextAlign.center,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
            ),
    );
  }
}
