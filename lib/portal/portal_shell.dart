import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import 'game_list.dart';
import 'portal_header.dart';

/// 포털의 공통 셸 — 헤더 + 게임 리스트 + 메인 영역.
///
/// go_router 의 ShellRoute 안쪽에서 사용한다. 메인 영역(`child`) 만 라우트별로
/// 교체되고 헤더와 게임 리스트는 유지된다.
class PortalShell extends StatelessWidget {
  const PortalShell({
    super.key,
    required this.child,
    required this.activeGameId,
  });

  /// 현재 라우트의 본문 (HomeScreen / GameScreen / ResultScreen 등).
  final Widget child;

  /// 게임 리스트에서 강조할 활성 게임 id. 홈에서는 null.
  final String? activeGameId;

  @override
  Widget build(BuildContext context) {
    final games = <GameEntry>[
      GameEntry(
        id: '1to50',
        title: '1to50',
        iconBuilder: (_) => Image.asset(
          'assets/icons/foreground.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
        onTap: () => context.go('/1to50'),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            PortalHeader(onLogoTap: () => context.go('/')),
            GameList(games: games, activeId: activeGameId),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: child,
              ),
            ),
            const _PortalFooter(),
          ],
        ),
      ),
    );
  }
}

class _PortalFooter extends StatelessWidget {
  const _PortalFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: Color(0xFF1A1A2A), width: 1),
        ),
      ),
      child: Text(
        '© $companyName',
        textAlign: TextAlign.center,
        style: AppTextStyles.smallText.copyWith(
          fontSize: 13,
          color: AppColors.subText,
        ),
      ),
    );
  }
}

/// 홈 (게임 미선택) 상태에서 메인 영역에 노출되는 안내 화면.
class PortalLanding extends StatelessWidget {
  const PortalLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset(
              'assets/branding/jj_games_portal.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '게임을 선택하세요',
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
