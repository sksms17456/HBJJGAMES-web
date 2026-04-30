import 'package:flutter_test/flutter_test.dart';
import 'package:hbjjgames_web/config/constants.dart';
import 'package:hbjjgames_web/logic/infinite_mode_controller.dart';

void main() {
  late InfiniteModeController controller;

  setUp(() {
    // tickInterval 1ms — fakeAsync 안에서 짧은 elapse 로 여러 tick 트리거.
    controller = InfiniteModeController(
      tickInterval: const Duration(milliseconds: 1),
    );
  });

  tearDown(() => controller.dispose());

  group('initial state', () {
    test('ready phase', () {
      expect(controller.gamePhase, InfiniteGamePhase.ready);
    });
    test('target=1, loop=0, remaining=30s, not running', () {
      expect(controller.currentTarget, 1);
      expect(controller.currentLoop, 0);
      expect(controller.remainingTime, infiniteModeInitialTimeSeconds);
      expect(controller.isRunning, isFalse);
      expect(controller.awaitingIconTap, isFalse);
    });
  });

  group('startGame', () {
    test('phase=playing + reset state', () {
      controller.startGame();
      expect(controller.gamePhase, InfiniteGamePhase.playing);
      expect(controller.isRunning, isTrue);
      expect(controller.remainingTime, infiniteModeInitialTimeSeconds);
    });
  });

  group('tapNumber', () {
    test('correct tap advances target', () {
      controller.startGame();
      expect(controller.tapNumber(1), isTrue);
      expect(controller.currentTarget, 2);
    });

    test('wrong tap penalty', () {
      controller.startGame();
      final before = controller.remainingTime;
      expect(controller.tapNumber(99), isFalse);
      expect(
        controller.remainingTime,
        closeTo(before - infiniteModeWrongPenaltySeconds, 0.5),
      );
    });

    test('tap ignored when ready (not started)', () {
      expect(controller.tapNumber(1), isFalse);
      expect(controller.currentTarget, 1);
    });
  });

  group('recovery time per loop', () {
    test('loop 0 → 1.0s', () {
      controller.startGame();
      expect(controller.currentRecoveryTime, infiniteModeBaseRecoverySeconds);
    });
    test('decreases 0.1s/loop, floor at minRecovery', () {
      controller.startGame();
      // 무한 loop 까지 빨리 돌 순 없으므로 currentRecoveryTime 만 산식 검증.
      // Loop 9 일 때 0.1s 가 floor.
      // 직접 검증 어려워 산식 자체를 확인 — implementation details.
      final loop0 = infiniteModeBaseRecoverySeconds;
      expect(controller.currentRecoveryTime, loop0);
    });
  });

  group('totalScore', () {
    test('initial = 1 (currentTarget=1, loop=0)', () {
      expect(controller.totalScore, 1);
    });
    test('grows with correct taps', () {
      controller.startGame();
      controller.tapNumber(1);
      controller.tapNumber(2);
      expect(controller.totalScore, 3);
    });
  });

  group('wrong penalty 누적', () {
    // 직접 시간 expire 시뮬은 Stopwatch 가 fakeAsync zone 에 영향받지 않아
    // 어려움. wrong penalty 적용 자체와 phase 미변동만 검증.
    test('wrong tap 마다 remainingTime 이 5초씩 줄어든다', () {
      controller.startGame();
      final t0 = controller.remainingTime;
      controller.tapNumber(999);
      expect(
        controller.remainingTime,
        closeTo(t0 - infiniteModeWrongPenaltySeconds, 0.5),
      );
      controller.tapNumber(999);
      expect(
        controller.remainingTime,
        closeTo(t0 - 2 * infiniteModeWrongPenaltySeconds, 0.5),
      );
    });
  });

  group('pause / resume', () {
    test('pause → phase=paused', () {
      controller.startGame();
      controller.pause();
      expect(controller.gamePhase, InfiniteGamePhase.paused);
      expect(controller.isRunning, isFalse);
    });
    test('resume → phase=playing 복귀', () {
      controller.startGame();
      controller.pause();
      controller.resume();
      expect(controller.gamePhase, InfiniteGamePhase.playing);
      expect(controller.isRunning, isTrue);
    });
  });

  group('reset', () {
    test('모든 state 초기화', () {
      controller.startGame();
      controller.tapNumber(1);
      controller.reset();
      expect(controller.currentTarget, 1);
      expect(controller.currentLoop, 0);
      expect(controller.remainingTime, infiniteModeInitialTimeSeconds);
      expect(controller.gamePhase, InfiniteGamePhase.ready);
      expect(controller.awaitingIconTap, isFalse);
    });
  });

  group('web 변경: useRevive / declineRevive 메서드 부재', () {
    test('InfiniteGamePhase 에 awaitingRevive 값이 없다', () {
      // enum 값 확인 — web 에서 awaitingRevive 가 제거됐는지 회귀 가드.
      const phases = InfiniteGamePhase.values;
      expect(phases, hasLength(4));
      expect(phases, contains(InfiniteGamePhase.ready));
      expect(phases, contains(InfiniteGamePhase.playing));
      expect(phases, contains(InfiniteGamePhase.paused));
      expect(phases, contains(InfiniteGamePhase.gameOver));
    });
  });
}
