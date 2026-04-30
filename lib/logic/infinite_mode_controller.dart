import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/constants.dart';

/// Phases of an infinite-mode game.
enum InfiniteGamePhase {
  /// Waiting to start.
  ready,

  /// Actively playing.
  playing,

  /// Paused (e.g. app backgrounded).
  paused,

  /// Time ran out — game over.
  gameOver,
}

/// Controls game state for the Infinite (survival) mode.
///
/// The player taps numbers in sequence while a countdown timer ticks.
/// Correct taps recover time; wrong taps subtract time.
/// Numbers go from 1–999 per loop, then the loop increments.
class InfiniteModeController extends ChangeNotifier {
  int _currentTarget = 1;
  int get currentTarget => _currentTarget;

  int _currentLoop = 0;
  int get currentLoop => _currentLoop;

  double _remainingTime = infiniteModeInitialTimeSeconds;
  double get remainingTime => _remainingTime;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  InfiniteGamePhase _gamePhase = InfiniteGamePhase.ready;
  InfiniteGamePhase get gamePhase => _gamePhase;

  bool _awaitingIconTap = false;
  bool get awaitingIconTap => _awaitingIconTap;

  Timer? _timer;

  final Stopwatch _stopwatch = Stopwatch();
  int _lastStopwatchUs = 0;

  double _accumulatedPlayMs = 0;

  int get totalScore =>
      _currentLoop * infiniteModeNumbersPerLoop + _currentTarget;

  int get elapsedPlayMs => _accumulatedPlayMs.round();

  double get currentRecoveryTime {
    final recovery =
        infiniteModeBaseRecoverySeconds -
        _currentLoop * infiniteModeRecoveryDecreasePerLoop;
    return recovery < infiniteModeMinRecoverySeconds
        ? infiniteModeMinRecoverySeconds
        : recovery;
  }

  double get remainingTimeRatio {
    return (_remainingTime / infiniteModeTimeCapSeconds).clamp(0.0, 1.0);
  }

  void startGame() {
    _currentTarget = 1;
    _currentLoop = 0;
    _remainingTime = infiniteModeInitialTimeSeconds;
    _isRunning = true;
    _awaitingIconTap = false;
    _accumulatedPlayMs = 0;
    _stopwatch.reset();
    _lastStopwatchUs = 0;
    _gamePhase = InfiniteGamePhase.playing;
    _startTimer();
    notifyListeners();
  }

  bool tapNumber(int number) {
    if (_gamePhase != InfiniteGamePhase.playing) return false;

    if (_awaitingIconTap) {
      if (number == -1) {
        _advanceLoop();
        return true;
      } else {
        _applyWrongPenalty();
        return false;
      }
    }

    if (number == _currentTarget) {
      _addRecoveryTime();
      _currentTarget++;

      if (_currentTarget > infiniteModeMaxNumberPerLoop) {
        _awaitingIconTap = true;
      }

      notifyListeners();
      return true;
    } else {
      _applyWrongPenalty();
      return false;
    }
  }

  void pause() {
    if (_gamePhase != InfiniteGamePhase.playing) return;
    _syncRemainingTime();
    _stopTimer();
    _isRunning = false;
    _gamePhase = InfiniteGamePhase.paused;
    notifyListeners();
  }

  void resume() {
    if (_gamePhase != InfiniteGamePhase.paused) return;
    _isRunning = true;
    _gamePhase = InfiniteGamePhase.playing;
    _startTimer();
    notifyListeners();
  }

  void reset() {
    _stopTimer();
    _stopwatch.reset();
    _lastStopwatchUs = 0;
    _currentTarget = 1;
    _currentLoop = 0;
    _remainingTime = infiniteModeInitialTimeSeconds;
    _isRunning = false;
    _awaitingIconTap = false;
    _gamePhase = InfiniteGamePhase.ready;
    notifyListeners();
  }

  void _advanceLoop() {
    _addRecoveryTime();
    _currentLoop++;
    _currentTarget = 1;
    _awaitingIconTap = false;
    notifyListeners();
  }

  void _addRecoveryTime() {
    _syncRemainingTime();
    _remainingTime = (_remainingTime + currentRecoveryTime).clamp(
      0.0,
      infiniteModeTimeCapSeconds,
    );
  }

  void _applyWrongPenalty() {
    _syncRemainingTime();
    _remainingTime -= infiniteModeWrongPenaltySeconds;
    if (_remainingTime <= 0) {
      _onTimeExpired();
    }
    notifyListeners();
  }

  void _startTimer() {
    _stopwatch.start();
    _lastStopwatchUs = _stopwatch.elapsedMicroseconds;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _syncRemainingTime();
      if (_remainingTime <= 0) {
        _onTimeExpired();
        notifyListeners();
        return;
      }
      notifyListeners();
    });
  }

  void _syncRemainingTime() {
    if (!_stopwatch.isRunning) return;
    final currentUs = _stopwatch.elapsedMicroseconds;
    final deltaUs = currentUs - _lastStopwatchUs;
    _remainingTime -= deltaUs / 1000000.0;
    _accumulatedPlayMs += deltaUs / 1000.0;
    _lastStopwatchUs = currentUs;
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
  }

  /// Called when remaining time drops to (or below) zero.
  /// Web: revive 기능이 없으므로 즉시 gameOver로 전환한다.
  void _onTimeExpired() {
    _stopTimer();
    _remainingTime = 0;
    _isRunning = false;
    _gamePhase = InfiniteGamePhase.gameOver;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
