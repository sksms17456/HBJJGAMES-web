import 'package:flutter_test/flutter_test.dart';
import 'package:hbjjgames_web/logic/basic_mode_controller.dart';

void main() {
  late BasicModeController controller;

  setUp(() {
    controller = BasicModeController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('initial state', () {
    test('starts in ready phase', () {
      expect(controller.gamePhase, BasicGamePhase.ready);
    });

    test('current target is 1', () {
      expect(controller.currentTarget, 1);
    });

    test('elapsed time is 0', () {
      expect(controller.elapsedTime, 0.0);
    });

    test('is not running', () {
      expect(controller.isRunning, isFalse);
    });
  });

  group('startGame', () {
    test('sets phase to playing', () {
      controller.startGame();
      expect(controller.gamePhase, BasicGamePhase.playing);
    });

    test('sets isRunning to true', () {
      controller.startGame();
      expect(controller.isRunning, isTrue);
    });
  });

  group('tapNumber', () {
    test('correct tap advances target', () {
      controller.startGame();
      final result = controller.tapNumber(1);
      expect(result, isTrue);
      expect(controller.currentTarget, 2);
    });

    test('wrong tap does not advance target', () {
      controller.startGame();
      final result = controller.tapNumber(5);
      expect(result, isFalse);
      expect(controller.currentTarget, 1);
    });

    test('wrong tap adds penalty time', () {
      controller.startGame();
      controller.tapNumber(5);
      expect(controller.penaltyTime, 5.0);
    });

    test('multiple wrong taps accumulate penalty', () {
      controller.startGame();
      controller.tapNumber(5);
      controller.tapNumber(5);
      expect(controller.penaltyTime, 10.0);
    });

    test('tapping all 50 numbers completes the game', () {
      controller.startGame();
      for (int i = 1; i <= 50; i++) {
        controller.tapNumber(i);
      }
      expect(controller.gamePhase, BasicGamePhase.completed);
      expect(controller.isRunning, isFalse);
    });

    test('tap is ignored when not playing', () {
      final result = controller.tapNumber(1);
      expect(result, isFalse);
    });
  });

  group('pause and resume', () {
    test('pause sets phase to paused', () {
      controller.startGame();
      controller.pause();
      expect(controller.gamePhase, BasicGamePhase.paused);
      expect(controller.isRunning, isFalse);
    });

    test('resume sets phase back to playing', () {
      controller.startGame();
      controller.pause();
      controller.resume();
      expect(controller.gamePhase, BasicGamePhase.playing);
      expect(controller.isRunning, isTrue);
    });

    test('pause is ignored when not playing', () {
      controller.pause();
      expect(controller.gamePhase, BasicGamePhase.ready);
    });

    test('resume is ignored when not paused', () {
      controller.startGame();
      controller.resume();
      expect(controller.gamePhase, BasicGamePhase.playing);
    });
  });

  group('reset', () {
    test('resets all state', () {
      controller.startGame();
      controller.tapNumber(1);
      controller.tapNumber(3); // wrong
      controller.reset();
      expect(controller.currentTarget, 1);
      expect(controller.elapsedTime, 0.0);
      expect(controller.penaltyTime, 0.0);
      expect(controller.isRunning, isFalse);
      expect(controller.gamePhase, BasicGamePhase.ready);
    });
  });

  group('progress', () {
    test('progress is 0.0 at start', () {
      expect(controller.progress, 0.0);
    });

    test('progress increases after correct taps', () {
      controller.startGame();
      controller.tapNumber(1);
      expect(controller.progress, 1 / 50);
    });
  });
}
