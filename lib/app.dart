import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/theme.dart';
import 'models/game_state.dart';
import 'portal/portal_shell.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/result_screen.dart';

/// 마지막으로 끝난 게임의 결과를 결과 화면 라우트로 넘기기 위한 임시 보관함.
/// go_router 의 `extra` 가 새로고침 시 휘발하므로 동일하게 메모리에서 휘발한다.
ResultArguments? _lastResult;

/// Top-level 라우터 — onExit 등 콜백에서 BuildContext 의존 없이 navigate 한다.
/// dispose 직전 context 로 `context.go` 호출하면 navigation 이 silent 하게 묻혀
/// 흰 화면이 뜨므로 항상 이 인스턴스를 통해 호출하고 post-frame 에 스케줄한다.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final activeId = state.matchedLocation.startsWith('/1to50')
            ? '1to50'
            : null;
        return PortalShell(activeGameId: activeId, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const PortalLanding(),
        ),
        GoRoute(
          path: '/1to50',
          builder: (context, state) => HomeScreen(
            onSelectMode: (mode) {
              final path = mode == GameMode.basic
                  ? '/1to50/basic'
                  : '/1to50/infinite';
              _scheduleGo(path);
            },
          ),
        ),
        GoRoute(
          path: '/1to50/basic',
          builder: (context, state) => GameScreen(
            mode: GameMode.basic,
            onExit: (result) {
              _lastResult = result;
              _scheduleGo(result == null ? '/1to50' : '/1to50/result');
            },
          ),
        ),
        GoRoute(
          path: '/1to50/infinite',
          builder: (context, state) => GameScreen(
            mode: GameMode.infinite,
            onExit: (result) {
              _lastResult = result;
              _scheduleGo(result == null ? '/1to50' : '/1to50/result');
            },
          ),
        ),
        GoRoute(
          path: '/1to50/result',
          builder: (context, state) {
            final args = _lastResult;
            if (args == null) {
              _scheduleGo('/1to50');
              return const SizedBox.shrink();
            }
            return ResultScreen(
              args: args,
              onReplay: () {
                final path = args.mode == GameMode.basic
                    ? '/1to50/basic'
                    : '/1to50/infinite';
                _lastResult = null;
                _scheduleGo(path);
              },
              onHome: () {
                _lastResult = null;
                _scheduleGo('/1to50');
              },
            );
          },
        ),
      ],
    ),
  ],
);

/// dialog pop transition (default ~200ms) 이 끝난 후 navigate.
/// 이전엔 addPostFrameCallback 만으론 transition 진행 중이라 GoRouter
/// delegate 와 Navigator state 가 동시에 변경되며 assertion (흰 화면) 발생.
void _scheduleGo(String path) {
  Future.delayed(const Duration(milliseconds: 250), () {
    appRouter.go(path);
  });
}

class HbjjGamesApp extends StatelessWidget {
  const HbjjGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.titleAccent,
        brightness: Brightness.dark,
        surface: AppColors.background,
      ),
    );
    return MaterialApp.router(
      title: 'HBJJGAMES',
      debugShowCheckedModeBanner: false,
      // 1to50 모바일과 동일한 Jua 폰트를 textTheme 전체에 적용 → AppTextStyles
      // 의 명시 안 한 fontFamily 가 상속으로 Jua 가 된다.
      theme: base.copyWith(textTheme: GoogleFonts.juaTextTheme(base.textTheme)),
      routerConfig: appRouter,
    );
  }
}
