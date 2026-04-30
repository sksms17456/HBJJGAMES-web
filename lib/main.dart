import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'portal/sound_prefs.dart';
import 'portal/web_local_storage.dart';
import 'services/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Jua 는 assets/fonts 에 번들돼 있고 그 외 GoogleFonts.* 호출은 시스템
  // 기본으로 폴백한다 — runtime fetching 막아 첫 진입 네트워크 트래픽 0.
  GoogleFonts.config.allowRuntimeFetching = false;
  // sound_prefs.dart 가 package:web 의존을 들이지 않도록 store 를 main 에서
  // 주입. test 환경(VM) 에서는 default InMemory 가 사용된다.
  SoundPrefs.instance = SoundPrefs(store: const WebLocalStorage());
  SoundPrefs.instance.hydrate();
  AudioService.instance.init();

  runApp(const HbjjGamesApp());
}
