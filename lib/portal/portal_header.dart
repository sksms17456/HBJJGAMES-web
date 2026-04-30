import 'package:flutter/material.dart';

import '../config/theme.dart';
import 'sound_prefs.dart';

/// 포털 상단 헤더 — HBJJGAMES 로고/타이틀 + 사운드 볼륨 슬라이더.
class PortalHeader extends StatelessWidget {
  const PortalHeader({super.key, required this.onLogoTap});

  final VoidCallback onLogoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: Color(0xFF1A1A2A), width: 1),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onLogoTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                'HBJJGAMES',
                style: AppTextStyles.title.copyWith(
                  fontSize: 22,
                  letterSpacing: 1.2,
                  color: AppColors.numberText,
                ),
              ),
            ),
          ),
          const Spacer(),
          const _VolumeControl(),
        ],
      ),
    );
  }
}

class _VolumeControl extends StatelessWidget {
  const _VolumeControl();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SoundPrefs.instance,
      builder: (_, _) {
        final v = SoundPrefs.instance.volume;
        final muted = v <= 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => SoundPrefs.instance.toggleMute(),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: AppColors.numberText,
                  size: 22,
                ),
              ),
            ),
            SizedBox(
              width: 140,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  activeTrackColor: AppColors.numberText,
                  inactiveTrackColor: AppColors.subText.withValues(alpha: 0.3),
                  thumbColor: AppColors.numberText,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  overlayColor: AppColors.numberText.withValues(alpha: 0.15),
                ),
                child: Slider(
                  value: v,
                  onChanged: (val) => SoundPrefs.instance.setVolume(val),
                ),
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '${(v * 100).round()}',
                textAlign: TextAlign.right,
                style: AppTextStyles.smallText.copyWith(
                  fontSize: 13,
                  color: AppColors.numberText,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
