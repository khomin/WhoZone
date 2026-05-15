import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedCameraButtons extends StatefulWidget {
  const AnimatedCameraButtons({super.key});

  @override
  State<AnimatedCameraButtons> createState() => AnimatedCameraButtonsState();
}

class TabInfo {
  const TabInfo({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class AnimatedCameraButtonsState extends State<AnimatedCameraButtons>
    with TickerProviderStateMixin {
  late final Animation<double> opacity;
  late AnimationController _controller;
  final List<TabInfo> tabs = [
    const TabInfo(
      icon: Icons.info_outline,
      label: 'Mode',
    ),
    const TabInfo(icon: Icons.palette_outlined, label: 'Take image'),
    const TabInfo(icon: Icons.palette_outlined, label: 'Flip'),
  ];
  var tabInfoItems = <Widget>[];
  final tag = 'animCameraButtons';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      tabInfoItems = [
        for (final _ in tabs)
          RoundButton(
              color: Theme.of(context)
                  .colorScheme
                  .colorBgUnderCard
                  .withValues(alpha: 0.3),
              iconColor: Theme.of(context)
                  .colorScheme
                  .colorCard
                  .withValues(alpha: 0.8),
              size: 55,
              useScaleAnimation: true,
              iconData: Icons.hdr_auto,
              onPressed: (v) async {})
      ];
    });
    tabInfoItems = tabInfoItems
        .animate(interval: 100.ms)
        .fadeIn(duration: 200.ms, delay: 50.ms)
        .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
        .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: tabInfoItems),
    );
  }
}
