import 'package:flutter/material.dart';

import 'constants.dart';

/// 무한모드 Loop 전환 아이콘 20종. Loop 0 → index 0, Loop 1 → index 1, …
/// Loop 20 은 다시 index 0 으로 순환한다.
///
/// 선정 기준: 카드(28px)·타겟 헤더(56px) 양쪽에서 실루엣이 뚜렷하고
/// 문화권 편향이 적은 Material 아이콘. 색상은 호출부에서 덧씌운다.
const List<IconData> loopIcons = [
  Icons.star_rounded,
  Icons.favorite_rounded,
  Icons.bolt_rounded,
  Icons.diamond_rounded,
  Icons.local_fire_department_rounded,
  Icons.ac_unit_rounded,
  Icons.water_drop_rounded,
  Icons.wb_sunny_rounded,
  Icons.nightlight_round,
  Icons.cloud_rounded,
  Icons.spa_rounded,
  Icons.eco_rounded,
  Icons.pets_rounded,
  Icons.cake_rounded,
  Icons.rocket_launch_rounded,
  Icons.music_note_rounded,
  Icons.flag_rounded,
  Icons.celebration_rounded,
  Icons.auto_awesome_rounded,
  Icons.emoji_emotions_rounded,
];

/// Returns the icon for the given 0-based loop number, cycling every
/// [loopIconTypeCount] loops. Accepts negative loop defensively by clamping
/// into a valid modular bucket.
IconData loopIconFor(int loop) {
  final idx =
      (loop % loopIconTypeCount + loopIconTypeCount) % loopIconTypeCount;
  return loopIcons[idx];
}
