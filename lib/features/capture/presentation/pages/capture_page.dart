import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/round_box.dart';
import 'package:flutter_demo/features/capture/domain/entities/surface_layout.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/camera_center_button.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/camera_flip_button.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/camera_frame_count.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/capture/data/models/capture_model.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/detection_painter.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/timer_button.dart';
import 'package:flutter_demo/core/repository/app_theme.dart';
import 'package:flutter_demo/core/repository/constants.dart';
import 'package:flutter_demo/components/disposable_stream.dart';
import 'package:provider/provider.dart';
import 'package:flutter_demo/core/utils/common.dart';
import 'package:flutter_demo/core/native-api/protobuf/app.pb.dart' as app;
import 'dart:math' as math;
import 'package:sensor_device_orientation/sensor_device_orientation.dart';

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
  late AppLifecycleListener _listener;
  final tag = 'capturePage';

  @override
  void initState() {
    super.initState();

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
          if (!model.cameraStarted) {
            model.start();
          }
          break;
      }
    });

    Future.microtask(() async {
      var res = await context.read<CaptureModel>().start();
      if (!res) {
        Common.showTextSnackBar(
          context: context,
          text: 'Could not get camera permissions!',
        );
      }
    });
  }

  @override
  void dispose() {
    _listener.dispose();
    _dispStream.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<CaptureModel>();
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Builder(builder: (context) {
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
                        boxes: model.boxesStream,
                        camWidth: size?.width ?? 0.0,
                        camHeight: size?.height ?? 0.0,
                      ),
                    ),
                  ],
                );
              }),
            ),
            //
            // debug information
            if (kDebugMode) Positioned(top: 0, right: 0, child: _debugLabels()),
            //
            // duration button
            Positioned(
              top: padding.top + 30,
              left: 20,
              child: Builder(
                builder: (context) {
                  var duration = context.select<CaptureModel, Duration>(
                    (v) => v.captureInterval,
                  );
                  return SensorRotatedBox(
                    animate: true,
                    child: Row(
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
                    ),
                  );
                },
              ),
            ),
            //
            // time elapsed
            Positioned(
              top: padding.top + 30,
              right: 20,
              child: SensorRotatedBox(
                animate: true,
                duration: Constants.duration,
                child: Center(
                  child: RepaintBoundary(
                    child: SizedBox(
                      width: 80,
                      height: 34,
                      child: Stack(children: [
                        Builder(builder: (context) {
                          var duration =
                              context.select<CaptureModel, Duration?>(
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
                        onPressed: () {},
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
        ));
  }

  Widget _debugLabels() {
    return SafeArea(
      child: Builder(
        builder: (context) {
          var camera =
              context.select<CaptureModel, app.Camera?>((v) => v.camera);
          var cameraSensor = camera?.sensor ?? 0;
          final sensorRadians = (cameraSensor * math.pi / 180.0);
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('camera.sensor: ${camera?.sensor}'),
                Text('sensorRadians: $sensorRadians'),
              ]);
        },
      ),
    );
  }
}
