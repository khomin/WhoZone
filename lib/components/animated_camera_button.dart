import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/button_round_corner.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:provider/provider.dart';

class AnimatedCameraButton extends StatefulWidget {
  const AnimatedCameraButton({
    required this.onCapture,
    required this.onStop,
    required this.onImagePressed,
    required this.activeDefault,
    super.key,
    required this.widthStart,
    required this.widthEnd,
  });
  final double widthStart;
  final double widthEnd;
  final Function() onCapture;
  final Function() onStop;
  final bool activeDefault;
  final Function() onImagePressed;

  @override
  State<AnimatedCameraButton> createState() => AnimatedCameraButtonState();
}

class TabInfo {
  const TabInfo({required this.icon});
  final IconData icon;
}

class AnimatedCameraButtonState extends State<AnimatedCameraButton>
    with TickerProviderStateMixin {
  final _animatedModel = AnimatedModel();
  late final Animation<double> _opacity1;
  late final Animation<double> _opacity2;
  late final Animation<double> _widthAnimation;
  late final Animation<double> _widthIconExpand;
  late AnimationController _controller;
  final _dispStream = DisposableStream();

  final List<TabInfo> tabs = [
    const TabInfo(icon: Icons.info_outline),
    const TabInfo(icon: Icons.palette_outlined),
  ];
  final tag = 'animCameraButton';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: widget.widthStart,
      end: widget.widthEnd,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _widthIconExpand = Tween<double>(
      begin: 5.0,
      end: 40.0,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));
    _opacity1 = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _opacity2 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    if (widget.activeDefault) {
      _animatedModel.expanded = true;
      _controller.forward().orCancel;
    }
  }

  Future<void> _switchAnimation() async {
    try {
      if (_animatedModel.expanded) {
        widget.onStop();
      } else {
        widget.onCapture();
      }
      if (_controller.isForwardOrCompleted) {
        await _controller.reverse().orCancel;
      } else {
        await _controller.forward().orCancel;
      }
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    _controller.dispose();
    _dispStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AnimatedModel>.value(
      value: _animatedModel,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(90)),
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      width: _widthAnimation.value,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.colorButton,
                        borderRadius: BorderRadius.all(Radius.circular(90)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                              opacity: _opacity1.value,
                              child: Builder(builder: (context) {
                                var expanded =
                                    context.select<AnimatedModel, bool>(
                                  (v) => v.expanded,
                                );
                                return IgnorePointer(
                                    ignoring: expanded,
                                    child: _recordButton(
                                      () {
                                        _switchAnimation();
                                        context
                                            .read<AnimatedModel>()
                                            .setExpanded(!expanded);
                                      },
                                    ));
                              })),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Opacity(
                                    opacity: _opacity2.value,
                                    child: Builder(builder: (context) {
                                      var expanded =
                                          context.select<AnimatedModel, bool>(
                                              (v) => v.expanded);
                                      return IgnorePointer(
                                          ignoring: !expanded,
                                          child: ButtonRoundCorner(
                                              color: Colors.transparent,
                                              width: _widthAnimation.value / 2,
                                              icon: Icon(
                                                Icons.camera_sharp,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .cameraButtonIcon,
                                                size: _widthIconExpand.value,
                                              ),
                                              radious: const BorderRadius.only(
                                                topLeft: Radius.circular(90),
                                                bottomLeft: Radius.circular(90),
                                              ),
                                              onPressed: () {
                                                widget.onImagePressed();
                                              }));
                                    })),
                                Opacity(
                                  opacity: _opacity2.value,
                                  child: Builder(
                                    builder: (context) {
                                      var expanded =
                                          context.select<AnimatedModel, bool>(
                                              (v) => v.expanded);
                                      return ButtonRoundCorner(
                                          color: Colors.transparent,
                                          width: _widthAnimation.value / 2,
                                          icon: Icon(
                                            Icons.stop_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .cameraButtonIcon,
                                            size: _widthIconExpand.value,
                                          ),
                                          radious: const BorderRadius.only(
                                            topRight: Radius.circular(90),
                                            bottomRight: Radius.circular(90),
                                          ),
                                          onPressed: () {
                                            _switchAnimation();
                                            context
                                                .read<AnimatedModel>()
                                                .setExpanded(!expanded);
                                          });
                                    },
                                  ),
                                )
                              ])
                        ],
                      ),
                    )));
          },
        );
      },
    );
  }

  Widget _recordButton(Function() onPressed) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Stack(alignment: Alignment.center, children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ])),
    );
  }
}

class AnimatedModel with ChangeNotifier {
  bool expanded = false;

  void setExpanded(bool v) {
    if (expanded != v) {
      expanded = v;
      notifyListeners();
    }
  }
}
