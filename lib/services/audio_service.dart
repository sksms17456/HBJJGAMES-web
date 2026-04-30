import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show AssetManifest, rootBundle;

/// Manages game sound effects.
///
/// Web 단순화 버전: storage 의존을 제거하고 [enabled] 만 외부에서 토글.
/// 영속은 호출자(`SoundPrefs`)가 localStorage 로 별도 처리.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  static const _correct = 'correct';
  static const _wrong = 'wrong';
  static const _newBest = 'new_best';
  static const _gameOver = 'game_over';
  static const _loopComplete = 'loop_complete';
  static const _gameStart = 'game_start';
  static const _buttonTap = 'button_tap';

  static const eventKeys = <String>[
    _correct,
    _wrong,
    _newBest,
    _gameOver,
    _loopComplete,
    _gameStart,
    _buttonTap,
  ];

  static const _assetPrefix = 'assets/sounds/';
  static const _candidateExtensions = <String>['.mp3', '.m4a', '.wav', '.ogg'];

  final Map<String, AudioPlayer> _players = {};
  final Map<String, String> _fileNames = {};
  final Set<String> _preloaded = {};
  double _volume = 1.0;
  bool _initStarted = false;
  Future<void>? _initFuture;

  double get volume => _volume;

  /// 볼륨 0.0~1.0. 0 이면 재생 자체를 short-circuit. SoundPrefs 가
  /// localStorage 영속을 책임지므로 여기서는 player 들에만 반영.
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    for (final p in _players.values) {
      try {
        await p.setVolume(_volume);
      } catch (_) {}
    }
    if (_volume == 0) {
      stopAll();
    }
  }

  Future<void> init() async {
    if (_initStarted) return _initFuture!;
    _initStarted = true;
    _initFuture = _runInit();
    return _initFuture!;
  }

  Future<void> _runInit() async {
    await _createPlayers();
    await _resolveFileNames();
    debugPrint(
      'AudioService init resolved ${_fileNames.length}/${eventKeys.length} '
      '— $_fileNames',
    );
    await _preloadAll();
  }

  Future<void> _createPlayers() async {
    for (final key in eventKeys) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      try {
        await player.setVolume(_volume);
      } catch (_) {}
      _players[key] = player;
    }
  }

  Future<void> _preloadAll() async {
    await Future.wait([
      for (final entry in _fileNames.entries) _preload(entry.key, entry.value),
    ]);
  }

  Future<void> _resolveFileNames() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      for (final key in eventKeys) {
        final prefix = '$_assetPrefix$key.';
        final match = allAssets.firstWhere(
          (path) => path.startsWith(prefix),
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          _fileNames[key] = match.substring(_assetPrefix.length);
        }
      }
    } catch (e) {
      debugPrint('AudioService manifest read failed: $e');
    }
  }

  Future<void> _preload(String key, String fileName) async {
    final player = _players[key];
    if (player == null) return;
    try {
      await player.setSource(AssetSource('sounds/$fileName'));
      _preloaded.add(key);
    } catch (e) {
      debugPrint('AudioService $key preload failed: $e');
    }
  }

  Future<void> _play(String key) async {
    if (_volume <= 0) return;
    // 첫 탭이 init 완료 전에 들어오면 manifest/preload 끝날 때까지 대기 →
    // _candidateExtensions 4회 fallback try 루프 회피.
    if (_initFuture != null) {
      await _initFuture;
    }
    final player = _players[key];
    if (player == null) return;

    if (_preloaded.contains(key)) {
      try {
        await player.seek(Duration.zero);
        await player.resume();
      } catch (e) {
        debugPrint('AudioService $key resume failed: $e');
      }
      return;
    }

    final cached = _fileNames[key];
    if (cached != null) {
      if (await _tryPlay(player, key, cached)) {
        _preloaded.add(key);
      }
      return;
    }

    for (final ext in _candidateExtensions) {
      final fileName = '$key$ext';
      if (await _tryPlay(player, key, fileName)) {
        _fileNames[key] = fileName;
        _preloaded.add(key);
        return;
      }
    }
    debugPrint('AudioService $key skipped: no matching asset found');
  }

  Future<bool> _tryPlay(
    AudioPlayer player,
    String key,
    String fileName,
  ) async {
    try {
      await player.play(AssetSource('sounds/$fileName'));
      return true;
    } catch (e) {
      debugPrint('AudioService $key($fileName) failed: $e');
      return false;
    }
  }

  void stopAll() {
    for (final p in _players.values) {
      p.stop();
    }
  }

  Future<void> playCorrect() => _play(_correct);
  Future<void> playWrong() => _play(_wrong);
  Future<void> playNewBest() => _play(_newBest);
  Future<void> playGameOver() => _play(_gameOver);
  Future<void> playLoopComplete() => _play(_loopComplete);
  Future<void> playGameStart() => _play(_gameStart);
  Future<void> playButtonTap() => _play(_buttonTap);
}
