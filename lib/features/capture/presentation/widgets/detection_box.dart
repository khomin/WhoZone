import 'package:flutter/painting.dart';
import 'package:flutter_demo/core/native-api/protobuf/app.pb.dart' as app;

class DetectionBox {
  final int trackId;
  final int classId;
  final String className;
  final double confidence;
  final Rect normalizedRect;
  final double velocityX; // normalized units per second
  final double velocityY;

  DetectionBox({
    required this.trackId,
    required this.classId,
    required this.className,
    required this.confidence,
    required this.normalizedRect,
    required this.velocityX,
    required this.velocityY,
  });

  factory DetectionBox.fromProto(
    app.DetectionItem proto,
    List<String> classNames,
  ) {
    return DetectionBox(
      trackId: proto.trackId,
      classId: proto.classId,
      className: classNames[proto.classId],
      confidence: proto.confidence,
      normalizedRect: Rect.fromLTWH(
        proto.detection.x.toDouble(),
        proto.detection.y.toDouble(),
        proto.detection.width.toDouble(),
        proto.detection.height.toDouble(),
      ),
      velocityX: proto.velocityX,
      velocityY: proto.velocityY,
    );
  }

  @override
  String toString() {
    return 'DetectionBox($className, ${(confidence * 100).toInt()})';
  }
}
