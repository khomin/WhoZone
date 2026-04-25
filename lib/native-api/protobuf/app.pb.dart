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

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class StartLibParam extends $pb.GeneratedMessage {
  factory StartLibParam({
    $core.String? cacheDirPath,
    $core.String? regServAddr,
    $core.int? regServPort,
    $core.String? fcm,
    $core.String? nativeLogPath,
    $core.bool? useMirrorCppLog,
    $core.bool? notificationShowData,
    $core.int? mtuLen,
  }) {
    final result = create();
    if (cacheDirPath != null) result.cacheDirPath = cacheDirPath;
    if (regServAddr != null) result.regServAddr = regServAddr;
    if (regServPort != null) result.regServPort = regServPort;
    if (fcm != null) result.fcm = fcm;
    if (nativeLogPath != null) result.nativeLogPath = nativeLogPath;
    if (useMirrorCppLog != null) result.useMirrorCppLog = useMirrorCppLog;
    if (notificationShowData != null)
      result.notificationShowData = notificationShowData;
    if (mtuLen != null) result.mtuLen = mtuLen;
    return result;
  }

  StartLibParam._();

  factory StartLibParam.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StartLibParam.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StartLibParam',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'app'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cacheDirPath')
    ..aOS(2, _omitFieldNames ? '' : 'regServAddr')
    ..aI(3, _omitFieldNames ? '' : 'regServPort')
    ..aOS(6, _omitFieldNames ? '' : 'fcm')
    ..aOS(7, _omitFieldNames ? '' : 'nativeLogPath')
    ..aOB(8, _omitFieldNames ? '' : 'useMirrorCppLog')
    ..aOB(10, _omitFieldNames ? '' : 'notificationShowData')
    ..aI(12, _omitFieldNames ? '' : 'mtuLen', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartLibParam clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartLibParam copyWith(void Function(StartLibParam) updates) =>
      super.copyWith((message) => updates(message as StartLibParam))
          as StartLibParam;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartLibParam create() => StartLibParam._();
  @$core.override
  StartLibParam createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StartLibParam getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StartLibParam>(create);
  static StartLibParam? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cacheDirPath => $_getSZ(0);
  @$pb.TagNumber(1)
  set cacheDirPath($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCacheDirPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearCacheDirPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get regServAddr => $_getSZ(1);
  @$pb.TagNumber(2)
  set regServAddr($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRegServAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearRegServAddr() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get regServPort => $_getIZ(2);
  @$pb.TagNumber(3)
  set regServPort($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRegServPort() => $_has(2);
  @$pb.TagNumber(3)
  void clearRegServPort() => $_clearField(3);

  @$pb.TagNumber(6)
  $core.String get fcm => $_getSZ(3);
  @$pb.TagNumber(6)
  set fcm($core.String value) => $_setString(3, value);
  @$pb.TagNumber(6)
  $core.bool hasFcm() => $_has(3);
  @$pb.TagNumber(6)
  void clearFcm() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get nativeLogPath => $_getSZ(4);
  @$pb.TagNumber(7)
  set nativeLogPath($core.String value) => $_setString(4, value);
  @$pb.TagNumber(7)
  $core.bool hasNativeLogPath() => $_has(4);
  @$pb.TagNumber(7)
  void clearNativeLogPath() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get useMirrorCppLog => $_getBF(5);
  @$pb.TagNumber(8)
  set useMirrorCppLog($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(8)
  $core.bool hasUseMirrorCppLog() => $_has(5);
  @$pb.TagNumber(8)
  void clearUseMirrorCppLog() => $_clearField(8);

  @$pb.TagNumber(10)
  $core.bool get notificationShowData => $_getBF(6);
  @$pb.TagNumber(10)
  set notificationShowData($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(10)
  $core.bool hasNotificationShowData() => $_has(6);
  @$pb.TagNumber(10)
  void clearNotificationShowData() => $_clearField(10);

  @$pb.TagNumber(12)
  $core.int get mtuLen => $_getIZ(7);
  @$pb.TagNumber(12)
  set mtuLen($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(12)
  $core.bool hasMtuLen() => $_has(7);
  @$pb.TagNumber(12)
  void clearMtuLen() => $_clearField(12);
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

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
