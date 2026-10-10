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

@$core.Deprecated('Use receiptStatusDescriptor instead')
const ReceiptStatus$json = {
  '1': 'ReceiptStatus',
  '2': [
    {'1': 'RECEIPT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'DELIVERED', '2': 1},
    {'1': 'ACKNOWLEDGED', '2': 2},
    {'1': 'RESOLVED', '2': 3},
  ],
};

/// Descriptor for `ReceiptStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List receiptStatusDescriptor = $convert.base64Decode(
    'Cg1SZWNlaXB0U3RhdHVzEh4KGlJFQ0VJUFRfU1RBVFVTX1VOU1BFQ0lGSUVEEAASDQoJREVMSV'
    'ZFUkVEEAESEAoMQUNLTk9XTEVER0VEEAISDAoIUkVTT0xWRUQQAw==');

@$core.Deprecated('Use alertLevelDescriptor instead')
const AlertLevel$json = {
  '1': 'AlertLevel',
  '2': [
    {'1': 'ALERT_LEVEL_UNSPECIFIED', '2': 0},
    {'1': 'INFO', '2': 1},
    {'1': 'WARNING', '2': 2},
    {'1': 'CRITICAL', '2': 3},
  ],
};

/// Descriptor for `AlertLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List alertLevelDescriptor = $convert.base64Decode(
    'CgpBbGVydExldmVsEhsKF0FMRVJUX0xFVkVMX1VOU1BFQ0lGSUVEEAASCAoESU5GTxABEgsKB1'
    'dBUk5JTkcQAhIMCghDUklUSUNBTBAD');

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

@$core.Deprecated('Use meshFrameDescriptor instead')
const MeshFrame$json = {
  '1': 'MeshFrame',
  '2': [
    {
      '1': 'notice',
      '3': 101,
      '4': 1,
      '5': 11,
      '6': '.emergencymesh.SignedNotice',
      '10': 'notice'
    },
  ],
};

/// Descriptor for `MeshFrame`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meshFrameDescriptor = $convert.base64Decode(
    'CglNZXNoRnJhbWUSMwoGbm90aWNlGGUgASgLMhsuZW1lcmdlbmN5bWVzaC5TaWduZWROb3RpY2'
    'VSBm5vdGljZQ==');

@$core.Deprecated('Use signedNoticeDescriptor instead')
const SignedNotice$json = {
  '1': 'SignedNotice',
  '2': [
    {'1': 'body', '3': 1, '4': 1, '5': 12, '10': 'body'},
    {'1': 'signature', '3': 2, '4': 1, '5': 12, '10': 'signature'},
  ],
};

/// Descriptor for `SignedNotice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signedNoticeDescriptor = $convert.base64Decode(
    'CgxTaWduZWROb3RpY2USEgoEYm9keRgBIAEoDFIEYm9keRIcCglzaWduYXR1cmUYAiABKAxSCX'
    'NpZ25hdHVyZQ==');

@$core.Deprecated('Use hqNoticeDescriptor instead')
const HqNotice$json = {
  '1': 'HqNotice',
  '2': [
    {'1': 'notice_id', '3': 1, '4': 1, '5': 9, '10': 'noticeId'},
    {'1': 'issued_at_ms', '3': 2, '4': 1, '5': 3, '10': 'issuedAtMs'},
    {'1': 'expiry_ms', '3': 3, '4': 1, '5': 3, '10': 'expiryMs'},
    {
      '1': 'receipt',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.emergencymesh.DeliveryReceipt',
      '9': 0,
      '10': 'receipt'
    },
    {
      '1': 'alert',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.emergencymesh.HqAlert',
      '9': 0,
      '10': 'alert'
    },
  ],
  '8': [
    {'1': 'kind'},
  ],
};

/// Descriptor for `HqNotice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hqNoticeDescriptor = $convert.base64Decode(
    'CghIcU5vdGljZRIbCglub3RpY2VfaWQYASABKAlSCG5vdGljZUlkEiAKDGlzc3VlZF9hdF9tcx'
    'gCIAEoA1IKaXNzdWVkQXRNcxIbCglleHBpcnlfbXMYAyABKANSCGV4cGlyeU1zEjoKB3JlY2Vp'
    'cHQYCiABKAsyHi5lbWVyZ2VuY3ltZXNoLkRlbGl2ZXJ5UmVjZWlwdEgAUgdyZWNlaXB0Ei4KBW'
    'FsZXJ0GAsgASgLMhYuZW1lcmdlbmN5bWVzaC5IcUFsZXJ0SABSBWFsZXJ0QgYKBGtpbmQ=');

@$core.Deprecated('Use deliveryReceiptDescriptor instead')
const DeliveryReceipt$json = {
  '1': 'DeliveryReceipt',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.emergencymesh.ReceiptStatus',
      '10': 'status'
    },
    {'1': 'team_name', '3': 3, '4': 1, '5': 9, '10': 'teamName'},
  ],
};

/// Descriptor for `DeliveryReceipt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deliveryReceiptDescriptor = $convert.base64Decode(
    'Cg9EZWxpdmVyeVJlY2VpcHQSHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEjQKBnN0YX'
    'R1cxgCIAEoDjIcLmVtZXJnZW5jeW1lc2guUmVjZWlwdFN0YXR1c1IGc3RhdHVzEhsKCXRlYW1f'
    'bmFtZRgDIAEoCVIIdGVhbU5hbWU=');

@$core.Deprecated('Use hqAlertDescriptor instead')
const HqAlert$json = {
  '1': 'HqAlert',
  '2': [
    {
      '1': 'level',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.emergencymesh.AlertLevel',
      '10': 'level'
    },
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'body', '3': 3, '4': 1, '5': 9, '10': 'body'},
  ],
};

/// Descriptor for `HqAlert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List hqAlertDescriptor = $convert.base64Decode(
    'CgdIcUFsZXJ0Ei8KBWxldmVsGAEgASgOMhkuZW1lcmdlbmN5bWVzaC5BbGVydExldmVsUgVsZX'
    'ZlbBIUCgV0aXRsZRgCIAEoCVIFdGl0bGUSEgoEYm9keRgDIAEoCVIEYm9keQ==');
