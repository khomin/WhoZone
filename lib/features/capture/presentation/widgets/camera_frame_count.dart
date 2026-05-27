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
    if (count == 0) {
      return const SizedBox();
    }
    return RepaintBoundary(
      child: SizedBox(
        width: 80,
        height: 35,
        child: Row(children: [
          Icon(Icons.camera, color: color, size: 25),
          const SizedBox(width: 4),
          Flexible(
              child: Text(
            count.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 17, color: color),
          ))
        ]),
      ),
    );
  }
}
