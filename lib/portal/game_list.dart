import 'package:flutter/material.dart';

import '../config/theme.dart';

/// 포털에 등록된 게임 1개의 메타.
class GameEntry {
  const GameEntry({
    required this.id,
    required this.title,
    required this.iconBuilder,
    required this.onTap,
  });

  /// 라우팅 경로 식별자 (예: '1to50'). 활성 게임 강조에 사용.
  final String id;

  final String title;

  /// 카드 안에 표시할 아이콘 위젯. `isActive` 가 true 면 강조 색을 적용해도 좋다.
  final Widget Function(bool isActive) iconBuilder;

  final VoidCallback onTap;
}

/// 헤더 바로 아래 가로 스크롤 가능한 게임 카드 리스트.
///
/// 게임 1개일 때도 자연스럽게 보이도록 좌측 정렬. 카드 너비는 고정.
class GameList extends StatelessWidget {
  const GameList({
    super.key,
    required this.games,
    required this.activeId,
  });

  final List<GameEntry> games;

  /// 현재 선택된 게임 id. 강조 테두리 표시용. null 이면 강조 없음.
  final String? activeId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: Color(0xFF1A1A2A), width: 1),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: games.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final game = games[index];
          final isActive = game.id == activeId;
          return _GameCard(game: game, isActive: isActive);
        },
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.isActive});

  final GameEntry game;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: game.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.numberText
                : Colors.transparent,
            width: isActive ? 2 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: game.iconBuilder(isActive),
            ),
            const SizedBox(height: 4),
            Text(
              game.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.smallText.copyWith(
                fontSize: 12,
                color: AppColors.numberText,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
