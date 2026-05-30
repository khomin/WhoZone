import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
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
import 'package:flutter_demo/features/capture/presentation/widgets/glass_button.dart';
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
      backgroundColor: Theme.of(context).colorScheme.colorBar,
      body: _camera(),
    );
  }

  // Widget _sliverAppBar() {
  //   return Stack(children: [
  //     Positioned(
  //         top: 0,
  //         left: 0,
  //         right: 0,
  //         child: Container(
  //             color: Theme.of(context).colorScheme.colorBar,
  //             height: kToolbarHeight,
  //             child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Flexible(
  //                       child: Padding(
  //                           padding: EdgeInsets.only(left: 25),
  //                           child: Text('Capture',
  //                               maxLines: 1,
  //                               overflow: TextOverflow.ellipsis,
  //                               style: Theme.of(context)
  //                                   .colorScheme
  //                                   .homeCardH1Style))),
  //                   //
  //                   // duration
  //                   RepaintBoundary(
  //                       child: SizedBox(
  //                           width: 110,
  //                           height: 30,
  //                           child: Stack(children: [
  //                             Builder(builder: (context) {
  //                               var duration =
  //                                   context.select<CaptureModel, Duration?>(
  //                                       (v) => v.captureTimeElapsed);
  //                               if (duration == null) return const SizedBox();
  //                               return RoundBox(
  //                                 text: duration.format(),
  //                                 useRightMargin: false,
  //                                 color: Theme.of(context)
  //                                     .colorScheme
  //                                     .colorButtonRed,
  //                                 borderRadius: 40,
  //                               );
  //                             })
  //                           ]))),
  //                   RoundButton(
  //                       color: Colors.transparent,
  //                       iconColor: Theme.of(context)
  //                           .colorScheme
  //                           .colorTextAccent
  //                           .withValues(alpha: 0.8),
  //                       size: 70,
  //                       vertTransform: true,
  //                       iconData: Icons.arrow_back_ios_new,
  //                       onPressed: (p0) {
  //                         var model = context.read<AppModel>();
  //                         model.setCollapse(!model.collapse);
  //                       })
  //                 ])))
  //   ]);
  // }

  var _initialButton = 0;

  Widget _camera() {
    return Builder(
      builder: (context) {
        final model = context.read<CaptureModel>();
        var padding = MediaQuery.paddingOf(context);
        var size = MediaQuery.sizeOf(context);
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: 0,
              child: LayoutBuilder(builder: (context, constraints) {
                var (camera, layout, textureId, recording) = context.select<
                    CaptureModel, (app.Camera?, SurfaceLayout, int?, bool)>(
                  (v) => (v.camera, v.layout, v.textureId, v.captureEnabled),
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
                                        width: camera.size.width.toDouble(),
                                        height: camera.size.height.toDouble(),
                                        child: Texture(textureId: textureId!),
                                      )))
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
                    // Positioned.fill(
                    //     child: CustomPaint(
                    //   painter: MaskPainter(),
                    //   size: Size.infinite,
                    // )),
                    // if (kDebugMode)
                    //   Positioned(
                    //     child: _debugLabels(),
                    //   ),
                    //
                    // border
                    Positioned.fill(
                        child: Container(
                      width: camera.size.width.toDouble(),
                      height: camera.size.height.toDouble(),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
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
                      ),
                    ),
                  ],
                );
              }),
            ),

            //
            // duration
            Positioned(
                top: kToolbarHeight + padding.top + 10,
                // bottom: 5,
                left: 0,
                right: 0,
                child: Stack(children: [
                  SizedBox(
                      width: 110,
                      height: 30,
                      child: RepaintBoundary(
                          child: SizedBox(
                              width: 110,
                              height: 30,
                              child: Stack(children: [
                                Builder(builder: (context) {
                                  var duration =
                                      context.select<CaptureModel, Duration?>(
                                          (v) => v.captureTimeElapsed);
                                  if (duration == null) return const SizedBox();
                                  return RoundBox(
                                    text: duration.format(),
                                    useRightMargin: false,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .colorButtonRed,
                                    borderRadius: 40,
                                  );
                                })
                              ]))))
                ])),

            // //
            // // top panel
            // Positioned(
            //   top: padding.top + 20,
            //   right: 20,
            //   child: Container(
            //     width: 40,
            //     height: 40,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.all(
            //         Radius.circular(20),
            //       ),
            //     ),
            //     child: Stack(alignment: Alignment.center, children: [
            //       ClipRRect(
            //         borderRadius: const BorderRadius.all(Radius.circular(20)),
            //         child: BackdropFilter(
            //           filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            //           child: Container(
            //             color: Theme.of(context).colorScheme.colorButton,
            //             height: kToolbarHeight,
            //           ),
            //         ),
            //       ),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(CupertinoIcons.gear, size: 18),
            //         ],
            //       )
            //     ]),
            //   ),
            // ),

            // //
            // // top panel
            // Positioned(
            //   top: padding.top + 20,
            //   right: 20,
            //   child: Container(
            //     child: Stack(
            //       alignment: Alignment.center,
            //       children: [
            //         Positioned.fill(
            //           child: ClipRRect(
            //             borderRadius: BorderRadiusGeometry.all(
            //               Radius.circular(30),
            //             ),
            //             child: BackdropFilter(
            //               filter: ImageFilter.blur(
            //                 sigmaX: 5.0,
            //                 sigmaY: 5.0,
            //               ),
            //               child: Container(
            //                 color: Theme.of(context).colorScheme.colorButton,
            //                 height: kToolbarHeight,
            //               ),
            //             ),
            //           ),
            //         ),
            //         Padding(
            //           padding: EdgeInsets.only(
            //             left: 10,
            //             right: 10,
            //             bottom: 8,
            //             top: 8,
            //           ),
            //           child: Row(
            //             children: [
            //               Icon(
            //                 CupertinoIcons.timer,
            //                 size: 18,
            //               ),
            //               const SizedBox(width: 5),
            //               Text('1 sec'),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // GlassTimerButton(),
            Positioned(
              top: padding.top + 40,
              // left: 0,
              right: 20,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TimerGlassButton(
                    initialDuration: _initialButton,
                    onDurationChanged: (seconds) {
                      setState(() {
                        _initialButton = seconds;
                      });
                    },
                  ),
                ],
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 1
                      CameraFrameCount(
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            settings: const RouteSettings(),
                            builder: (context) {
                              return HomePagePage();
                            },
                          ));
                        },
                      ),
                      // 2
                      CameraCenterButton(
                        captureEnabled: model.captureEnabled,
                        onMakeOneShot: () {
                          model.makeOneShot();
                        },
                      ),
                      // 3
                      CameraFlipButton(),
                    ]),
              ),
            ),
            //
            // safe area gause
            if (Constants.useBottomBlur)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: 100,
                  height: padding.bottom,
                  child: Stack(alignment: Alignment.center, children: [
                    Positioned.fill(
                        child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          color: Theme.of(context).colorScheme.colorButton,
                        ),
                      ),
                    )),
                  ]),
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

// TODO: restore old home layout with camera as an overlay widget
// TODO: box boundaries don't match frame
// TODO: crash in cpp
// signal 6 (SIGABRT), code -1 (SI_QUEUE), fault addr --------
// Abort message: 'terminating due to uncaught exception of type cv::Exception: OpenCV(4.10.0) /Users/panic/Documents/PROJECTS/WhoZone/scripts/.opencv/modules/core/src/matrix_expressions.cpp:32: error: (-5:Bad argument) One or more matrix operands are empty. in function 'checkOperandsExist''

// CaptureSettingsPage(),
