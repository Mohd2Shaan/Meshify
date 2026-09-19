// This is a generated file - do not edit.
//
// Generated from emergency_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'emergency_message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'emergency_message.pbenum.dart';

/// The packet that travels phone-to-phone (FR-4).
///
/// Everything here except sealed_payload is routing metadata that relay
/// phones must read to deduplicate (FR-5), expire (FR-6) and prioritise
/// (FR-7). The actual emergency content lives only inside sealed_payload.
class MeshPacket extends $pb.GeneratedMessage {
  factory MeshPacket({
    $core.String? messageId,
    $core.String? senderDeviceId,
    MessageType? type,
    $fixnum.Int64? timestampMs,
    $fixnum.Int64? ttlExpiryMs,
    $core.int? hopCount,
    $core.List<$core.int>? sealedPayload,
  }) {
    final result = MeshPacket._();
    if (messageId != null) result.messageId = messageId;
    if (senderDeviceId != null) result.senderDeviceId = senderDeviceId;
    if (type != null) result.type = type;
    if (timestampMs != null) result.timestampMs = timestampMs;
    if (ttlExpiryMs != null) result.ttlExpiryMs = ttlExpiryMs;
    if (hopCount != null) result.hopCount = hopCount;
    if (sealedPayload != null) result.sealedPayload = sealedPayload;
    return result;
  }

  MeshPacket._();

  factory MeshPacket.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MeshPacket()..mergeFromBuffer(data, registry);
  factory MeshPacket.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MeshPacket()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeshPacket',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'emergencymesh'),
      createEmptyInstance: MeshPacket.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'senderDeviceId')
    ..aE<MessageType>(3, _omitFieldNames ? '' : 'type',
        enumValues: MessageType.values)
    ..aInt64(4, _omitFieldNames ? '' : 'timestampMs')
    ..aInt64(5, _omitFieldNames ? '' : 'ttlExpiryMs')
    ..aI(6, _omitFieldNames ? '' : 'hopCount')
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'sealedPayload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeshPacket clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeshPacket copyWith(void Function(MeshPacket) updates) =>
      super.copyWith((message) => updates(message as MeshPacket)) as MeshPacket;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MeshPacket() / MeshPacket.new instead')
  static MeshPacket create() => MeshPacket._();
  static $pb.GeneratedMessage $_createMessage() => MeshPacket._();
  @$core.override
  MeshPacket createEmptyInstance() => MeshPacket._();
  @$core.pragma('dart2js:noInline')
  static MeshPacket getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeshPacket>(MeshPacket.$_createMessage);
  static MeshPacket? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get senderDeviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set senderDeviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSenderDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSenderDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  MessageType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(MessageType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get timestampMs => $_getI64(3);
  @$pb.TagNumber(4)
  set timestampMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestampMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestampMs() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get ttlExpiryMs => $_getI64(4);
  @$pb.TagNumber(5)
  set ttlExpiryMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTtlExpiryMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearTtlExpiryMs() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get hopCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set hopCount($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHopCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearHopCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get sealedPayload => $_getN(6);
  @$pb.TagNumber(7)
  set sealedPayload($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSealedPayload() => $_has(6);
  @$pb.TagNumber(7)
  void clearSealedPayload() => $_clearField(7);
}

/// The private content, encrypted so only Headquarters can read it (FR-3).
class EmergencyPayload extends $pb.GeneratedMessage {
  factory EmergencyPayload({
    $core.double? latitude,
    $core.double? longitude,
    $core.String? note,
  }) {
    final result = EmergencyPayload._();
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (note != null) result.note = note;
    return result;
  }

  EmergencyPayload._();

  factory EmergencyPayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EmergencyPayload()..mergeFromBuffer(data, registry);
  factory EmergencyPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EmergencyPayload()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EmergencyPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'emergencymesh'),
      createEmptyInstance: EmergencyPayload.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'latitude')
    ..aD(2, _omitFieldNames ? '' : 'longitude')
    ..aOS(3, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EmergencyPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EmergencyPayload copyWith(void Function(EmergencyPayload) updates) =>
      super.copyWith((message) => updates(message as EmergencyPayload))
          as EmergencyPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EmergencyPayload() / EmergencyPayload.new instead')
  static EmergencyPayload create() => EmergencyPayload._();
  static $pb.GeneratedMessage $_createMessage() => EmergencyPayload._();
  @$core.override
  EmergencyPayload createEmptyInstance() => EmergencyPayload._();
  @$core.pragma('dart2js:noInline')
  static EmergencyPayload getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EmergencyPayload>(
          EmergencyPayload.$_createMessage);
  static EmergencyPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get note => $_getSZ(2);
  @$pb.TagNumber(3)
  set note($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNote() => $_has(2);
  @$pb.TagNumber(3)
  void clearNote() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
