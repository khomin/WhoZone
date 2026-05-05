import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/pages/capture/capture_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/settings_rep.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:provider/provider.dart';

class CameraSettingsPage extends StatefulWidget {
  const CameraSettingsPage({super.key});

  @override
  State<CameraSettingsPage> createState() => CameraSettingsPageState();
}

class CameraSettingsPageState extends State<CameraSettingsPage> {
  final _dispStream = DisposableStream();
  late CaptureModel _model;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _model.init(
        captureIntervalSec: await SettingsRep().getCaptureIntervalSec(),
      );
    });
  }

  @override
  void dispose() {
    _dispStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _model = context.read<CaptureModel>();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.colorBar,
        body: Stack(children: [
          Column(children: [
            Container(
                color: Theme.of(context).colorScheme.colorBar,
                height: kToolbarHeight,
                child: Row(children: [
                  Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text('Camera settings',
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
                      iconData: Icons.close_sharp,
                      onPressed: (p0) async {
                        var model = context.read<AppModel>();
                        model.setCollapse(!model.collapse);
                      })
                ])),
            Container(
                margin: const EdgeInsets.only(top: 15),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //
                      // capture image interval
                      Builder(builder: (context) {
                        var captureSec = context.select<CaptureModel, int>(
                            (v) => v.captureIntervalSec);
                        return Row(children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Text('Capture filter [$captureSec] sec',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .colorTextAccent))),
                          Expanded(
                              child: Slider(
                                  value: captureSec.toDouble(),
                                  min: 1.0,
                                  max: 30.0,
                                  divisions: 100,
                                  activeColor: Theme.of(context)
                                      .colorScheme
                                      .colorSecondary,
                                  inactiveColor: Theme.of(context)
                                      .colorScheme
                                      .colorSecondary,
                                  thumbColor: Theme.of(context)
                                      .colorScheme
                                      .colorPrimary,
                                  label: captureSec.toString(),
                                  onChanged: (double newValue) {
                                    context
                                        .read<CaptureModel>()
                                        .setCaptureImageIntVal(
                                            newValue.toInt());
                                  }))
                        ]);
                      }),
                    ]))
          ]),
          Builder(builder: (context) {
            var size = MediaQuery.of(context).size;
            return Positioned(
                top: (size.height / 3),
                left: 0,
                right: 0,
                child: Builder(builder: (context) {
                  var collapse =
                      context.select<AppModel, bool>((v) => v.collapse);
                  if (collapse) {
                    return Container(
                        height: 50,
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              spreadRadius: 10,
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 0))
                        ]));
                  }
                  return const SizedBox();
                }));
          })
        ]));
  }
}
