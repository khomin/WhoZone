import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
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
  final tag = 'animCameraButtons';

  late final Animation<double> opacity;
  late final Animation<double> _width;
  late final Animation<double> _height;
  late final Animation<double> _borderRadius;
  late final Animation<double> _leftOffset;
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

  @override
  void initState() {
    super.initState();

    // // Animate all of the info items in the list:
    // tabInfoItems = tabInfoItems
    //     .animate(interval: 100.ms)
    //     .fadeIn(duration: 200.ms, delay: 300.ms)
    //     .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
    //     .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);

    Future.microtask(() {
      if (!mounted) return;
      tabInfoItems = [
        for (final tab in tabs)
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

    _width = Tween<double>(
      begin: 55.0,
      end: 120.0,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.125,
          0.250,
          curve: Curves.ease,
        )));
    _height = Tween<double>(begin: 55.0, end: 100.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(
          0.250,
          0.375,
          curve: Curves.ease,
        )));
    _borderRadius =
        Tween<double>(begin: 60.0, end: 25.0).animate(CurvedAnimation(
            parent: _controller.view,
            curve: const Interval(
              0.000,
              0.125,
              curve: Curves.ease,
            )
            // curve: Curves.easeInOut,
            ));
    _leftOffset = Tween<double>(begin: 40.0, end: 10.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.150, 0.225, curve: Curves.easeIn)));
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
