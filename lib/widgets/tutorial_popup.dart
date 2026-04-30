import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

/// 3-page tutorial overlay shown on first infinite mode entry.
class TutorialPopup extends StatefulWidget {
  const TutorialPopup({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<TutorialPopup> createState() => _TutorialPopupState();
}

class _TutorialPopupState extends State<TutorialPopup> {
  int _currentPage = 0;

  static const _pages = [
    _TutorialPage(
      icon: Icons.grid_view_rounded,
      title: '1부터 50까지\n순서대로 찾아라!',
      description: '숫자를 누르면 뒤집히며\n다음 숫자가 나타납니다',
    ),
    _TutorialPage(
      icon: Icons.timer_outlined,
      title: '시간이 다 되기 전에\n살아남아라!',
      description: '정답을 누르면 시간이\n회복됩니다',
    ),
    _TutorialPage(
      icon: Icons.loop_rounded,
      title: '999까지 완료하면\nLoop +1!',
      description: '내 최고 Loop와 Total을\n갱신하자!',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      setState(() => _currentPage++);
    } else {
      widget.onComplete();
    }
  }

  void _previous() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withAlpha(230),
      child: SafeArea(
        child: Stack(
          children: [
            _buildSkipButton(),
            Center(child: _buildPageContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: TextButton(
        onPressed: widget.onComplete,
        child: Text(
          'SKIP',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.subText),
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    final page = _pages[_currentPage];
    final isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(page.icon, color: AppColors.correctFeedback, size: 64),
          const SizedBox(height: 24),
          Text(
            page.title,
            style: AppTextStyles.resultLabel,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPageIndicators(),
          const SizedBox(height: 32),
          _buildNavButtons(isLastPage),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _pages.length,
        (i) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _currentPage ? AppColors.numberText : AppColors.subText,
          ),
        ),
      ),
    );
  }

  Widget _buildNavButtons(bool isLastPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentPage > 0) ...[
          SizedBox(
            height: buttonHeight,
            child: TextButton(
              onPressed: _previous,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                '← 이전',
                style: AppTextStyles.button.copyWith(color: AppColors.subText),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonMain,
            minimumSize: const Size(120, buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonBorderRadius),
            ),
          ),
          onPressed: _next,
          child: Text(
            isLastPage ? '시작하기!' : '다음 →',
            style: AppTextStyles.button,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

class _TutorialPage {
  const _TutorialPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
