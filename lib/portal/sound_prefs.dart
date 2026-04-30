import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../services/audio_service.dart';

/// 사운드 볼륨 (0.0~1.0) 영속 저장소.
///
/// `AudioService.volume` 와 양방향 동기화. 외부에서는 [hydrate] / [setVolume]
/// 두 메서드만 사용한다. 0 이면 mute (UI 에서 mute 아이콘 표시).
class SoundPrefs extends ChangeNotifier {
  SoundPrefs._();
  static final SoundPrefs instance = SoundPrefs._();

  static const _volumeKey = 'hbjj_sound_volume';
  static const _lastKey = 'hbjj_sound_last_nonzero';

  double _volume = 1.0;

  /// mute 상태에서 unmute 시 복원할 마지막 양수 볼륨.
  /// 페이지 새로고침 후에도 유지되도록 별도 키로 영속.
  double _lastNonZero = 1.0;

  double get volume => _volume;
  bool get isMuted => _volume <= 0;

  void hydrate() {
    _volume = _read(_volumeKey) ?? 1.0;
    _lastNonZero =
        _read(_lastKey) ?? (_volume > 0 ? _volume : 1.0);
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

  /// 스피커 아이콘 탭 — 0 ↔ 마지막 양수 볼륨 토글.
  Future<void> toggleMute() async {
    if (_volume > 0) {
      // 현재 양수 → mute. _lastNonZero 는 setVolume 호출 직전에 보존되므로
      // 여기서 별도 저장 안 해도 OK.
      await setVolume(0);
    } else {
      await setVolume(_lastNonZero == 0 ? 1.0 : _lastNonZero);
    }
  }

  double? _read(String key) {
    try {
      final v = web.window.localStorage.getItem(key);
      if (v == null) return null;
      return double.tryParse(v);
    } catch (e) {
      debugPrint('SoundPrefs read failed: $e');
      return null;
    }
  }

  void _write(String key, double v) {
    try {
      web.window.localStorage.setItem(key, v.toStringAsFixed(2));
    } catch (e) {
      debugPrint('SoundPrefs write failed: $e');
    }
  }
}
