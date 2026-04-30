import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/constants.dart';

/// Phases of a basic-mode game.
enum BasicGamePhase {
  /// Waiting to start.
  ready,

  /// Actively playing.
  playing,

  /// Paused (e.g. app backgrounded).
  paused,

  /// All 50 numbers tapped — game complete.
  completed,
}

/// Controls game state for the Basic 1–50 mode.
///
/// Tracks elapsed time (with penalty), the current target number,
/// and game phase transitions.
class BasicModeController extends ChangeNotifier {
  BasicModeController({
    Duration tickInterval = const Duration(milliseconds: 16),
  }) : _tickInterval = tickInterval;

  /// 내부 타이머의 tick 간격. 테스트에서는 짧게 주입해 game-tick 시뮬을 빠르게.
  final Duration _tickInterval;

  /// The next number the player must tap.
  int _currentTarget = 1;
  int get currentTarget => _currentTarget;

  /// Elapsed game time in seconds (excluding pause time).
  double _elapsedTime = 0.0;
  double get elapsedTime => _elapsedTime;

  /// Accumulated penalty time in seconds.
  double _penaltyTime = 0.0;
  double get penaltyTime => _penaltyTime;

  /// Total display time = elapsed + penalty.
  double get totalTime => _elapsedTime + _penaltyTime;

  /// Whether the game timer is actively running.
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  /// Current game phase.
  BasicGamePhase _gamePhase = BasicGamePhase.ready;
  BasicGamePhase get gamePhase => _gamePhase;

  /// Internal timer for updating elapsed time.
  Timer? _timer;

  /// Monotonic stopwatch — wall-clock(`DateTime.now()`) 은 사용자가 기기 시계를
  /// 과거로 돌리면 delta 가 음수가 되어 타이머가 정지하거나 시간 조작으로
  /// 비정상 기록 제출이 가능. Dart `Stopwatch` 는 OS monotonic clock 기반이라
  /// 시계 조작에 영향받지 않음. (2026-04-24 arbitration #14)
  final Stopwatch _stopwatch = Stopwatch();
  int _lastStopwatchUs = 0;

  /// Formatted total time string with 3 decimal places.
  String get formattedTime {
    return totalTime.toStringAsFixed(basicModeTimeDecimalPlaces);
  }

  /// Progress ratio from 0.0 to 1.0 (how many of 50 numbers have been tapped).
  double get progress {
    return (_currentTarget - 1) / basicModeMaxNumber;
  }

  /// Starts a new game. Resets all state and begins the timer.
  void startGame() {
    _currentTarget = 1;
    _elapsedTime = 0.0;
    _penaltyTime = 0.0;
    _isRunning = true;
    _gamePhase = BasicGamePhase.playing;
    _stopwatch.reset();
    _lastStopwatchUs = 0;
    _startTimer();
    notifyListeners();
  }

  /// Handles a number tap.
  ///
  /// Returns `true` if [number] matches [currentTarget] (correct),
  /// `false` otherwise (wrong — penalty applied).
  bool tapNumber(int number) {
    if (_gamePhase != BasicGamePhase.playing) return false;

    if (number == _currentTarget) {
      _currentTarget++;
      // Check if game is complete (all 1–50 tapped).
      if (_currentTarget > basicModeMaxNumber) {
        _complete();
      }
      notifyListeners();
      return true;
    } else {
      // Wrong answer: apply time penalty.
      _penaltyTime += basicModeWrongPenaltySeconds;
      notifyListeners();
      return false;
    }
  }

  /// Pauses the game (e.g. when app goes to background).
  void pause() {
    if (_gamePhase != BasicGamePhase.playing) return;
    _syncElapsedTime();
    _stopTimer();
    _isRunning = false;
    _gamePhase = BasicGamePhase.paused;
    notifyListeners();
  }

  /// Resumes the game after a pause.
  void resume() {
    if (_gamePhase != BasicGamePhase.paused) return;
    _isRunning = true;
    _gamePhase = BasicGamePhase.playing;
    _startTimer();
    notifyListeners();
  }

  /// Resets all state back to initial values.
  void reset() {
    _stopTimer();
    _stopwatch.reset();
    _lastStopwatchUs = 0;
    _currentTarget = 1;
    _elapsedTime = 0.0;
    _penaltyTime = 0.0;
    _isRunning = false;
    _gamePhase = BasicGamePhase.ready;
    notifyListeners();
  }

  /// Completes the game.
  void _complete() {
    _syncElapsedTime();
    _stopTimer();
    _isRunning = false;
    _gamePhase = BasicGamePhase.completed;
  }

  /// Starts the internal periodic timer.
  void _startTimer() {
    // Stopwatch 는 누적 시간을 보전하며 start/stop 을 반복해도 elapsed 가 누적됨.
    // pause 후 resume 시 동일 stopwatch 를 다시 start — pause 이전 누적 보존.
    _stopwatch.start();
    _lastStopwatchUs = _stopwatch.elapsedMicroseconds;
    // 16ms (~60Hz) matches vsync — faster ticks would bounce against the
    // display refresh and waste notifyListeners on frames that can't render.
    _timer = Timer.periodic(_tickInterval, (_) {
      _syncElapsedTime();
      notifyListeners();
    });
  }

  /// Synchronizes elapsed time based on monotonic stopwatch delta.
  void _syncElapsedTime() {
    if (!_stopwatch.isRunning) return;
    final currentUs = _stopwatch.elapsedMicroseconds;
    _elapsedTime += (currentUs - _lastStopwatchUs) / 1000000.0;
    _lastStopwatchUs = currentUs;
  }

  /// Stops the internal timer.
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
