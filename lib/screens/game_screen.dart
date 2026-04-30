import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/loop_icons.dart';
import '../config/theme.dart';
import '../logic/basic_mode_controller.dart';
import '../logic/board_generator.dart';
import '../logic/infinite_mode_controller.dart';
import '../models/game_state.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../widgets/countdown_overlay.dart';
import '../widgets/game_board.dart';
import '../widgets/game_pause_dialog.dart';
import '../widgets/game_pause_overlay.dart';
import '../widgets/game_target_display.dart';
import '../widgets/game_top_bar.dart';
import '../widgets/number_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/timer_bar.dart';
import '../widgets/tutorial_popup.dart';
import 'result_screen.dart';

/// Web 게임 화면. 모바일과 동일한 디자인 + 광고/에너지/부활/베스트 기록 제거.
///
/// 페이지 떠나면 메모리 상의 상태는 모두 휘발 — best 기록을 저장/조회하지 않고,
/// 매 판은 완전한 새출발이다.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.mode,
    required this.onExit,
    this.audioService,
    this.hapticService,
  });

  final GameMode mode;

  /// 결과 화면 또는 홈으로 라우팅할 때 호출. go_router 등 외부가 라우팅을 소유.
  final void Function(ResultArguments? result) onExit;

  final AudioService? audioService;
  final HapticService? hapticService;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// 무한모드 첫 진입 시 한 번만 튜토리얼을 띄우기 위한 세션 플래그.
/// 탭 새로고침/종료 후 다시 진입하면 재표시 (요구사항: 기록은 그 순간에만 남음).
bool _infiniteTutorialShownThisSession = false;

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  bool _tapLock = false;
  Timer? _tapLockTimer;

  DateTime? _backgroundedAt;

  BasicModeController? _basicController;
  InfiniteModeController? _infiniteController;

  final BoardGenerator _boardGen = BoardGenerator();
  List<int> _frontNumbers = [];
  List<int> _backNumbers = [];
  final Set<int> _flippedCells = {};
  final Map<int, CardFeedback> _feedbackStates = {};
  final Map<int, int> _feedbackVersions = {};
  int _boardKey = 0;
  int _currentFrontStart = 1;

  bool _gameStarted = false;
  bool _isPaused = false;
  bool _showCountdown = false;
  bool _showTutorial = false;
  bool _navigating = false;
  bool _pauseDialogOpen = false;

  late final AudioService _audioService =
      widget.audioService ?? AudioService.instance;
  late final HapticService _hapticService =
      widget.hapticService ?? HapticService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initGame();
    if (widget.mode == GameMode.infinite) {
      if (!_infiniteTutorialShownThisSession) {
        _showTutorial = true;
      } else {
        _audioService.playGameStart();
      }
    } else {
      _audioService.playGameStart();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tapLockTimer?.cancel();
    _basicController?.removeListener(_onControllerUpdate);
    _basicController?.dispose();
    _infiniteController?.removeListener(_onControllerUpdate);
    _infiniteController?.dispose();
    super.dispose();
  }

  void _initGame() {
    if (widget.mode == GameMode.basic) {
      _basicController = BasicModeController()
        ..addListener(_onControllerUpdate);
      final board = _boardGen.generateBasicBoard();
      _frontNumbers = board[0];
      _backNumbers = board[1];
    } else {
      _infiniteController = InfiniteModeController()
        ..addListener(_onControllerUpdate);
      final board = _boardGen.generateInfiniteBoard(1);
      _frontNumbers = board[0];
      _backNumbers = board[1];
    }
  }

  void _onTutorialComplete() {
    _infiniteTutorialShownThisSession = true;
    setState(() => _showTutorial = false);
    _audioService.playGameStart();
  }

  void _startGame() {
    _basicController?.startGame();
    _infiniteController?.startGame();
    setState(() => _gameStarted = true);
  }

  void _onControllerUpdate() {
    if (!mounted || _navigating) return;

    if (widget.mode == GameMode.basic &&
        _basicController?.gamePhase == BasicGamePhase.completed) {
      _navigating = true;
      _handleBasicComplete();
      return;
    }
    if (widget.mode == GameMode.infinite) {
      final phase = _infiniteController?.gamePhase;
      if (phase == InfiniteGamePhase.gameOver) {
        _navigating = true;
        _handleInfiniteGameOver();
        return;
      }
    }
  }

  void _onCellTap(int cellIndex, int number) {
    if (_isPaused || _showCountdown || _showTutorial || _navigating) return;
    if (_tapLock) return;
    _tapLock = true;
    _tapLockTimer?.cancel();
    _tapLockTimer = Timer(multiTouchLockDuration, () {
      _tapLock = false;
      _tapLockTimer = null;
    });
    if (!_gameStarted) _startGame();

    final prevLoop = _infiniteController?.currentLoop;

    final correct = widget.mode == GameMode.basic
        ? _basicController!.tapNumber(number)
        : _infiniteController!.tapNumber(number);

    setState(() {
      _feedbackVersions[cellIndex] = (_feedbackVersions[cellIndex] ?? 0) + 1;
      if (correct) {
        _flippedCells.add(cellIndex);
        _feedbackStates[cellIndex] = CardFeedback.correct;
        _hapticService.correctFeedback();
        _audioService.playCorrect();
        _handlePostCorrectTap(prevLoop);
      } else {
        _feedbackStates[cellIndex] = CardFeedback.wrong;
        _hapticService.wrongFeedback();
        _audioService.playWrong();
      }
    });
  }

  void _handlePostCorrectTap(int? prevLoop) {
    if (widget.mode == GameMode.infinite &&
        _infiniteController!.currentLoop != prevLoop) {
      _regenerateBoardForNewLoop();
      _audioService.playLoopComplete();
    } else {
      _checkSetTransition();
    }
  }

  void _checkSetTransition() {
    if (_flippedCells.length < totalCells) return;

    _frontNumbers = List.of(_backNumbers);
    _flippedCells.clear();
    _feedbackStates.clear();
    _feedbackVersions.clear();
    _boardKey++;

    if (widget.mode == GameMode.basic) {
      _backNumbers = List.filled(totalCells, -2);
      return;
    }

    _currentFrontStart += totalCells;
    _generateNextInfiniteBack();
  }

  void _generateNextInfiniteBack() {
    final backStart = _currentFrontStart + totalCells;

    if (backStart > infiniteModeMaxNumberPerLoop) {
      _backNumbers = List.filled(totalCells, -2);
    } else if (backStart + totalCells - 1 > infiniteModeMaxNumberPerLoop) {
      final count = infiniteModeMaxNumberPerLoop - backStart + 1;
      final lastNumbers = List.generate(count, (i) => backStart + i);
      _backNumbers = _boardGen.generateLastSetBackNumbers(lastNumbers);
    } else {
      _backNumbers = _boardGen.generateBackNumbers(backStart);
    }
  }

  void _regenerateBoardForNewLoop() {
    final board = _boardGen.generateInfiniteBoard(1);
    _frontNumbers = board[0];
    _backNumbers = board[1];
    _flippedCells.clear();
    _feedbackStates.clear();
    _feedbackVersions.clear();
    _boardKey++;
    _currentFrontStart = 1;
  }

  void _handleBasicComplete() {
    final time = _basicController!.totalTime;
    widget.onExit(
      ResultArguments(mode: GameMode.basic, time: time),
    );
  }

  void _handleInfiniteGameOver() {
    final controller = _infiniteController!;
    _audioService.playGameOver();
    widget.onExit(
      ResultArguments(
        mode: GameMode.infinite,
        score: controller.totalScore,
        loop: controller.currentLoop,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_gameStarted || _navigating) return;
    if (_pauseDialogOpen) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      _basicController?.pause();
      _infiniteController?.pause();
      _backgroundedAt = DateTime.now();
      setState(() => _isPaused = true);
    } else if (state == AppLifecycleState.resumed && _isPaused) {
      final startedAt = _backgroundedAt;
      _backgroundedAt = null;
      if (startedAt != null &&
          DateTime.now().difference(startedAt) >= backgroundGameOverThreshold) {
        _handleAbort(bgTimeout: true);
        return;
      }
      setState(() => _showCountdown = true);
    }
  }

  void _onCountdownComplete() {
    _basicController?.resume();
    _infiniteController?.resume();
    setState(() {
      _isPaused = false;
      _showCountdown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 보드 정사각형 size 를 화면 가용 영역에 맞춰 먼저 계산하고,
              // Column 폭을 그 size 와 동일하게 강제 → ProgressBar / TopBar /
              // TimerBar 좌우가 보드 좌우와 정확히 일치한다. 화면이 좁아지면
              // 보드와 함께 일관 축소.
              LayoutBuilder(
                builder: (context, constraints) {
                  // 보드 외 column 자식 합산 높이 (top bar 56 + progress 12 +
                  // gap 16 + target ~140 + gap 16 + vertical padding 32).
                  const reservedHeight = 56.0 + 12.0 + 16.0 + 140.0 + 16.0 + 32.0;
                  final availH = math.max(
                    0.0,
                    constraints.maxHeight - reservedHeight,
                  );
                  final boardSide = math.min(
                    math.min(constraints.maxWidth - 32, boardMaxSize),
                    availH,
                  ).clamp(0.0, boardMaxSize).toDouble();
                  return Center(
                    child: SizedBox(
                      width: boardSide,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.mode == GameMode.basic
                                ? GameBasicTopBar(
                                    controller: _basicController,
                                    onPauseTap: _onPauseTapped,
                                  )
                                : GameInfiniteTopBar(
                                    controller: _infiniteController!,
                                    onPauseTap: _onPauseTapped,
                                  ),
                            widget.mode == GameMode.basic
                                ? _buildBasicProgressBar()
                                : _buildInfiniteTimerBar(),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 140,
                              child: Center(
                                child: GameTargetDisplay(
                                  target: widget.mode == GameMode.basic
                                      ? _basicController?.currentTarget ?? 1
                                      : _infiniteController?.currentTarget ?? 1,
                                  awaitingIcon:
                                      widget.mode == GameMode.infinite &&
                                      (_infiniteController?.awaitingIconTap ??
                                          false),
                                  iconAsset: _currentLoopIcon,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: boardSide,
                              height: boardSide,
                              child: _buildBoard(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_isPaused && !_showCountdown)
                GamePauseOverlay(onTap: _onPauseOverlayTap),
              if (_showCountdown)
                CountdownOverlay(onComplete: _onCountdownComplete),
              if (_showTutorial) TutorialPopup(onComplete: _onTutorialComplete),
            ],
          ),
        ),
    );
  }

  Widget _buildBasicProgressBar() {
    return ProgressBar(current: (_basicController?.currentTarget ?? 1) - 1);
  }

  Widget _buildInfiniteTimerBar() {
    final c = _infiniteController;
    if (c == null) {
      return const TimerBar(
        remainingSeconds: infiniteModeInitialTimeSeconds,
        maxSeconds: infiniteModeTimeCapSeconds,
      );
    }
    return ListenableBuilder(
      listenable: c,
      builder: (_, _) => TimerBar(
        remainingSeconds: c.remainingTime,
        maxSeconds: infiniteModeTimeCapSeconds,
      ),
    );
  }

  void _onPauseOverlayTap() {
    if (!_isPaused || !_gameStarted || _navigating || _showCountdown) return;
    if (_pauseDialogOpen) return;
    setState(() => _showCountdown = true);
  }

  Future<void> _onPauseTapped() async {
    if (_navigating || _showTutorial || _showCountdown || _isPaused) {
      return;
    }

    if (_gameStarted) {
      _basicController?.pause();
      _infiniteController?.pause();
    }
    setState(() => _isPaused = true);

    _pauseDialogOpen = true;
    final choice = await showGamePauseDialog(context);
    if (!mounted) {
      _pauseDialogOpen = false;
      return;
    }
    // Dialog pop transition (~200ms) 이 끝나기 전에 setState / navigation 을
    // 호출하면 GoRouter delegate + Navigator state 가 충돌해 흰 화면이 뜬다.
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) {
      _pauseDialogOpen = false;
      return;
    }

    if (choice == true) {
      if (!_gameStarted) {
        _pauseDialogOpen = false;
        widget.onExit(null);
        return;
      }
      await _handleAbort();
      _pauseDialogOpen = false;
      return;
    }

    if (!_gameStarted) {
      _pauseDialogOpen = false;
      setState(() => _isPaused = false);
      return;
    }
    setState(() => _showCountdown = true);
    _pauseDialogOpen = false;
  }

  Future<void> _handleAbort({bool bgTimeout = false}) async {
    _navigating = true;

    if (widget.mode == GameMode.basic) {
      widget.onExit(
        ResultArguments(
          mode: GameMode.basic,
          aborted: true,
          bgTimeout: bgTimeout,
        ),
      );
      return;
    }

    final controller = _infiniteController!;
    widget.onExit(
      ResultArguments(
        mode: GameMode.infinite,
        score: controller.totalScore,
        loop: controller.currentLoop,
        aborted: true,
        bgTimeout: bgTimeout,
      ),
    );
  }

  Widget _buildBoard() {
    final palette = _currentCardPalette();
    return Center(
      child: GameBoard(
        key: ValueKey(_boardKey),
        frontNumbers: _frontNumbers,
        backNumbers: _backNumbers,
        flippedCells: _flippedCells,
        feedbackStates: _feedbackStates,
        feedbackVersions: _feedbackVersions,
        onCellTap: _onCellTap,
        useSmallFont: widget.mode == GameMode.infinite,
        cardBaseColor: palette.background,
        cardBorderColor: palette.border,
        iconAsset: _currentLoopIcon,
      ),
    );
  }

  IconData get _currentLoopIcon {
    if (widget.mode != GameMode.infinite || _infiniteController == null) {
      return Icons.star_rounded;
    }
    return loopIconFor(_infiniteController!.currentLoop);
  }

  CardPaletteEntry _currentCardPalette() {
    if (widget.mode != GameMode.infinite || _infiniteController == null) {
      return AppColors.cardPalette[0];
    }
    final completedTaps = _infiniteController!.totalScore - 1;
    final bucket = completedTaps ~/ cardPaletteBucketSize;
    return AppColors.cardPalette[bucket % AppColors.cardPalette.length];
  }
}
