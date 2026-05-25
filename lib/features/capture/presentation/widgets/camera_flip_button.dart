import 'package:flutter/material.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/features/capture/data/models/capture_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_demo/core/native-api/protobuf/app.pb.dart' as app;

class CameraFlipButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 30,
      top: 30,
      child: SizedBox(
        height: 60,
        width: 60,
        child: RepaintBoundary(
          child: Builder(builder: (context) {
            var (camera, flipTurns) =
                context.select<CaptureModel, (app.Camera?, double)>(
              (v) => (v.camera, v.flipTurns),
            );
            return AnimatedRotation(
                turns: flipTurns,
                duration: Constants.duration,
                child: RoundButton(
                    color: Theme.of(context).colorScheme.colorButton,
                    iconColor: Theme.of(context).colorScheme.cameraButtonIcon,
                    size: 55,
                    radius: 90,
                    useScaleAnimation: true,
                    iconData: Icons.flip_camera_android,
                    onPressed: (v) async {
                      final model = context.read<CaptureModel>();
                      if (model.flipBusy) return;
                      model.start(flip: true);
                    }));
          }),
        ),
      ),
    );
  }
}
