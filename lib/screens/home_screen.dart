import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../models/game_state.dart';
import '../services/audio_service.dart';

/// 1to50 메인 화면 — 모바일 home_screen 디자인 그대로, 에너지/랭킹/설정/캡션 제거.
///
/// 포털 컨테이너의 메인 영역 안에 들어간다. 헤더와 게임 리스트는 외부에서 그린다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onSelectMode,
    this.audioService,
    this.shimmerAutoStart = true,
  });

  final void Function(GameMode mode) onSelectMode;
  final AudioService? audioService;

  /// shimmer 애니메이션 자동 시작 여부. 테스트에서 false 로.
  final bool shimmerAutoStart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AudioService _audio = widget.audioService ?? AudioService.instance;
  late final AnimationController _shimmerController;

  final Paint _titleStrokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.shimmerAutoStart) {
      _shimmerController.repeat();
    } else {
      _shimmerController.value = 0.5;
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _navigateToGame(GameMode mode) {
    _audio.playButtonTap();
    widget.onSelectMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildSparklingTitle(),
            ),
          ),
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ModeButton(
                          label: '기본 모드',
                          onTap: () => _navigateToGame(GameMode.basic),
                        ),
                        const SizedBox(height: 24),
                        _ModeButton(
                          label: '무한 모드',
                          onTap: () => _navigateToGame(GameMode.infinite),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSparklingTitle() {
    const titleSpan = TextSpan(
      children: [
        TextSpan(text: '1', style: TextStyle(fontSize: 90)),
        TextSpan(text: 'TO', style: TextStyle(fontSize: 60)),
        TextSpan(text: '50', style: TextStyle(fontSize: 90)),
      ],
    );

    final baseTitleStyle = GoogleFonts.jua(fontWeight: FontWeight.w900);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          final t = (1 - (2 * _shimmerController.value - 1).abs());
          _titleStrokePaint.color = Color.lerp(
            AppColors.shimmerOutlineDark,
            AppColors.shimmerOutlineLight,
            t,
          )!;

          return Stack(
            children: [
              Text.rich(
                titleSpan,
                style: baseTitleStyle.copyWith(foreground: _titleStrokePaint),
              ),
              child!,
            ],
          );
        },
        child: Text.rich(
          titleSpan,
          style: baseTitleStyle.copyWith(color: AppColors.titleAccent),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: AppColors.buttonText,
          ),
        ),
      ),
    );
  }
}
