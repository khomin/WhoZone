// This is a generated file - do not edit.
//
// Generated from app.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class InitParam extends $pb.GeneratedMessage {
  factory InitParam({
    $core.Iterable<$core.String>? cocoNames,
    $core.String? modelPath,
    $core.int? targetWidth,
    $core.int? targetHeight,
  }) {
    final result = create();
    if (cocoNames != null) result.cocoNames.addAll(cocoNames);
    if (modelPath != null) result.modelPath = modelPath;
    if (targetWidth != null) result.targetWidth = targetWidth;
    if (targetHeight != null) result.targetHeight = targetHeight;
    return result;
  }

  InitParam._();

  factory InitParam.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InitParam.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitParam',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'cocoNames')
    ..aOS(2, _omitFieldNames ? '' : 'modelPath')
    ..aI(3, _omitFieldNames ? '' : 'targetWidth')
    ..aI(4, _omitFieldNames ? '' : 'targetHeight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitParam clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitParam copyWith(void Function(InitParam) updates) =>
      super.copyWith((message) => updates(message as InitParam)) as InitParam;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitParam create() => InitParam._();
  @$core.override
  InitParam createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InitParam getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InitParam>(create);
  static InitParam? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get cocoNames => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get modelPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set modelPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasModelPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearModelPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get targetWidth => $_getIZ(2);
  @$pb.TagNumber(3)
  set targetWidth($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetWidth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get targetHeight => $_getIZ(3);
  @$pb.TagNumber(4)
  set targetHeight($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTargetHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetHeight() => $_clearField(4);
}

class CameraInfo extends $pb.GeneratedMessage {
  factory CameraInfo({
    $core.String? id,
    $core.int? sensorRotation,
    $core.bool? isFront,
    $core.Iterable<Size>? cameraSizes,
    $core.Iterable<Range>? fpsRanges,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (sensorRotation != null) result.sensorRotation = sensorRotation;
    if (isFront != null) result.isFront = isFront;
    if (cameraSizes != null) result.cameraSizes.addAll(cameraSizes);
    if (fpsRanges != null) result.fpsRanges.addAll(fpsRanges);
    return result;
  }

  CameraInfo._();

  factory CameraInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CameraInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CameraInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'sensorRotation',
        fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'isFront')
    ..pPM<Size>(4, _omitFieldNames ? '' : 'cameraSizes',
        protoName: 'cameraSizes', subBuilder: Size.create)
    ..pPM<Range>(5, _omitFieldNames ? '' : 'fpsRanges',
        subBuilder: Range.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CameraInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CameraInfo copyWith(void Function(CameraInfo) updates) =>
      super.copyWith((message) => updates(message as CameraInfo)) as CameraInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CameraInfo create() => CameraInfo._();
  @$core.override
  CameraInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CameraInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CameraInfo>(create);
  static CameraInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get sensorRotation => $_getIZ(1);
  @$pb.TagNumber(2)
  set sensorRotation($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSensorRotation() => $_has(1);
  @$pb.TagNumber(2)
  void clearSensorRotation() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isFront => $_getBF(2);
  @$pb.TagNumber(3)
  set isFront($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsFront() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsFront() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<Size> get cameraSizes => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<Range> get fpsRanges => $_getList(4);
}

class Camera extends $pb.GeneratedMessage {
  factory Camera({
    $core.String? id,
    $core.bool? isFront,
    $core.int? sensor,
    Size? size,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (isFront != null) result.isFront = isFront;
    if (sensor != null) result.sensor = sensor;
    if (size != null) result.size = size;
    return result;
  }

  Camera._();

  factory Camera.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Camera.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Camera',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'isFront')
    ..aI(3, _omitFieldNames ? '' : 'sensor', fieldType: $pb.PbFieldType.OU3)
    ..aOM<Size>(4, _omitFieldNames ? '' : 'size', subBuilder: Size.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Camera clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Camera copyWith(void Function(Camera) updates) =>
      super.copyWith((message) => updates(message as Camera)) as Camera;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Camera create() => Camera._();
  @$core.override
  Camera createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Camera getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Camera>(create);
  static Camera? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isFront => $_getBF(1);
  @$pb.TagNumber(2)
  set isFront($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsFront() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFront() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sensor => $_getIZ(2);
  @$pb.TagNumber(3)
  set sensor($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSensor() => $_has(2);
  @$pb.TagNumber(3)
  void clearSensor() => $_clearField(3);

  @$pb.TagNumber(4)
  Size get size => $_getN(3);
  @$pb.TagNumber(4)
  set size(Size value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearSize() => $_clearField(4);
  @$pb.TagNumber(4)
  Size ensureSize() => $_ensure(3);
}

class Range extends $pb.GeneratedMessage {
  factory Range({
    $core.int? lower,
    $core.int? upper,
  }) {
    final result = create();
    if (lower != null) result.lower = lower;
    if (upper != null) result.upper = upper;
    return result;
  }

  Range._();

  factory Range.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Range.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Range',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'lower', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'upper', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Range clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Range copyWith(void Function(Range) updates) =>
      super.copyWith((message) => updates(message as Range)) as Range;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Range create() => Range._();
  @$core.override
  Range createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Range getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Range>(create);
  static Range? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get lower => $_getIZ(0);
  @$pb.TagNumber(1)
  set lower($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLower() => $_has(0);
  @$pb.TagNumber(1)
  void clearLower() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get upper => $_getIZ(1);
  @$pb.TagNumber(2)
  set upper($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUpper() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpper() => $_clearField(2);
}

class Size extends $pb.GeneratedMessage {
  factory Size({
    $core.int? width,
    $core.int? height,
  }) {
    final result = create();
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    return result;
  }

  Size._();

  factory Size.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Size.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Size',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'width', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Size clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Size copyWith(void Function(Size) updates) =>
      super.copyWith((message) => updates(message as Size)) as Size;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Size create() => Size._();
  @$core.override
  Size createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Size getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Size>(create);
  static Size? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get width => $_getIZ(0);
  @$pb.TagNumber(1)
  set width($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => $_clearField(2);
}

enum EventWrapper_Msg { detection, notSet }

class EventWrapper extends $pb.GeneratedMessage {
  factory EventWrapper({
    Detection? detection,
  }) {
    final result = create();
    if (detection != null) result.detection = detection;
    return result;
  }

  EventWrapper._();

  factory EventWrapper.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EventWrapper.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, EventWrapper_Msg> _EventWrapper_MsgByTag = {
    1: EventWrapper_Msg.detection,
    0: EventWrapper_Msg.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EventWrapper',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app'),
      createEmptyInstance: create)
    ..oo(0, [1])
    ..aOM<Detection>(1, _omitFieldNames ? '' : 'detection',
        subBuilder: Detection.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventWrapper clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EventWrapper copyWith(void Function(EventWrapper) updates) =>
      super.copyWith((message) => updates(message as EventWrapper))
          as EventWrapper;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EventWrapper create() => EventWrapper._();
  @$core.override
  EventWrapper createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EventWrapper getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EventWrapper>(create);
  static EventWrapper? _defaultInstance;

  @$pb.TagNumber(1)
  EventWrapper_Msg whichMsg() => _EventWrapper_MsgByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  void clearMsg() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Detection get detection => $_getN(0);
  @$pb.TagNumber(1)
  set detection(Detection value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDetection() => $_has(0);
  @$pb.TagNumber(1)
  void clearDetection() => $_clearField(1);
  @$pb.TagNumber(1)
  Detection ensureDetection() => $_ensure(0);
}

class Detection extends $pb.GeneratedMessage {
  factory Detection({
    $core.Iterable<DetectionItem>? item,
    $core.int? frameCount,
    $fixnum.Int64? timestampNs,
  }) {
    final result = create();
    if (item != null) result.item.addAll(item);
    if (frameCount != null) result.frameCount = frameCount;
    if (timestampNs != null) result.timestampNs = timestampNs;
    return result;
  }

  Detection._();

  factory Detection.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Detection.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Detection',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app'),
      createEmptyInstance: create)
    ..pPM<DetectionItem>(1, _omitFieldNames ? '' : 'item',
        subBuilder: DetectionItem.create)
    ..aI(4, _omitFieldNames ? '' : 'frameCount')
    ..aInt64(5, _omitFieldNames ? '' : 'timestampNs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Detection clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Detection copyWith(void Function(Detection) updates) =>
      super.copyWith((message) => updates(message as Detection)) as Detection;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Detection create() => Detection._();
  @$core.override
  Detection createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Detection getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Detection>(create);
  static Detection? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DetectionItem> get item => $_getList(0);

  @$pb.TagNumber(4)
  $core.int get frameCount => $_getIZ(1);
  @$pb.TagNumber(4)
  set frameCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(4)
  $core.bool hasFrameCount() => $_has(1);
  @$pb.TagNumber(4)
  void clearFrameCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestampNs => $_getI64(2);
  @$pb.TagNumber(5)
  set timestampNs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestampNs() => $_has(2);
  @$pb.TagNumber(5)
  void clearTimestampNs() => $_clearField(5);
}

class DetectionItem extends $pb.GeneratedMessage {
  factory DetectionItem({
    Rect? detection,
    $core.int? classId,
    $core.double? confidence,
  }) {
    final result = create();
    if (detection != null) result.detection = detection;
    if (classId != null) result.classId = classId;
    if (confidence != null) result.confidence = confidence;
    return result;
  }

  DetectionItem._();

  factory DetectionItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectionItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectionItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app'),
      createEmptyInstance: create)
    ..aOM<Rect>(1, _omitFieldNames ? '' : 'detection', subBuilder: Rect.create)
    ..aI(2, _omitFieldNames ? '' : 'classId')
    ..aD(3, _omitFieldNames ? '' : 'confidence', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectionItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectionItem copyWith(void Function(DetectionItem) updates) =>
      super.copyWith((message) => updates(message as DetectionItem))
          as DetectionItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectionItem create() => DetectionItem._();
  @$core.override
  DetectionItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectionItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectionItem>(create);
  static DetectionItem? _defaultInstance;

  @$pb.TagNumber(1)
  Rect get detection => $_getN(0);
  @$pb.TagNumber(1)
  set detection(Rect value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDetection() => $_has(0);
  @$pb.TagNumber(1)
  void clearDetection() => $_clearField(1);
  @$pb.TagNumber(1)
  Rect ensureDetection() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get classId => $_getIZ(1);
  @$pb.TagNumber(2)
  set classId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClassId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClassId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get confidence => $_getN(2);
  @$pb.TagNumber(3)
  set confidence($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConfidence() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfidence() => $_clearField(3);
}

class Rect extends $pb.GeneratedMessage {
  factory Rect({
    $core.int? x,
    $core.int? y,
    $core.int? width,
    $core.int? height,
  }) {
    final result = create();
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    return result;
  }

  Rect._();

  factory Rect.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Rect.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Rect',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'x')
    ..aI(2, _omitFieldNames ? '' : 'y')
    ..aI(3, _omitFieldNames ? '' : 'width')
    ..aI(4, _omitFieldNames ? '' : 'height')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Rect clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Rect copyWith(void Function(Rect) updates) =>
      super.copyWith((message) => updates(message as Rect)) as Rect;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Rect create() => Rect._();
  @$core.override
  Rect createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Rect getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Rect>(create);
  static Rect? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get x => $_getIZ(0);
  @$pb.TagNumber(1)
  set x($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get y => $_getIZ(1);
  @$pb.TagNumber(2)
  set y($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
