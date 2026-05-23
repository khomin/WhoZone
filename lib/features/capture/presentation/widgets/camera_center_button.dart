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
                        activeDefault: captureEnabled,
                        onCapture: () async {
                          context.read<CaptureModel>().startCapture();
                        },
                        onStop: () async {
                          context.read<CaptureModel>().stopCapture();
                        },
                        onImagePressed: () => onMakeOneShot(),
                      ),
                    ]))));
  }
}
