import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/elipse_with_text.dart';
import 'package:flutter_demo/features/capture/data/models/capture_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:provider/provider.dart';

class CameraFrameCount extends StatelessWidget {
  CameraFrameCount({required this.onPressed});

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.cameraButtonIcon;
    final count = context.select<CaptureModel, int>(
      (value) => value.detectionCount,
    );
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide.none,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.defaultDensityForPlatform(
                  TargetPlatform.android,
                ),
                alignment: Alignment.center,
                animationDuration: Duration.zero,
                shadowColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                iconColor: Colors.white,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
              ),
              onPressed: () {
                onPressed();
              },
              child: Icon(
                CupertinoIcons.rectangle_fill_on_rectangle_angled_fill,
                size: 22,
              ),
            ),
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
    );
  }
}
