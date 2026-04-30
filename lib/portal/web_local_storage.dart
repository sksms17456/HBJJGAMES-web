import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'sound_prefs.dart';

/// 브라우저 localStorage 어댑터. main.dart 에서 [SoundPrefs.instance] 의 store
/// 로 주입한다. test 환경 (VM) 에서는 web 의존이 깨지므로 import 분리 — 이
/// 파일은 main 만 참조하고 sound_prefs.dart 는 import 하지 않는다.
class WebLocalStorage implements KeyValueStore {
  const WebLocalStorage();

  @override
  String? read(String key) {
    try {
      return web.window.localStorage.getItem(key);
    } catch (e) {
      debugPrint('WebLocalStorage read failed: $e');
      return null;
    }
  }

  @override
  void write(String key, String value) {
    try {
      web.window.localStorage.setItem(key, value);
    } catch (e) {
      debugPrint('WebLocalStorage write failed: $e');
    }
  }
}
