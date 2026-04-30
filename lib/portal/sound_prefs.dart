import 'package:flutter/foundation.dart';

import '../services/audio_service.dart';

/// 키-값 저장소 인터페이스. 프로덕션에서는 main.dart 가 `WebLocalStorage` 를
/// 주입하고, 테스트는 [InMemoryKeyValueStore] 를 사용한다.
/// (이 파일은 `package:web` 에 의존하지 않아 VM `flutter test` 환경에서도 안전.)
abstract class KeyValueStore {
  String? read(String key);
  void write(String key, String value);
}

@visibleForTesting
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  String? read(String key) => _data[key];

  @override
  void write(String key, String value) {
    _data[key] = value;
  }
}

/// 사운드 볼륨 (0.0~1.0) 영속 저장소.
class SoundPrefs extends ChangeNotifier {
  SoundPrefs({KeyValueStore? store})
    : _store = store ?? InMemoryKeyValueStore();

  /// 프로덕션 싱글턴. main.dart 가 `WebLocalStorage` 주입한 인스턴스로 교체.
  static SoundPrefs instance = SoundPrefs();

  static const _volumeKey = 'hbjj_sound_volume';
  static const _lastKey = 'hbjj_sound_last_nonzero';

  final KeyValueStore _store;

  double _volume = 1.0;
  double _lastNonZero = 1.0;

  double get volume => _volume;
  bool get isMuted => _volume <= 0;

  void hydrate() {
    _volume = _read(_volumeKey) ?? 1.0;
    _lastNonZero = _read(_lastKey) ?? (_volume > 0 ? _volume : 1.0);
    AudioService.instance.setVolume(_volume);
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    if (_volume > 0) {
      _lastNonZero = _volume;
      _write(_lastKey, _lastNonZero);
    }
    await AudioService.instance.setVolume(_volume);
    _write(_volumeKey, _volume);
    notifyListeners();
  }

  Future<void> toggleMute() async {
    if (_volume > 0) {
      await setVolume(0);
    } else {
      await setVolume(_lastNonZero == 0 ? 1.0 : _lastNonZero);
    }
  }

  double? _read(String key) {
    final v = _store.read(key);
    if (v == null) return null;
    return double.tryParse(v);
  }

  void _write(String key, double v) {
    _store.write(key, v.toStringAsFixed(2));
  }
}
