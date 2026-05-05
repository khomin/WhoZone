import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/animated_camera_button.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/components/round_box.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/pages/capture/capture_model.dart';
import 'package:flutter_demo/pages/capture/detection_painter.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart' as app;
import 'package:flutter_demo/main.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => CapturePageState();
}

class CapturePageState extends State<CapturePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _dispStream = DisposableStream();
  late CaptureModel _captureModel;
  final _onStopRecordStream = PublishSubject<bool>();
  Timer? _updateLayoutTm;
  AppLifecycleListener? _listener;
  late final Animation<double> _slideHeight;
  late AnimationController _ctrSlideTop;
  late final Animation<double> _slideOpacity;

  final tag = 'capturePage';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      var res = await _captureModel.start();
      if (!res) {
        Common.showTextSnackBar(
          context: context,
          text: 'Could not get camera permissions!',
        );
      }
    });

    _listener = AppLifecycleListener(onStateChange: (value) {
      switch (value) {
        case AppLifecycleState.inactive:
        case AppLifecycleState.hidden:
        case AppLifecycleState.detached:
        case AppLifecycleState.paused:
          _captureModel.stop();
          break;
        case AppLifecycleState.resumed:
          _captureModel.start();
          break;
      }
    });
    _ctrSlideTop = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideHeight = Tween<double>(
      begin: kToolbarHeight,
      end: kToolbarHeight * 3,
    ).animate(CurvedAnimation(
        parent: _ctrSlideTop.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));
    _slideOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _ctrSlideTop.view,
        curve: const Interval(0.000, 0.50, curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    _listener?.dispose();
    _dispStream.dispose();
    _onStopRecordStream.close();
    _captureModel.stop(shouldNotify: false);
    getIt<CameraRep>().onCapture = null;
    getIt<CameraRep>().onFirstFrame = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _captureModel = context.read<CaptureModel>();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _updateLayoutTm?.cancel();
    _updateLayoutTm = Timer(const Duration(milliseconds: 300), () async {
      _captureModel.updateRotation();
    });
  }

  void _handleOnSlide() {
    if (_ctrSlideTop.isForwardOrCompleted) {
      _ctrSlideTop.reverse().orCancel;
    } else {
      _ctrSlideTop.forward().orCancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.colorBar,
        body: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              AnimatedBuilder(
                  animation: _ctrSlideTop,
                  builder: (context, child) {
                    return SliverAppBar(
                      backgroundColor: Theme.of(context).colorScheme.colorBar,
                      toolbarHeight: _slideHeight.value,
                      automaticallyImplyLeading: false,
                      flexibleSpace: _sliverAppBar(),
                    );
                  }),
              SliverFillRemaining(child: _camera())
            ]));
  }

  Widget _sliverAppBar() {
    return Stack(children: [
      Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
              opacity: _slideOpacity.value,
              child: SizedBox(
                  height: _slideHeight.value / 1.5,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundButton(
                            color: Theme.of(context)
                                .colorScheme
                                .colorButtonRed
                                .withValues(alpha: 0.8),
                            iconColor: Theme.of(context)
                                .colorScheme
                                .colorCard
                                .withValues(alpha: 0.8),
                            size: 55,
                            radius: 20,
                            useScaleAnimation: true,
                            iconData: Icons.stop_circle_sharp,
                            onPressed: (v) async {
                              _handleOnSlide();
                              await getIt<CameraRep>().setCaptureActive(false);
                              _onStopRecordStream.add(true);
                            }),
                        const SizedBox(width: 15),
                        RoundButton(
                            color: Theme.of(context)
                                .colorScheme
                                .colorSecondary
                                .withValues(alpha: 0.8),
                            iconColor: Theme.of(context)
                                .colorScheme
                                .colorCard
                                .withValues(alpha: 0.8),
                            size: 55,
                            radius: 20,
                            useScaleAnimation: true,
                            iconData: Icons.close,
                            onPressed: (v) {
                              _handleOnSlide();
                            })
                      ])))),
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
              color: Theme.of(context).colorScheme.colorBar,
              height: kToolbarHeight,
              child: Row(children: [
                Container(
                  width: 100,
                  margin: const EdgeInsets.only(left: 25),
                  child: Text('Capture',
                      style: Theme.of(context).colorScheme.homeCardH1Style),
                ),
                const Spacer(),
                RoundButton(
                    color: Colors.transparent,
                    iconColor: Theme.of(context)
                        .colorScheme
                        .colorTextAccent
                        .withValues(alpha: 0.8),
                    size: 70,
                    vertTransform: true,
                    iconData: Icons.arrow_back_ios_new,
                    onPressed: (p0) {
                      var model = context.read<AppModel>();
                      model.setCollapse(!model.collapse);
                    })
              ])))
    ]);
  }

  // var collapse = context.select<AppModel, bool>((v) => v.collapse);
  Widget _camera() {
    return Builder(builder: (context) {
      var camera = context.select<CaptureModel, app.Camera?>((v) => v.camera);
      var layout = context.select<CaptureModel, SurfaceLayout>((v) => v.layout);
      var targetSize = getIt<CameraRep>().targetSize;
      var textureId = context.select<CaptureModel, int?>((v) => v.textureId);
      logDebug(
          'BTEST: width=${camera?.size.width}, height=${camera?.size.height}, rotation-surface=${layout.rotation}, ratio=${layout.ratio}');
      if (camera == null || targetSize == null) {
        return const SizedBox();
      }
      var sensorWidth = camera.size.width.toDouble();
      var sensorHeight = camera.size.height.toDouble();
      return Center(
        child: AspectRatio(
          // aspectRatio: 480 / 640, // 3:4 The AI World (Portrait)
          aspectRatio: targetSize.height / targetSize.width,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: RotatedBox(
                      quarterTurns: layout.rotation,
                      child: SizedBox(
                        width: sensorWidth,
                        height: sensorHeight,
                        child: Texture(textureId: textureId!),
                      ),
                    ),
                  ),
                ),
              ),
              // overlay
              Positioned.fill(
                child: CameraPreviewWithOverlay(
                  boxes: getIt<CameraRep>().onDetection.stream,
                ),
              ),
            ],
          ),
        ),
      );
      // return Center(
      //   child: AspectRatio(
      //     aspectRatio: 480 / 640,
      //     child: Stack(
      //       children: [
      //         Positioned.fill(
      //           child: RotatedBox(
      //             quarterTurns: 3,
      //             child: FittedBox(
      //               fit: BoxFit.cover,
      //               child: SizedBox(
      //                 width: 1,
      //                 height: 1,
      //                 child: Texture(textureId: textureId!),
      //               ),
      //             ),
      //           ),
      //         ),
      //         Positioned.fill(
      //           child: CameraPreviewWithOverlay(
      //             boxes: getIt<CameraRep>().onDetection.stream,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // );
      // return ClipRRect(
      //     borderRadius: BorderRadius.circular(20.0),
      //     child: RotatedBox(
      //         quarterTurns: layout.rotation,
      //         child: FittedBox(
      //             // fit: BoxFit.cover,
      //             fit: BoxFit.contain,
      //             child: SizedBox(
      //                 width: cameraSize.height.toDouble(),
      //                 height: cameraSize.width.toDouble(),
      //                 child: Stack(
      //                     alignment: AlignmentGeometry.center,
      //                     children: [
      //                       //
      //                       // texture
      //                       textureId != null
      //                           ? Texture(
      //                               textureId: textureId,
      //                             )
      //                           : const SizedBox(),
      //                     ])))));
      // })
      // ]));
      // })),
      //
      // overlay
      // Positioned.fill(
      //     child: CameraPreviewWithOverlay(
      //         boxes: _captureModel.onDetection.stream)),
      // //
      // //
      // // progress
      // Positioned.fill(
      //     child: Stack(alignment: Alignment.center, children: [
      //   RepaintBoundary(child: Builder(builder: (context) {
      //     var wait = context
      //         .select<CaptureModel, bool>((v) => v.orientationpWait);
      //     if (wait) {
      //       return const SizedBox(
      //           width: 60,
      //           height: 60,
      //           child: CircularProgressIndicator());
      //     }
      //     return const SizedBox();
      //   }))
      // ])),
      // // buttons
      // Positioned(left: 0, bottom: 0, right: 0, child: _buttons())
      // ]));
    });
  }

  Widget _buttons() {
    return RepaintBoundary(
        child: Container(
            height: 130,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.colorButtonBg),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //
                  // last captured frame
                  // _lastCaptured(),
                  //
                  // center
                  AnimatedCameraButton(
                      activeDefault: getIt<CameraRep>().captureActive,
                      onStopOutsideStream: _onStopRecordStream,
                      onCapture: () async {
                        await getIt<CameraRep>().setCaptureActive(true);
                      },
                      onStop: () async {
                        await getIt<CameraRep>().setCaptureActive(false);
                      }),
                  //
                  // right
                  RepaintBoundary(child: Builder(builder: (context) {
                    var camera = context
                        .select<CaptureModel, app.Camera?>((v) => v.camera);
                    return AnimatedRotation(
                        turns: camera?.isFront == Constants.isDefaultFront
                            ? 0
                            : 0.5,
                        duration: Constants.duration * 2,
                        child: RoundButton(
                            color: Theme.of(context).colorScheme.colorButton,
                            iconColor: Theme.of(context)
                                .colorScheme
                                .colorCard
                                .withValues(alpha: 0.8),
                            size: 55,
                            useScaleAnimation: true,
                            iconData: Icons.flip_camera_android,
                            onPressed: (v) async {
                              // if (_model.flipWait) return;
                              // _model.setFlipWait(true);
                              // _start(flip: true);
                              _captureModel.start();
                            }));
                  }))
                ])));
  }

  // Widget _lastCaptured() {
  //   return Builder(builder: (context) {
  //     var item = _captured;
  //     return AnimatedOpacity(
  //         opacity: _hasLastCapture ? 1 : 0,
  //         duration: Constants.lastFrameDuration,
  //         child: Container(
  //             width: 55,
  //             height: 55,
  //             decoration: BoxDecoration(
  //                 color: Theme.of(context).colorScheme.colorButton,
  //                 borderRadius: BorderRadius.all(Radius.circular(30))),
  //             child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(30.0),
  //                 child: Stack(alignment: Alignment.center, children: [
  //                   AnimatedPositioned(
  //                       duration: Constants.lastFrameDuration,
  //                       left: _onLeftToGone ? -55 : (_onRightToLeft ? 0 : 55),
  //                       bottom: 0,
  //                       top: 0,
  //                       child: SizedBox(
  //                           width: 55,
  //                           height: 55,
  //                           child: item ?? const SizedBox())),
  //                   // const Center(
  //                   //     child: Text('2', style: TextStyle(color: Colors.white)))
  //                 ]))));
  //   });
  // }
}
