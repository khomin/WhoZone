import 'package:flutter/material.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/features/capture/data/models/capture_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart' as app;

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
                      final model = context.read<CaptureModel>();
                      if (model.flipWait) return;
                      model.setFlipWait(true);
                      model.start(flip: true);
                      model.setFlipWait(false);
                    }));
          }),
        ),
      ),
    );
  }
}
