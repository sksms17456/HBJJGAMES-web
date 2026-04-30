import 'package:flutter/services.dart';

/// Provides haptic feedback for game events.
///
/// Web 단순화 버전: storage 영속 제거. 기본값 false (브라우저 햅틱은 일관성
/// 없고 모바일 사파리는 미지원). 모바일 브라우저 PWA 에서 켜고 싶으면 외부에서
/// `HapticService.instance.enabled = true` 로 토글.
class HapticService {
  HapticService._();

  static final HapticService instance = HapticService._();

  bool enabled = false;

  Future<void> lightImpact() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> mediumImpact() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavyImpact() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> correctFeedback() async {
    await lightImpact();
  }

  Future<void> wrongFeedback() async {
    await heavyImpact();
  }
}
