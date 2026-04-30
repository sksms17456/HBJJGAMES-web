import 'package:flutter/material.dart';

/// Application color palette from wireframe-guide.md.
///
/// All color values are defined here — never use inline hex elsewhere.
class AppColors {
  const AppColors._();

  /// Backgrounds
  static const Color background = Color(0xFF000000);

  /// Card
  ///
  /// 배경은 기본 navy 보다 살짝 채도/밝기 상향 — 흰 테두리와의 콘트라스트로
  /// 보드가 더 생동감 있게 보임. 흰 숫자 대비 L* 24 → 흰 대비 ≈ 7:1 (WCAG AAA).
  /// 테두리는 흰색으로 통일하여 배경색 순환 중에도 프레임이 일관되게 드러남.
  static const Color cardDefault = Color(0xFF1E3B7A);
  static const Color cardBorder = Color(0xFFFFFFFF);

  /// Text
  static const Color numberText = Color(0xFFFFFFFF);
  static const Color subText = Color(0xFFA0A0B0);

  /// Feedback
  static const Color correctFeedback = Color(0xFF00C853);
  static const Color wrongFeedback = Color(0xFFFF1744);

  /// Title accent (home screen "1TO50")
  static const Color titleAccent = Color(0xFFFFF600);

  /// Record / highlight
  static const Color recordHighlight = Color(0xFFFFD700);

  /// 본인 행 / 1위 배지 배경 — 어두운 골드 톤 (#2A2410). [recordHighlight]
  /// 테두리/텍스트와 짝을 이뤄 "내 기록" 또는 "오늘 1위" 강조 컨테이너에 쓰임.
  /// 리더보드 본인 행, RankBadge 1위 배경 두 곳에서 공유한다.
  static const Color myEntryBackground = Color(0xFF2A2410);

  /// Button
  static const Color buttonMain = Color(0xFF0F3460);
  static const Color buttonText = Color(0xFFFFFFFF);

  /// Timer bar thresholds
  static const Color timerGreen = Color(0xFF00C853);
  static const Color timerGold = Color(0xFFFFD700);
  static const Color timerRed = Color(0xFFFF1744);

  /// Title shimmer outline (dark gold → light gold lerp)
  static const Color shimmerOutlineDark = Color(0xFF997A00);
  static const Color shimmerOutlineLight = Color(0xFFFFFFCC);

  /// Infinite-mode card palette. Cycled every [cardPaletteBucketSize] taps
  /// (based on `totalScore`) as a milestone reward.
  ///
  /// Vivid jewel tones — lightness ~30–35%, saturation ~55% 에서 흰색 숫자/
  /// 흰색 테두리와 대비 ≥ 5:1 (WCAG AA). Border 는 모두 흰색으로 통일하여
  /// 팔레트 순환 중에도 프레임 두께가 일관되게 읽힘.
  static const List<CardPaletteEntry> cardPalette = [
    CardPaletteEntry(
      background: Color(0xFF3852A8),
      border: Color(0xFFFFFFFF),
    ), // navy
    CardPaletteEntry(
      background: Color(0xFF287F50),
      border: Color(0xFFFFFFFF),
    ), // emerald
    CardPaletteEntry(
      background: Color(0xFF9E3868),
      border: Color(0xFFFFFFFF),
    ), // rose
    CardPaletteEntry(
      background: Color(0xFFA06C28),
      border: Color(0xFFFFFFFF),
    ), // amber
    CardPaletteEntry(
      background: Color(0xFF4068A8),
      border: Color(0xFFFFFFFF),
    ), // steel
    CardPaletteEntry(
      background: Color(0xFF683AA8),
      border: Color(0xFFFFFFFF),
    ), // violet
    CardPaletteEntry(
      background: Color(0xFF8A8A3A),
      border: Color(0xFFFFFFFF),
    ), // olive
    CardPaletteEntry(
      background: Color(0xFF2D8686),
      border: Color(0xFFFFFFFF),
    ), // teal
  ];
}

/// One row of [AppColors.cardPalette] — a background/border pair that
/// changes together so the card frame stays visually consistent.
@immutable
class CardPaletteEntry {
  const CardPaletteEntry({required this.background, required this.border});

  final Color background;
  final Color border;
}

/// Application text styles from wireframe-guide.md.
///
/// All font sizes and weights are defined here.
class AppTextStyles {
  const AppTextStyles._();

  /// Title — 36px Bold (home screen title)
  static const TextStyle title = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.numberText,
  );

  /// Subtitle — 20px (dialog body, tutorial description, guide text).
  /// Matches the home caption scale per the project's larger-than-default
  /// typography tone (see feedback_typography_scale memory).
  static const TextStyle subtitle = TextStyle(
    fontSize: 20,
    color: AppColors.subText,
  );

  /// Target number — 73px Bold (current target in-game, 1.3× the original 56).
  static const TextStyle targetNumber = TextStyle(
    fontSize: 73,
    fontWeight: FontWeight.bold,
    color: AppColors.numberText,
  );

  /// Timer — 24px (elapsed / remaining time)
  static const TextStyle timer = TextStyle(
    fontSize: 24,
    color: AppColors.numberText,
  );

  /// Board number (basic mode) — 20px (18 → 20 으로 가독성 강화).
  static const TextStyle boardNumberBasic = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.numberText,
  );

  /// Board number (infinite / up to 3-digit). Unified with [boardNumberBasic]
  /// at 20px — "999" 3자리도 ~72dp 카드(boardMaxSize 500)에 무리 없이 들어감.
  static const TextStyle boardNumberInfinite = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.numberText,
  );

  /// Result score — 48px Bold
  static const TextStyle resultScore = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.numberText,
  );

  /// Result label — 24px Bold (e.g. "Complete!" / "Game Over")
  static const TextStyle resultLabel = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.numberText,
  );

  /// Mode label — 14px (result screen mode name)
  static const TextStyle modeLabel = TextStyle(
    fontSize: 14,
    color: AppColors.subText,
  );

  /// New best — 18px Bold (gold)
  static const TextStyle newBest = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.recordHighlight,
  );

  /// Small text — 12px (record under buttons, previous record)
  static const TextStyle smallText = TextStyle(
    fontSize: 12,
    color: AppColors.subText,
  );

  /// Loop / Total info — 16px
  static const TextStyle loopTotalInfo = TextStyle(
    fontSize: 16,
    color: AppColors.numberText,
  );

  /// Timer bar remaining — 18px (1.3× of original 14).
  static const TextStyle timerBarRemaining = TextStyle(
    fontSize: 18,
    color: AppColors.numberText,
  );

  /// Button text — dialog / tutorial actions. Home mode buttons override
  /// locally (see `home_screen.dart` `_ModeButton`).
  static const TextStyle button = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
  );
}
