import 'package:flutter/painting.dart';
import 'package:flutter_demo/native-api/protobuf/app.pb.dart' as app;

class DetectionBox {
  final int classId;
  final String className;
  final double confidence;
  final Rect normalizedRect; // 0.0 to 1.0 coordinates
  // final int frameCount;
  // final int timestamp;

  DetectionBox({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.normalizedRect,
    // required this.frameCount,
    // required this.timestamp,
  });

  // Create from protobuf message
  factory DetectionBox.fromProto(
    app.DetectionItem proto,
    List<String> classNames,
  ) {
    return DetectionBox(
      classId: proto.classId,
      className: classNames[proto.classId],
      confidence: proto.confidence,
      normalizedRect: Rect.fromLTWH(
        proto.detection.x.toDouble(), // Already normalized (0.0-1.0)
        proto.detection.y.toDouble(),
        proto.detection.width.toDouble(),
        proto.detection.height.toDouble(),
      ),
      // frameCount: proto.frameCount,
      // timestamp: proto.timestamp,
    );
  }

  // Create from FFI raw data
  factory DetectionBox.fromRaw({
    required int classId,
    required List<String> classNames,
    required double confidence,
    required double x,
    required double y,
    required double width,
    required double height,
    // required int frameCount,
    // required int timestamp,
  }) {
    return DetectionBox(
      classId: classId,
      className: classNames[classId],
      confidence: confidence,
      normalizedRect: Rect.fromLTWH(x, y, width, height),
      // frameCount: frameCount,
      // timestamp: timestamp,
    );
  }

  // Scale to screen coordinates
  Rect toScreenRect(Size screenSize) {
    return Rect.fromLTWH(
      normalizedRect.left * screenSize.width,
      normalizedRect.top * screenSize.height,
      normalizedRect.width * screenSize.width,
      normalizedRect.height * screenSize.height,
    );
  }

  @override
  String toString() {
    return 'DetectionBox($className, ${(confidence * 100).toInt()})';
  }
}

// Container for multiple detections
// class DetectionResult {
//   final int frameCount;
//   final int timestamp;
//   final List<DetectionBox> detections;
//   final double fps; // Optional, for debugging

//   DetectionResult({
//     required this.frameCount,
//     required this.timestamp,
//     required this.detections,
//     this.fps = 0.0,
//   });

//   bool get hasDetections => detections.isNotEmpty;

//   // From protobuf
//   factory DetectionResult.fromProto(
//       DetectionResultProto proto, List<String> classNames) {
//     final detections = <DetectionBox>[];
//     for (int i = 0; i < proto.detections.length; i++) {
//       final d = proto.detections[i];
//       detections.add(DetectionBox(
//         classId: d.classId,
//         className: classNames[d.classId],
//         confidence: d.confidence,
//         normalizedRect: Rect.fromLTWH(d.x, d.y, d.width, d.height),
//         frameCount: proto.frameCount,
//         timestamp: proto.timestamp,
//       ));
//     }

//     return DetectionResult(
//       frameCount: proto.frameCount,
//       timestamp: proto.timestamp,
//       detections: detections,
//     );
//   }

//   // Empty result
//   static DetectionResult empty(int frameCount) {
//     return DetectionResult(
//       frameCount: frameCount,
//       timestamp: DateTime.now().millisecondsSinceEpoch,
//       detections: [],
//     );
//   }
// }
