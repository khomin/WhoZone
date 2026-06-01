import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/custom_radio_box.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/components/round_box.dart';
import 'package:flutter_demo/features/alert/presentation/pages/alert_page.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/camera_center_button.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/camera_flip_button.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/camera_frame_count.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/app/data/models/app_model.dart';
import 'package:flutter_demo/features/capture/data/models/capture_model.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/detection_painter.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/mask_painter.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/timer_button.dart';
import 'package:flutter_demo/features/home/presentation/pages/home_page.dart';
import 'package:flutter_demo/pages/settings/settings_page.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:provider/provider.dart';
import 'package:flutter_demo/core/utils/common.dart';
import 'package:flutter_demo/core/native-api/protobuf/app.pb.dart' as app;
import 'dart:math' as math;

class CapturePageProvilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => getIt<CaptureModel>(),
      child: CapturePage(),
    );
  }
}

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => CapturePageState();
}

class CapturePageState extends State<CapturePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _dispStream = DisposableStream();
  AppLifecycleListener? _listener;
  late final Animation<double> _slideHeight;
  late AnimationController _ctrSlideTop;
  final tag = 'capturePage';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      var res = await context.read<CaptureModel>().start();
      if (!res) {
        Common.showTextSnackBar(
          context: context,
          text: 'Could not get camera permissions!',
        );
      }
    });

    _listener = AppLifecycleListener(onStateChange: (value) {
      final model = context.read<CaptureModel>();
      switch (value) {
        case AppLifecycleState.hidden:
        case AppLifecycleState.detached:
        case AppLifecycleState.paused:
          model.stop();
        case AppLifecycleState.inactive:
          break;
        case AppLifecycleState.resumed:
          if (!model.started) {
            model.start();
          }
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
  }

  @override
  void dispose() {
    _listener?.dispose();
    _dispStream.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _camera(),
    );
  }

  Widget _camera() {
    return Builder(
      builder: (context) {
        final model = context.read<CaptureModel>();
        var padding = MediaQuery.paddingOf(context);
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: LayoutBuilder(builder: (context, constraints) {
                var (camera, layout, textureId, recording, size) =
                    context.select<CaptureModel,
                        (app.Camera?, SurfaceLayout, int?, bool, Size?)>(
                  (v) => (
                    v.camera,
                    v.layout,
                    v.textureId,
                    v.captureEnabled,
                    v.textureSize,
                  ),
                );
                if (camera == null) {
                  return const SizedBox();
                }
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRect(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: camera.isFront
                              ? Transform.flip(
                                  flipX: true,
                                  child: RotatedBox(
                                    quarterTurns: layout.rotation,
                                    child: Container(
                                      // width: camera.size.width.toDouble(),
                                      // height: camera.size.height.toDouble(),
                                      width: size?.width,
                                      height: size?.height,
                                      child: Texture(textureId: textureId!),
                                    ),
                                  ),
                                )
                              : RotatedBox(
                                  quarterTurns: layout.rotation,
                                  child: SizedBox(
                                    width: camera.size.width.toDouble(),
                                    height: camera.size.height.toDouble(),
                                    child: Texture(textureId: textureId!),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    //
                    // border
                    Positioned.fill(
                        child: Container(
                      width: camera.size.width.toDouble(),
                      height: camera.size.height.toDouble(),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        border: Border.all(
                          color: recording
                              ? Theme.of(context).colorScheme.colorButtonRed
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    )),
                    //
                    // overlay
                    Positioned.fill(
                      child: CameraPreviewWithOverlay(
                        boxes: model.detectionBoxesStream,
                        camWidth: size?.width ?? 0.0,
                        camHeight: size?.height ?? 0.0,
                        // camWidth: camera.size.width.toDouble(),
                        // camHeight: camera.size.height.toDouble(),
                      ),
                    ),
                  ],
                );
              }),
            ),
            //
            // duration button
            Positioned(
              top: padding.top + 30,
              left: 20,
              child: Builder(builder: (context) {
                var duration = context.select<CaptureModel, Duration>(
                  (v) => v.captureInterval,
                );
                return Row(
                  children: [
                    TimerGlassButton(
                      initialDuration: duration.inSeconds,
                      onDurationChanged: (seconds) {
                        var model = context.read<CaptureModel>();
                        model.captureInterval = Duration(seconds: seconds);
                        model.notify();
                      },
                    ),
                  ],
                );
              }),
            ),
            //
            // time elapsed
            Positioned(
              top: padding.top + 30,
              right: 20,
              child: Center(
                child: RepaintBoundary(
                  child: SizedBox(
                    width: 80,
                    height: 34,
                    child: Stack(children: [
                      Builder(builder: (context) {
                        var duration = context.select<CaptureModel, Duration?>(
                            (v) => v.captureTimeElapsed);
                        if (duration == null) return const SizedBox();
                        return RoundBox(
                          text: duration.format(),
                          useRightMargin: false,
                          color: Theme.of(context).colorScheme.colorButtonRed,
                          borderRadius: 40,
                        );
                      })
                    ]),
                  ),
                ),
              ),
            ),
            //
            // bottom panel
            Positioned(
              bottom: padding.bottom + 40,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      width: 75,
                      child: CameraFrameCount(
                        onPressed: () {
                          //
                        },
                      ),
                    ),
                    // 2
                    CameraCenterButton(
                      captureEnabled: model.captureEnabled,
                      onMakeOneShot: () {
                        model.makeOneShot();
                      },
                    ),
                    // 3
                    Container(
                      padding: EdgeInsets.only(right: 10),
                      width: 75,
                      child: CameraFlipButton(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _debugLabels() {
    return Builder(builder: (context) {
      var camera = context.select<CaptureModel, app.Camera?>((v) => v.camera);
      var cameraSensor = camera?.sensor ?? 0;
      final sensorRadians = (cameraSensor * math.pi / 180.0);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('camera.sensor: ${camera?.sensor}'),
        Text('sensorRadians: $sensorRadians'),
      ]);
    });
  }
}

// TODO: make letter boxes like: car: 0.79 and in a box itself
// TODO: box boundaries don't match frame
// TODO: rotate frame in cpp
// TODO: crash in cpp
// TODO: beatiful flip?

// TODO: use FutureBuilder for "no records"

// signal 6 (SIGABRT), code -1 (SI_QUEUE), fault addr --------
// Abort message: 'terminating due to uncaught exception of type cv::Exception: OpenCV(4.10.0) /Users/panic/Documents/PROJECTS/WhoZone/scripts/.opencv/modules/core/src/matrix_expressions.cpp:32: error: (-5:Bad argument) One or more matrix operands are empty. in function 'checkOperandsExist''

// CaptureSettingsPage(),
