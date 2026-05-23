import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/components/round_box.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/camera_center_button.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/camera_flip_button.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/camera_frame_count.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/features/capture/data/models/capture_model.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/detection_painter.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:provider/provider.dart';
import 'package:flutter_demo/core/utils/common.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart' as app;
import 'dart:math' as math;

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => CapturePageState();
}

class CapturePageState extends State<CapturePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _dispStream = DisposableStream();
  late final CaptureModel _captureModel;
  AppLifecycleListener? _listener;
  late final Animation<double> _slideHeight;
  late AnimationController _ctrSlideTop;
  final tag = 'capturePage';

  @override
  void initState() {
    super.initState();

    _captureModel = CaptureModel(
      captureInterval: getIt<SettingsRep>().getCaptureIntervalSec(),
      cameraRep: getIt<CameraRep>(),
      settingsRep: getIt<SettingsRep>(),
    );

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
        case AppLifecycleState.hidden:
        case AppLifecycleState.detached:
        case AppLifecycleState.paused:
          _captureModel.stop();
        case AppLifecycleState.inactive:
          break;
        case AppLifecycleState.resumed:
          if (!_captureModel.started) {
            _captureModel.start();
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
    _captureModel.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
              SliverFillRemaining(
                child: _camera(),
              )
            ]));
  }

  Widget _sliverAppBar() {
    return Stack(children: [
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
              color: Theme.of(context).colorScheme.colorBar,
              height: kToolbarHeight,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text('Capture',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .colorScheme
                                    .homeCardH1Style))),
                    //
                    // duration
                    RepaintBoundary(
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
                            ]))),
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

  Widget _camera() {
    // TODO: clean architecture
    // TODO: tensorflow
    // TODO: doc
    // TODO: publish
    return Stack(alignment: Alignment.center, children: [
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        top: 0,
        child: LayoutBuilder(builder: (context, constraints) {
          var (camera, layout, textureId, recording) = context
              .select<CaptureModel, (app.Camera?, SurfaceLayout, int?, bool)>(
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
              if (kDebugMode)
                Positioned(
                  child: _debugLabels(),
                ),
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
                      width: 2),
                ),
              )),
              //
              // overlay
              Positioned.fill(
                child: CameraPreviewWithOverlay(
                  boxes: _captureModel.detectionBoxesStream,
                ),
              ),
              //
              // frame-shots count
              CameraFrameCount()
            ],
          );
        }),
      ),
      //
      // camera button
      CameraCenterButton(
        captureEnabled: _captureModel.captureEnabled,
        onMakeOneShot: () {
          _captureModel.makeOneShot();
        },
      ),
      //
      // flip camera button
      CameraFlipButton(),
    ]);
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
