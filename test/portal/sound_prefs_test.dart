import 'package:flutter_test/flutter_test.dart';
import 'package:hbjjgames_web/portal/sound_prefs.dart';

void main() {
  group('SoundPrefs with InMemoryKeyValueStore', () {
    late InMemoryKeyValueStore store;
    late SoundPrefs prefs;

    setUp(() {
      store = InMemoryKeyValueStore();
      prefs = SoundPrefs(store: store);
    });

    test('hydrate without prior data → volume=1.0 (default)', () {
      prefs.hydrate();
      expect(prefs.volume, 1.0);
      expect(prefs.isMuted, isFalse);
    });

    test('hydrate reads stored volume', () {
      store.write('hbjj_sound_volume', '0.42');
      prefs.hydrate();
      expect(prefs.volume, closeTo(0.42, 0.0001));
    });

    test('setVolume clamps + persists', () async {
      prefs.hydrate();
      await prefs.setVolume(0.7);
      expect(prefs.volume, 0.7);
      expect(store.read('hbjj_sound_volume'), '0.70');
      // _lastNonZero 도 갱신 (0이 아니므로)
      expect(store.read('hbjj_sound_last_nonzero'), '0.70');
    });

    test('setVolume(2.0) clamps to 1.0', () async {
      prefs.hydrate();
      await prefs.setVolume(2.0);
      expect(prefs.volume, 1.0);
    });

    test('setVolume(-0.5) clamps to 0.0', () async {
      prefs.hydrate();
      await prefs.setVolume(-0.5);
      expect(prefs.volume, 0.0);
      expect(prefs.isMuted, isTrue);
    });

    test('toggleMute: 양수 → 0, 다시 toggle → 직전 양수로 복원', () async {
      prefs.hydrate();
      await prefs.setVolume(0.6);
      await prefs.toggleMute();
      expect(prefs.volume, 0.0);
      expect(prefs.isMuted, isTrue);
      // _lastNonZero 는 0.6 영속
      expect(store.read('hbjj_sound_last_nonzero'), '0.60');
      await prefs.toggleMute();
      expect(prefs.volume, closeTo(0.6, 0.001));
      expect(prefs.isMuted, isFalse);
    });

    test('toggleMute when stored=0 and lastNonZero=0 → fallback 1.0', () async {
      // 새 사용자가 vol=0 으로 시작한 엣지 케이스.
      store.write('hbjj_sound_volume', '0.00');
      store.write('hbjj_sound_last_nonzero', '0.00');
      prefs.hydrate();
      await prefs.toggleMute();
      expect(prefs.volume, 1.0);
    });

    test('새로고침 시뮬: 같은 store 로 새 인스턴스 생성하면 값 유지', () async {
      prefs.hydrate();
      await prefs.setVolume(0.33);

      // 새로고침 시뮬 — 새 SoundPrefs 인스턴스, 같은 store
      final reloaded = SoundPrefs(store: store);
      reloaded.hydrate();
      expect(reloaded.volume, closeTo(0.33, 0.001));
    });

    test('mute 후 새로고침 시 last_nonzero 영속 유지', () async {
      prefs.hydrate();
      await prefs.setVolume(0.5);
      await prefs.toggleMute(); // → 0

      final reloaded = SoundPrefs(store: store);
      reloaded.hydrate();
      expect(reloaded.volume, 0.0);
      // toggleMute → 0.5 복원 가능해야
      await reloaded.toggleMute();
      expect(reloaded.volume, closeTo(0.5, 0.001));
    });

    test('notifyListeners 가 setVolume/toggleMute 마다 호출', () async {
      prefs.hydrate();
      var count = 0;
      prefs.addListener(() => count++);
      await prefs.setVolume(0.4);
      await prefs.toggleMute();
      expect(count, 2);
    });
  });
}
