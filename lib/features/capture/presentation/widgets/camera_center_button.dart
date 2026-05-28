import 'package:flutter/material.dart';
import 'package:flutter_demo/components/animated_camera_button.dart';
import 'package:flutter_demo/features/capture/data/models/capture_model.dart';
import 'package:provider/provider.dart';

class CameraCenterButton extends StatelessWidget {
  CameraCenterButton({
    required this.captureEnabled,
    required this.onMakeOneShot,
  });
  final bool captureEnabled;
  final VoidCallback onMakeOneShot;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 70,
        width: 140,
        // color: Colors.amber,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedCameraButton(
                widthStart: 70.0,
                widthEnd: 140.0,
                activeDefault: captureEnabled,
                onCapture: () async {
                  context.read<CaptureModel>().startCapture();
                },
                onStop: () async {
                  context.read<CaptureModel>().stopCapture();
                },
                onImagePressed: () => onMakeOneShot(),
              ),
            ]),
      ),
    );
  }
}
