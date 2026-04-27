// This is a generated file - do not edit.
//
// Generated from app.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use initParamDescriptor instead')
const InitParam$json = {
  '1': 'InitParam',
  '2': [
    {'1': 'coco_names', '3': 1, '4': 3, '5': 9, '10': 'cocoNames'},
    {'1': 'model_path', '3': 2, '4': 1, '5': 9, '10': 'modelPath'},
  ],
};

/// Descriptor for `InitParam`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initParamDescriptor = $convert.base64Decode(
    'CglJbml0UGFyYW0SHQoKY29jb19uYW1lcxgBIAMoCVIJY29jb05hbWVzEh0KCm1vZGVsX3BhdG'
    'gYAiABKAlSCW1vZGVsUGF0aA==');

@$core.Deprecated('Use cameraInfoDescriptor instead')
const CameraInfo$json = {
  '1': 'CameraInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'sensor_rotation', '3': 2, '4': 1, '5': 13, '10': 'sensorRotation'},
    {'1': 'is_front', '3': 3, '4': 1, '5': 8, '10': 'isFront'},
    {
      '1': 'cameraSizes',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.app.Size',
      '10': 'cameraSizes'
    },
    {
      '1': 'fps_ranges',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.app.Range',
      '10': 'fpsRanges'
    },
  ],
};

/// Descriptor for `CameraInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cameraInfoDescriptor = $convert.base64Decode(
    'CgpDYW1lcmFJbmZvEg4KAmlkGAEgASgJUgJpZBInCg9zZW5zb3Jfcm90YXRpb24YAiABKA1SDn'
    'NlbnNvclJvdGF0aW9uEhkKCGlzX2Zyb250GAMgASgIUgdpc0Zyb250EisKC2NhbWVyYVNpemVz'
    'GAQgAygLMgkuYXBwLlNpemVSC2NhbWVyYVNpemVzEikKCmZwc19yYW5nZXMYBSADKAsyCi5hcH'
    'AuUmFuZ2VSCWZwc1Jhbmdlcw==');

@$core.Deprecated('Use cameraDescriptor instead')
const Camera$json = {
  '1': 'Camera',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'is_front', '3': 2, '4': 1, '5': 8, '10': 'isFront'},
    {'1': 'sensor', '3': 3, '4': 1, '5': 13, '10': 'sensor'},
    {'1': 'size', '3': 4, '4': 1, '5': 11, '6': '.app.Size', '10': 'size'},
  ],
};

/// Descriptor for `Camera`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cameraDescriptor = $convert.base64Decode(
    'CgZDYW1lcmESDgoCaWQYASABKAlSAmlkEhkKCGlzX2Zyb250GAIgASgIUgdpc0Zyb250EhYKBn'
    'NlbnNvchgDIAEoDVIGc2Vuc29yEh0KBHNpemUYBCABKAsyCS5hcHAuU2l6ZVIEc2l6ZQ==');

@$core.Deprecated('Use rangeDescriptor instead')
const Range$json = {
  '1': 'Range',
  '2': [
    {'1': 'lower', '3': 1, '4': 1, '5': 13, '10': 'lower'},
    {'1': 'upper', '3': 2, '4': 1, '5': 13, '10': 'upper'},
  ],
};

/// Descriptor for `Range`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rangeDescriptor = $convert.base64Decode(
    'CgVSYW5nZRIUCgVsb3dlchgBIAEoDVIFbG93ZXISFAoFdXBwZXIYAiABKA1SBXVwcGVy');

@$core.Deprecated('Use sizeDescriptor instead')
const Size$json = {
  '1': 'Size',
  '2': [
    {'1': 'width', '3': 1, '4': 1, '5': 13, '10': 'width'},
    {'1': 'height', '3': 2, '4': 1, '5': 13, '10': 'height'},
  ],
};

/// Descriptor for `Size`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sizeDescriptor = $convert.base64Decode(
    'CgRTaXplEhQKBXdpZHRoGAEgASgNUgV3aWR0aBIWCgZoZWlnaHQYAiABKA1SBmhlaWdodA==');
