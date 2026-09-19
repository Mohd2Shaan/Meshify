// This is a generated file - do not edit.
//
// Generated from emergency_message.proto.

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

@$core.Deprecated('Use messageTypeDescriptor instead')
const MessageType$json = {
  '1': 'MessageType',
  '2': [
    {'1': 'MESSAGE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'MEDICAL', '2': 1},
    {'1': 'TRAPPED', '2': 2},
    {'1': 'SUPPLIES', '2': 3},
    {'1': 'STATUS', '2': 4},
  ],
};

/// Descriptor for `MessageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageTypeDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlVHlwZRIcChhNRVNTQUdFX1RZUEVfVU5TUEVDSUZJRUQQABILCgdNRURJQ0FMEA'
    'ESCwoHVFJBUFBFRBACEgwKCFNVUFBMSUVTEAMSCgoGU1RBVFVTEAQ=');

@$core.Deprecated('Use meshPacketDescriptor instead')
const MeshPacket$json = {
  '1': 'MeshPacket',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'sender_device_id', '3': 2, '4': 1, '5': 9, '10': 'senderDeviceId'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.emergencymesh.MessageType',
      '10': 'type'
    },
    {'1': 'timestamp_ms', '3': 4, '4': 1, '5': 3, '10': 'timestampMs'},
    {'1': 'ttl_expiry_ms', '3': 5, '4': 1, '5': 3, '10': 'ttlExpiryMs'},
    {'1': 'hop_count', '3': 6, '4': 1, '5': 5, '10': 'hopCount'},
    {'1': 'sealed_payload', '3': 7, '4': 1, '5': 12, '10': 'sealedPayload'},
  ],
};

/// Descriptor for `MeshPacket`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meshPacketDescriptor = $convert.base64Decode(
    'CgpNZXNoUGFja2V0Eh0KCm1lc3NhZ2VfaWQYASABKAlSCW1lc3NhZ2VJZBIoChBzZW5kZXJfZG'
    'V2aWNlX2lkGAIgASgJUg5zZW5kZXJEZXZpY2VJZBIuCgR0eXBlGAMgASgOMhouZW1lcmdlbmN5'
    'bWVzaC5NZXNzYWdlVHlwZVIEdHlwZRIhCgx0aW1lc3RhbXBfbXMYBCABKANSC3RpbWVzdGFtcE'
    '1zEiIKDXR0bF9leHBpcnlfbXMYBSABKANSC3R0bEV4cGlyeU1zEhsKCWhvcF9jb3VudBgGIAEo'
    'BVIIaG9wQ291bnQSJQoOc2VhbGVkX3BheWxvYWQYByABKAxSDXNlYWxlZFBheWxvYWQ=');

@$core.Deprecated('Use emergencyPayloadDescriptor instead')
const EmergencyPayload$json = {
  '1': 'EmergencyPayload',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'note', '3': 3, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `EmergencyPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emergencyPayloadDescriptor = $convert.base64Decode(
    'ChBFbWVyZ2VuY3lQYXlsb2FkEhoKCGxhdGl0dWRlGAEgASgBUghsYXRpdHVkZRIcCglsb25naX'
    'R1ZGUYAiABKAFSCWxvbmdpdHVkZRISCgRub3RlGAMgASgJUgRub3Rl');
