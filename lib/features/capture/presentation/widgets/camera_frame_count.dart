import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/elipse_with_text.dart';
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
    return RepaintBoundary(
      child: Container(
        width: 50,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              CupertinoIcons.rectangle_fill_on_rectangle_angled_fill,
              size: 22,
            ),
            if (count != 0)
              Positioned(
                top: 0,
                right: 2,
                child: ElipseWithText(
                  text: count.toString(),
                  color: color,
                ),
              )
          ],
        ),
      ),
    );
  }
}
