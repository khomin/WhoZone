import 'package:flutter/painting.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart' as app;

class DetectionBox {
  final int classId;
  final String className;
  final double confidence;
  final Rect normalizedRect;

  DetectionBox({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.normalizedRect,
  });

  factory DetectionBox.fromProto(
    app.DetectionItem proto,
    List<String> classNames,
  ) {
    return DetectionBox(
      classId: proto.classId,
      className: classNames[proto.classId],
      confidence: proto.confidence,
      normalizedRect: Rect.fromLTWH(
        proto.detection.x.toDouble(),
        proto.detection.y.toDouble(),
        proto.detection.width.toDouble(),
        proto.detection.height.toDouble(),
      ),
    );
  }

  @override
  String toString() {
    return 'DetectionBox($className, ${(confidence * 100).toInt()})';
  }
}
