import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'portal/sound_prefs.dart';
import 'services/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Jua 는 assets/fonts 에 번들돼 있고 그 외 GoogleFonts.* 호출은 시스템
  // 기본으로 폴백한다 — runtime fetching 막아 첫 진입 네트워크 트래픽 0.
  GoogleFonts.config.allowRuntimeFetching = false;
  SoundPrefs.instance.hydrate();
  AudioService.instance.init();

  runApp(const HbjjGamesApp());
}
