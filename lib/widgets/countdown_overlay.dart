import 'dart:async';

import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

class CountdownOverlay extends StatefulWidget {
  const CountdownOverlay({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int _count = resumeCountdownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_count <= 1) {
        _timer?.cancel();
        widget.onComplete();
      } else {
        setState(() => _count--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: Text(
        '$_count',
        style: AppTextStyles.resultScore.copyWith(fontSize: 72),
      ),
    );
  }
}
