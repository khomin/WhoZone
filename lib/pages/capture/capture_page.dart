import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/components/animated_camera_button.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/components/round_box.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/pages/home/record_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:loggy/loggy.dart';
import 'package:provider/provider.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:rxdart/rxdart.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => CapturePageState();
}

class CapturePageState extends State<CapturePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _dispStream = DisposableStream();
  late RecordModel _model;
  AppLifecycleListener? _listener;
  late final Animation<double> _slideHeight;
  late final Animation<double> _slideOpacity;
  late AnimationController _ctrSlideTop;
  final _onStopRecordStream = PublishSubject<bool>();
  Widget? _captured;
  bool _hasLastCapture = false;
  bool _onRightToLeft = false;
  bool _onLeftToGone = false;
  final tag = 'capturePage';

  @override
  void initState() {
    super.initState();

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

    CameraRep().onCapture = (path) {
      _updateLastFrame(path: path);
    };
    CameraRep().onFirstFrame = () async {
      logDebug('BTEST_onFirstFrame');
      await Future.delayed(const Duration(milliseconds: 100));
      _model.setImgBlur(null);
      _model.setFlipWait(false);
    };
  }

  @override
  void dispose() {
    super.dispose();
    _listener?.dispose();
    _dispStream.dispose();
    _onStopRecordStream.close();
    _model.setRun(run: false, camera: null, mounted: false);
    // if (!MyRep().captureActive) {
    () async {
      CameraRep().setCaptureActive(false);
      CameraRep().stopCamera();
      // }
      CameraRep().onCapture = null;
      CameraRep().onFirstFrame = null;
    }();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _start({required bool flip}) async {
    Camera? camera;
    if (flip) {
      camera = _cameraToFlit();
      var path = await CameraRep().captureOneFrame(serviceFrame: true);
      _model.setBlurLayout(_model.layout);
      _model.setImgBlur(path);
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      var cameras = CameraRep().cameraMap;
      var front = cameras['front'];
      var back = cameras['back'];
      // start with last used or default camera
      var cameraId = await SettingsRep().getCameraUsed();
      if (front?.id == cameraId) {
        camera = front;
      } else if (back?.id == cameraId) {
        camera = back;
      } else {
        if (Constants.defaultCamera == front?.facing) {
          camera = front;
        } else if (back != null) {
          camera = back;
        }
      }
    }
    if (camera == null) return;
    _model.setRun(run: true, camera: camera);

    await CameraRep().stopCamera();
    await CameraRep().startCamera(
        id: camera.id,
        captureIntervalSec: await SettingsRep().getCaptureIntervalSec(),
        minArea: await SettingsRep().getCaptureMinArea(),
        showAreaOnCapture: await SettingsRep().getCaptureShowArea());

    _model.updateRotation();
    SettingsRep().setCameraUsed(camera.id);
  }

  Camera? _cameraToFlit() {
    var camera = CameraRep().cameraMap;
    var front = camera['front'];
    var back = camera['back'];
    var cur = _model.camera;
    if (front == cur) {
      return back;
    }
    return front;
  }

  void _updateLastFrame({required String path}) async {
    if (_captured == null) {
      setState(() {
        if (path.isNotEmpty) {
          _captured = ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Stack(alignment: Alignment.center, children: [
                Image.memory(File(path).readAsBytesSync(),
                    cacheHeight: 100, cacheWidth: 100, fit: BoxFit.fill)
              ]));
        } else {
          _captured = ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child:
                  Stack(alignment: Alignment.center, children: [Container()]));
        }
        _onRightToLeft = true;
        _hasLastCapture = true;
      });
    } else {
      setState(() {
        _onLeftToGone = true;
        _hasLastCapture = true;
      });
      Timer(Constants.lastFrameDuration, () {
        setState(() {
          _onLeftToGone = false;
          _captured = null;
          _onRightToLeft = false;
        });
        Timer(Constants.lastFrameDuration, () {
          setState(() {
            if (path.isNotEmpty) {
              _captured = ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Stack(alignment: Alignment.center, children: [
                    Image.memory(File(path).readAsBytesSync(),
                        cacheHeight: 100,
                        cacheWidth: 100,
                        fit: BoxFit.fitHeight)
                  ]));
            } else {
              _captured = ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Stack(
                      alignment: Alignment.center, children: [Container()]));
            }
            _onRightToLeft = true;
          });
        });
      });
    }
  }

  void _handleOnSlide() {
    if (CameraRep().onCaptureTime.valueOrNull == null) return;
    if (_ctrSlideTop.isForwardOrCompleted) {
      _ctrSlideTop.reverse().orCancel;
    } else {
      _ctrSlideTop.forward().orCancel;
    }
  }

  Timer? _updateLayoutTm;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Here you can detect orientation change
    // final orientation = MediaQuery.of(context).orientation;
    var view = View.of(context).platformDispatcher.views.first;
    var size = view.physicalSize / view.devicePixelRatio;
    // print("BTEST_Current size: $size");
    logDebug('BTEST: didChange');
    // _model.setOrientationWait(true);
    _updateLayoutTm?.cancel();
    _updateLayoutTm = Timer(const Duration(milliseconds: 300), () async {
      // await _updateRotation();
      _model.updateRotation();
      // Timer(const Duration(milliseconds: 100), () {
      //   _model.setOrientationWait(false);
      // });
    });
  }

  void _onPlatformViewCreated(int id) async {
    // init first
    await CameraRep().initRender();

    _listener = AppLifecycleListener(onStateChange: (value) {
      // logDebug('BTEST_STATE=$value');
      switch (value) {
        case AppLifecycleState.inactive:
        case AppLifecycleState.hidden:
        case AppLifecycleState.detached:
        case AppLifecycleState.paused:
          _model.setRun(run: false, camera: null);
          CameraRep().stopCamera();
          break;
        case AppLifecycleState.resumed:
          _start(flip: false);
          break;
      }
    });

    _model.devRotation = await CameraRep().getDeviceSensor();
    // _model.setOrientationWait(true);
    await CameraRep().getCameras();
    await CameraRep().registerView();
    await _start(flip: false);
    // await _updateRotation();
    // _model.setOrientationWait(false);
  }

  @override
  Widget build(BuildContext context) {
    _model = context.read<RecordModel>();
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
                        flexibleSpace: _sliverAppBar());
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
                              await CameraRep().setCaptureActive(false);
                              _onStopRecordStream.add(true);
                              // MyRep().stopCamera();
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
                    child:
                        const Text('Capture', style: TextStyle(fontSize: 25))),
                HoverClick(
                    onPressedL: (p0) async {
                      _handleOnSlide();
                    },
                    child: SizedBox(
                        width: 130,
                        height: 50,
                        child: RepaintBoundary(
                            child:
                                Stack(alignment: Alignment.center, children: [
                          StreamBuilder(
                              stream: CameraRep().onCaptureTime,
                              initialData:
                                  CameraRep().onCaptureTime.valueOrNull,
                              builder: (context, snapshot) {
                                var duration = snapshot.data;
                                return AnimatedContainer(
                                    duration: Duration.zero,
                                    width: duration == null ? 10 : 130,
                                    height: duration == null ? 10 : 30,
                                    child: RoundBox(
                                        text: duration?.duration.format() ?? '',
                                        color: const Color.fromARGB(
                                                255, 211, 19, 5)
                                            .withValues(alpha: 0.8),
                                        borderRadius: 40));
                              })
                        ])))),
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

  Widget _camera() {
    return ChangeNotifierProvider.value(
        value: _model,
        builder: (context, child) {
          // var v1 = NavigatorRep().size.height;
          // var v = (NavigatorRep().size.height + 20 / 3);
          var collapse = context.select<AppModel, bool>((v) => v.collapse);
          return Container(
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              height: double.infinity,
              child: Stack(alignment: Alignment.center, children: [
                //
                // surface
                Positioned(
                    // top: 0,
                    // top: collapse ? NavigatorRep().size.height / 3 : 0,
                    // top: 0,
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    // bottom: collapse ? -NavigatorRep().size.height / 3 : 0,
                    child: LayoutBuilder(builder: (context, constraints) {
                      () async {
                        _model.devRotation =
                            await CameraRep().getDeviceSensor();
                        _model.updateRotation();
                      }();
                      return Builder(builder: (context) {
                        var size = MediaQuery.of(context).size;
                        var camera = context
                            .select<RecordModel, Camera?>((v) => v.camera);
                        var layout = context.select<RecordModel, SurfaceLayout>(
                            (v) => v.layout);
                        logDebug(
                            'BTEST: width=${camera?.size.width}, height=${camera?.size.height}, rotation-surface=${layout.rotation}, ratio=${layout.ratio}');
                        // return Text('111');
                        return ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: RotatedBox(
                                quarterTurns: layout.rotation,
                                child: FittedBox(
                                    fit: BoxFit.cover,
                                    // fit: BoxFit.fitHeight,
                                    // fit: BoxFit.fitWidth,
                                    // fit: BoxFit.fill,
                                    child: SizedBox(
                                        // width: 500, // Same as the container's width
                                        // height: 500, // Same as the container's height
                                        // width: NavigatorRep().size.width,
                                        // // height: NavigatorRep().size.height,
                                        // height:
                                        //     (NavigatorRep().size.height + 20 / 3),
                                        // width: 350 ?? 100,
                                        // height: 350 ?? 100,
                                        width: camera?.size.width ?? size.width,
                                        height:
                                            camera?.size.height ?? size.height,
                                        child: AndroidView(
                                          viewType: 'my_gl_surface_view',
                                          creationParams: null,
                                          creationParamsCodec:
                                              const StandardMessageCodec(),
                                          onPlatformViewCreated:
                                              _onPlatformViewCreated,
                                        )))));
                      });
                    })),
                //
                // for presentation
                // Positioned(
                //     top: 0,
                //     left: 0,
                //     right: 0,
                //     // bottom: 0,
                //     // bottom: -(NavigatorRep().size.height + 20 / 3),
                //     child: ClipRRect(
                //         borderRadius: BorderRadius.circular(20.0),
                //         child: RotatedBox(
                //             // quarterTurns: 0,
                //             quarterTurns: 1,
                //             child: Image.asset(
                //               'assets/image.jpeg',
                //               // width: 500,
                //               // height: 650,
                //               // fit: BoxFit.fitWidth,
                //               // fit: BoxFit.fitHeight,
                //               //
                //             )))),
                //
                // blur
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    // bottom: -(NavigatorRep().size.height + 20 / 3),
                    child: _blurTransition()),
                //
                // progress
                Positioned.fill(
                    child: Stack(alignment: Alignment.center, children: [
                  RepaintBoundary(child: Builder(builder: (context) {
                    var wait = context
                        .select<RecordModel, bool>((v) => v.orientationpWait);
                    if (wait) {
                      return const SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator());
                    }
                    return const SizedBox();
                  }))
                ])),
                //
                // buttons
                Positioned(left: 0, bottom: 0, right: 0, child: _buttons())
              ]));
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
                  _lastCaptured(),
                  //
                  // center
                  AnimatedCameraButton(
                      activeDefault: CameraRep().captureActive,
                      onStopOutsideStream: _onStopRecordStream,
                      onCapture: () async {
                        await CameraRep().setCaptureActive(true);
                      },
                      onStop: () async {
                        await CameraRep().setCaptureActive(false);
                      }),
                  //
                  // right
                  RepaintBoundary(child: Builder(builder: (context) {
                    var camera =
                        context.select<RecordModel, Camera?>((v) => v.camera);
                    return AnimatedRotation(
                        turns:
                            camera?.facing == Constants.defaultCamera ? 0 : 0.5,
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
                              if (_model.flipWait) return;
                              _model.setFlipWait(true);
                              _start(flip: true);
                            }));
                  }))
                ])));
  }

  Widget _blurTransition() {
    return Builder(builder: (context) {
      var layout =
          context.select<RecordModel, SurfaceLayout>((v) => v.oldLayout);
      var imgBlur = context.select<RecordModel, String?>((v) => v.imgBlur);
      logDebug(
          'BTEST: rotation-blur=${layout.rotation}, ratio=${layout.ratio}');
      return RotatedBox(
          quarterTurns: layout.rotation,
          child: AspectRatio(
              aspectRatio: layout.ratio,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Stack(children: [
                    Positioned.fill(
                        child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 50),
                            opacity: imgBlur == null ? 0 : 1,
                            child: imgBlur == null
                                ? const SizedBox()
                                : Image.memory(
                                    File(imgBlur).readAsBytesSync(),
                                    // color: Colors.yellow,
                                    // colorBlendMode: BlendMode.color,
                                    // cacheHeight: 100,
                                    // cacheWidth: 100,
                                    //     NavigatorRep().size.width.toInt(),
                                    // color: Colors.yellow,
                                    // fit: BoxFit.fitHeight,
                                    fit: BoxFit.cover,
                                    // fit: BoxFit.fill
                                  ))),
                    if (imgBlur != null)
                      Positioned.fill(
                          child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX:
                                    5.0, // Control the intensity of the horizontal blur
                                sigmaY:
                                    5.0, // Control the intensity of the vertical blur
                              ),
                              child: Container(
                                // This container is needed to define the size of the blur area.
                                // Since the image fills the Stack, this transparent container
                                // ensures the blur covers the same area.
                                color: Colors.black.withValues(
                                    alpha:
                                        0.00001), // Slight overlay for effect
                              )))
                  ]))));
    });
  }

  Widget _lastCaptured() {
    return Builder(builder: (context) {
      var item = _captured;
      return AnimatedOpacity(
          opacity: _hasLastCapture ? 1 : 0,
          duration: Constants.lastFrameDuration,
          child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.colorButton,
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Stack(alignment: Alignment.center, children: [
                    AnimatedPositioned(
                        duration: Constants.lastFrameDuration,
                        left: _onLeftToGone ? -55 : (_onRightToLeft ? 0 : 55),
                        bottom: 0,
                        top: 0,
                        child: SizedBox(
                            width: 55,
                            height: 55,
                            child: item ?? const SizedBox())),
                    // const Center(
                    //     child: Text('2', style: TextStyle(color: Colors.white)))
                  ]))));
    });
  }
}
