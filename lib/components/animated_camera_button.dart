import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_demo/components/button_round_corner.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ExpandModel with ChangeNotifier {
  bool isExpanded = false;
  void setExpanded(bool v) {
    if (isExpanded != v) {
      isExpanded = v;
      notifyListeners();
    }
  }
}

class AnimatedCameraButton extends StatefulWidget {
  const AnimatedCameraButton({
    required this.onCapture,
    required this.onStop,
    required this.onStopOutsideStream,
    this.activeDefault = false,
    super.key,
  });
  final Function() onCapture;
  final Function() onStop;
  final bool activeDefault;
  final PublishSubject<bool> onStopOutsideStream;
  @override
  State<AnimatedCameraButton> createState() => AnimatedCameraButtonState();
}

class TabInfo {
  const TabInfo({required this.icon});
  final IconData icon;
}

class AnimatedCameraButtonState extends State<AnimatedCameraButton>
    with TickerProviderStateMixin {
  final _expandModel = ExpandModel();
  late final Animation<double> _opacity1;
  late final Animation<double> _opacity2;
  late final Animation<double> _width;
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

    _width = Tween<double>(
      begin: 70.0,
      end: 200.0,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    // _height = Tween<double>(begin: 70.0, end: 100.0).animate(CurvedAnimation(
    //     parent: _controller.view,
    //     curve: const Interval(
    //       0.10,
    //       0.375,
    //       curve: Curves.ease,
    //     )));

    // _widthIconStart = Tween<double>(
    //   begin: 70.0,
    //   end: 5.0,
    // ).animate(CurvedAnimation(
    //     parent: _controller.view,
    //     curve: const Interval(0.000, 0.100, curve: Curves.easeInOut)));

    _widthIconExpand = Tween<double>(
      begin: 5.0,
      end: 30.0,
    ).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    // _borderRadius = Tween<double>(begin: 60.0, end: 25.0).animate(
    //     CurvedAnimation(
    //         parent: _controller.view,
    //         curve: const Interval(0.000, 0.125, curve: Curves.easeInOut)));

    _opacity1 = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));

    _opacity2 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));
    if (widget.activeDefault) {
      _expandModel.setExpanded(true);
      _controller.forward().orCancel;
    }
    _dispStream.add(widget.onStopOutsideStream.listen((v) async {
      if (v) {
        if (_expandModel.isExpanded) {
          if (_controller.isForwardOrCompleted) {
            await _controller.reverse().orCancel;
          } else {
            await _controller.forward().orCancel;
          }
          _expandModel.setExpanded(false);
        }
      }
    }));
  }

  Future<void> _switchAnimation() async {
    try {
      if (_expandModel.isExpanded) {
        widget.onStop();
      } else {
        widget.onCapture();
      }
      if (_controller.isForwardOrCompleted) {
        await _controller.reverse().orCancel;
      } else {
        await _controller.forward().orCancel;
      }
    } on TickerCanceled {
      // The animation got canceled, probably because we were disposed.
    }
  }

  // void _doPlay() {
  //   Timer(Duration(milliseconds: 1), () {
  //     setState(() {
  //       tabInfoItems = [
  //         Container(
  //             // padding:
  //             //     const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
  //             child: Icon(Icons.photo_camera_back_rounded,
  //                 color: Constants.colorCard, size: 30)),
  //         Container(
  //             // padding:
  //             //     const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
  //             child: Icon(Icons.stop_circle,
  //                 color: Constants.colorCard, size: 30)),
  //       ];
  //       tabInfoItems = tabInfoItems
  //           .animate(interval: 500.ms)
  //           .fadeIn(duration: 500.ms, delay: 100.ms)
  //           // .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
  //           // .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);
  //           // .
  //           .move(begin: const Offset(0, -16), curve: Curves.easeOutQuad);
  //     });
  //   });
  // }

  // void _doStop() {
  //   Timer(Duration(milliseconds: 300), () {
  //     setState(() {
  //       tabInfoItems = [];
  //     });
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _dispStream.dispose();
    // _model.setRun(run: false, camera: null, mounted: false);
    // MyRep().stopCamera();
    // WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExpandModel>.value(
        value: _expandModel,
        builder: (context, child) {
          return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                    width: _width.value,
                    height: 70,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.colorButton,
                        borderRadius: BorderRadius.all(Radius.circular(90))),
                    child: Stack(alignment: Alignment.center, children: [
                      Opacity(
                          opacity: _opacity1.value,
                          child: Builder(builder: (context) {
                            var expanded = context
                                .select<ExpandModel, bool>((v) => v.isExpanded);
                            return IgnorePointer(
                                ignoring: expanded,
                                child: RoundButton(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .colorButtonBg,
                                    iconColor:
                                        Colors.red.withValues(alpha: 0.8),
                                    size: 70,
                                    useScaleAnimation: true,
                                    iconSize: 50,
                                    iconData: Icons.radio_button_on,
                                    onPressed: (v) {
                                      _switchAnimation();
                                      context
                                          .read<ExpandModel>()
                                          .setExpanded(!expanded);
                                    }));
                          })),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Opacity(
                                opacity: _opacity2.value,
                                child: Builder(builder: (context) {
                                  var expanded =
                                      context.select<ExpandModel, bool>(
                                          (v) => v.isExpanded);
                                  return IgnorePointer(
                                      ignoring: !expanded,
                                      child: ButtonRoundCorner(
                                          color: Colors.transparent,
                                          colorIcon: Theme.of(context)
                                              .colorScheme
                                              .colorCard,
                                          width: _width.value / 2,
                                          icon: Icon(
                                              Icons.photo_camera_back_rounded,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .colorCard,
                                              size: _widthIconExpand.value),
                                          radious: const BorderRadius.only(
                                              topLeft: Radius.circular(90),
                                              bottomLeft: Radius.circular(90)),
                                          onPressed: () {
                                            getIt<CameraRep>()
                                                .captureOneFrame();
                                          }));
                                })),
                            Opacity(
                                opacity: _opacity2.value,
                                child: Builder(builder: (context) {
                                  var expanded =
                                      context.select<ExpandModel, bool>(
                                          (v) => v.isExpanded);
                                  return IgnorePointer(
                                      ignoring: !expanded,
                                      child: ButtonRoundCorner(
                                          color: Colors.transparent,
                                          width: _width.value / 2,
                                          colorIcon: Theme.of(context)
                                              .colorScheme
                                              .colorCard,
                                          icon: Icon(Icons.stop_circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .colorCard,
                                              size: _widthIconExpand.value),
                                          radious: const BorderRadius.only(
                                              topRight: Radius.circular(90),
                                              bottomRight: Radius.circular(90)),
                                          onPressed: () {
                                            _switchAnimation();
                                            context
                                                .read<ExpandModel>()
                                                .setExpanded(!expanded);
                                          }));
                                }))
                          ])
                    ]));
              });
        });
  }
}
