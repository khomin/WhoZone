import 'package:flutter/material.dart';
import 'package:flutter_demo/features/capture/data/models/capture_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:provider/provider.dart';

class CameraFrameCount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.cameraButtonIcon;
    final count = context.select<CaptureModel, int>(
      (value) => value.detectionCount,
    );
    if (count == 0) return const SizedBox();
    return Positioned(
      bottom: 10,
      left: 10,
      child: RepaintBoundary(
        child: SizedBox(
          width: 80,
          height: 30,
          child: Row(children: [
            Icon(Icons.camera, color: color),
            Flexible(
                child: Text(
              count.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 17, color: color),
            ))
          ]),
        ),
      ),
    );
  }
}
