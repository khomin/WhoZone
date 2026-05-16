import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/animated_camera_button.dart';
import 'package:flutter_demo/components/round_button.dart';
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
                              StreamBuilder(
                                  stream: getIt<CameraRep>().onCaptureTime,
                                  initialData: getIt<CameraRep>()
                                      .onCaptureTime
                                      .valueOrNull,
                                  builder: (context, snapshot) {
                                    var duration = snapshot.data;
                                    if (duration == null)
                                      return const SizedBox();
                                    return RoundBox(
                                        text: duration.duration.format(),
                                        useRightMargin: false,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .colorButtonRed,
                                        borderRadius: 40);
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
    // TODO: publish
    // TODO: tensorflow
    // TODO: doc
    return Stack(alignment: Alignment.center, children: [
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        top: 0,
        child: LayoutBuilder(builder: (context, constraints) {
          var targetSize = getIt<CameraRep>().targetSize;
          var (camera, layout, textureId, recording) = context
              .select<CaptureModel, (app.Camera?, SurfaceLayout, int?, bool)>(
            (v) => (v.camera, v.layout, v.textureId, v.recording),
          );
          logDebug(
              'BTEST: width=${camera?.size.width}, height=${camera?.size.height}, rotation-surface=${layout.rotation}, ratio=${layout.ratio}');
          if (camera == null || targetSize == null) {
            return const SizedBox();
          }
          Future.microtask(() async {
            _captureModel.updateRotation();
          });
          var sensorWidth = camera.size.width.toDouble();
          var sensorHeight = camera.size.height.toDouble();
          return AspectRatio(
            aspectRatio: targetSize.height / targetSize.width,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: RotatedBox(
                        quarterTurns: layout.rotation,
                        child: Container(
                          width: sensorWidth,
                          height: sensorHeight,
                          child: Texture(textureId: textureId!),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                    child: Container(
                  width: sensorWidth,
                  height: sensorHeight,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                        color: recording
                            ? Theme.of(context).colorScheme.colorButtonRed
                            : Colors.transparent,
                        width: 2),
                  ),
                )),
                // overlay
                Positioned.fill(
                  child: CameraPreviewWithOverlay(
                    boxes: getIt<CameraRep>().onDetection.stream,
                  ),
                ),
                //
                // frame-shots count
                _frameCount()
              ],
            ),
          );
        }),
      ),
      _buttonCenterButton(),
      _buttonFlip(),
    ]);
  }

  Widget _buttonCenterButton() {
    return Positioned(
        left: 0,
        bottom: 0,
        right: 0,
        child: RepaintBoundary(
            child: SizedBox(
                height: 130,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedCameraButton(
                          activeDefault: getIt<CameraRep>().captureEnable,
                          onStopOutsideStream: _onStopRecordStream,
                          onCapture: () async {
                            _captureModel.startCapture();
                          },
                          onStop: () async {
                            _captureModel.stopCapture();
                          }),
                    ]))));
  }

  Widget _buttonFlip() {
    return Positioned(
        right: 30,
        top: 30,
        child: SizedBox(
            height: 60,
            width: 60,
            child: RepaintBoundary(child: Builder(builder: (context) {
              var camera =
                  context.select<CaptureModel, app.Camera?>((v) => v.camera);
              return AnimatedRotation(
                  turns: camera?.isFront == Constants.isDefaultFront ? 0 : 0.5,
                  duration: Constants.duration * 2,
                  child: RoundButton(
                      color: Theme.of(context).colorScheme.colorButton,
                      iconColor: Theme.of(context).colorScheme.cameraButtonIcon,
                      size: 55,
                      radius: 90,
                      useScaleAnimation: true,
                      iconData: Icons.flip_camera_android,
                      onPressed: (v) async {
                        if (_captureModel.flipWait) return;
                        _captureModel.setFlipWait(true);
                        _captureModel.start(flip: true);
                        _captureModel.setFlipWait(false);
                      }));
            }))));
  }

  Widget _frameCount() {
    final color = Theme.of(context).colorScheme.cameraButtonIcon;
    return Positioned(
      bottom: 10,
      left: 10,
      child: RepaintBoundary(
          child: SizedBox(
              width: 80,
              height: 30,
              child: StreamBuilder(
                  stream: getIt<CameraRep>().onDetectionCount.stream,
                  builder: (context, snapshot) {
                    var count = snapshot.data ?? 0;
                    if (count == 0) return const SizedBox();
                    return Row(children: [
                      Icon(Icons.camera, color: color),
                      Flexible(
                          child: Text(
                        count.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 17, color: color),
                      ))
                    ]);
                  }))),
    );
  }
}
