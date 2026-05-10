import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/button_round_corner.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/pages/capture/capture_model.dart';
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
                                child: _recordButton(
                                  () {
                                    _switchAnimation();
                                    context
                                        .read<ExpandModel>()
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
                                      context.select<ExpandModel, bool>(
                                          (v) => v.isExpanded);
                                  return IgnorePointer(
                                      ignoring: !expanded,
                                      child: ButtonRoundCorner(
                                          color: Colors.transparent,
                                          width: _width.value / 2,
                                          icon: Icon(
                                            Icons.camera_sharp,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .cameraButtonIcon,
                                            size: _widthIconExpand.value,
                                          ),
                                          radious: const BorderRadius.only(
                                              topLeft: Radius.circular(90),
                                              bottomLeft: Radius.circular(90)),
                                          onPressed: () {
                                            getIt<CameraRep>()
                                                .detectionEvent(force: true);
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
                                          icon: Icon(
                                            Icons.stop_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .cameraButtonIcon,
                                            size: _widthIconExpand.value,
                                          ),
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
