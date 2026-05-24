import 'package:flutter/material.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/core/utils/common.dart';
import 'package:flutter_demo/features/capture_settings/data/models/capture_settings_model.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/pages/app_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:provider/provider.dart';

class CaptureSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => getIt<CaptureSettingsModel>(),
        builder: (context, child) {
          return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.colorBar,
              body: Stack(children: [
                Column(children: [
                  Container(
                    color: Theme.of(context).colorScheme.colorBar,
                    height: kToolbarHeight,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text('Camera settings',
                                style: Theme.of(context)
                                    .colorScheme
                                    .homeCardH1Style),
                          ),
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
                              }),
                        ]),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //
                            // capture image interval
                            Builder(builder: (context) {
                              var duration = context
                                  .select<CaptureSettingsModel, Duration>(
                                (v) => v.captureInterval,
                              );
                              return Row(children: [
                                Padding(
                                    padding: const EdgeInsets.only(left: 25),
                                    child: Text(
                                        'Capture filter ${duration.format()}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .colorTextAccent))),
                                Expanded(
                                    child: Slider(
                                        value: duration.inSeconds.toDouble(),
                                        min: 1.0,
                                        max: 30.0,
                                        divisions: 30,
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .colorSecondary,
                                        inactiveColor: Theme.of(context)
                                            .colorScheme
                                            .colorSecondary,
                                        thumbColor: Theme.of(context)
                                            .colorScheme
                                            .colorPrimary,
                                        label: duration.format(),
                                        onChanged: (double v) {
                                          context
                                              .read<CaptureSettingsModel>()
                                              .setCaptureInterval(
                                                  Duration(seconds: v.toInt()));
                                        }))
                              ]);
                            }),
                          ]))
                ]),
                Builder(builder: (context) {
                  var size = MediaQuery.sizeOf(context);
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
        });
  }
}
