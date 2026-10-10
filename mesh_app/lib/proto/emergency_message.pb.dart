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

/// ---- HQ -> mesh (delivery receipts, broadcast alerts) -----------------------
///
/// Emergency messages still travel as a bare MeshPacket, exactly as before.
/// HQ notices travel wrapped in a MeshFrame. MeshPacket only uses fields 1-7,
/// so a MeshPacket read as a MeshFrame never has `notice` set: a receiver reads
/// every payload as a MeshFrame first and falls back to MeshPacket. Older app
/// versions read a MeshFrame as an empty, invalid MeshPacket and drop it.
class MeshFrame extends $pb.GeneratedMessage {
  factory MeshFrame({
    SignedNotice? notice,
  }) {
    final result = MeshFrame._();
    if (notice != null) result.notice = notice;
    return result;
  }

  MeshFrame._();

  factory MeshFrame.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MeshFrame()..mergeFromBuffer(data, registry);
  factory MeshFrame.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MeshFrame()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeshFrame',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'emergencymesh'),
      createEmptyInstance: MeshFrame.$_createMessage)
    ..aOM<SignedNotice>(101, _omitFieldNames ? '' : 'notice',
        subBuilder: SignedNotice.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeshFrame clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeshFrame copyWith(void Function(MeshFrame) updates) =>
      super.copyWith((message) => updates(message as MeshFrame)) as MeshFrame;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MeshFrame() / MeshFrame.new instead')
  static MeshFrame create() => MeshFrame._();
  static $pb.GeneratedMessage $_createMessage() => MeshFrame._();
  @$core.override
  MeshFrame createEmptyInstance() => MeshFrame._();
  @$core.pragma('dart2js:noInline')
  static MeshFrame getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeshFrame>(MeshFrame.$_createMessage);
  static MeshFrame? _defaultInstance;

  @$pb.TagNumber(101)
  SignedNotice get notice => $_getN(0);
  @$pb.TagNumber(101)
  set notice(SignedNotice value) => $_setField(101, value);
  @$pb.TagNumber(101)
  $core.bool hasNotice() => $_has(0);
  @$pb.TagNumber(101)
  void clearNotice() => $_clearField(101);
  @$pb.TagNumber(101)
  SignedNotice ensureNotice() => $_ensure(0);
}

/// A notice from Headquarters, relayed verbatim. `body` is a serialized
/// HqNotice and `signature` its Ed25519 signature by HQ. Phones verify it
/// against the HQ key baked into the app and drop anything that fails, so no
/// phone can forge a receipt or an alert.
class SignedNotice extends $pb.GeneratedMessage {
  factory SignedNotice({
    $core.List<$core.int>? body,
    $core.List<$core.int>? signature,
  }) {
    final result = SignedNotice._();
    if (body != null) result.body = body;
    if (signature != null) result.signature = signature;
    return result;
  }

  SignedNotice._();

  factory SignedNotice.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignedNotice()..mergeFromBuffer(data, registry);
  factory SignedNotice.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignedNotice()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SignedNotice',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'emergencymesh'),
      createEmptyInstance: SignedNotice.$_createMessage)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'body', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignedNotice clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignedNotice copyWith(void Function(SignedNotice) updates) =>
      super.copyWith((message) => updates(message as SignedNotice))
          as SignedNotice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignedNotice() / SignedNotice.new instead')
  static SignedNotice create() => SignedNotice._();
  static $pb.GeneratedMessage $_createMessage() => SignedNotice._();
  @$core.override
  SignedNotice createEmptyInstance() => SignedNotice._();
  @$core.pragma('dart2js:noInline')
  static SignedNotice getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignedNotice>(
          SignedNotice.$_createMessage);
  static SignedNotice? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get body => $_getN(0);
  @$pb.TagNumber(1)
  set body($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBody() => $_has(0);
  @$pb.TagNumber(1)
  void clearBody() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => $_clearField(2);
}

enum HqNotice_Kind { receipt, alert, notSet }

class HqNotice extends $pb.GeneratedMessage {
  factory HqNotice({
    $core.String? noticeId,
    $fixnum.Int64? issuedAtMs,
    $fixnum.Int64? expiryMs,
    DeliveryReceipt? receipt,
    HqAlert? alert,
  }) {
    final result = HqNotice._();
    if (noticeId != null) result.noticeId = noticeId;
    if (issuedAtMs != null) result.issuedAtMs = issuedAtMs;
    if (expiryMs != null) result.expiryMs = expiryMs;
    if (receipt != null) result.receipt = receipt;
    if (alert != null) result.alert = alert;
    return result;
  }

  HqNotice._();

  factory HqNotice.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HqNotice()..mergeFromBuffer(data, registry);
  factory HqNotice.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HqNotice()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, HqNotice_Kind> _HqNotice_KindByTag = {
    10: HqNotice_Kind.receipt,
    11: HqNotice_Kind.alert,
    0: HqNotice_Kind.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HqNotice',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'emergencymesh'),
      createEmptyInstance: HqNotice.$_createMessage)
    ..oo(0, [10, 11])
    ..aOS(1, _omitFieldNames ? '' : 'noticeId')
    ..aInt64(2, _omitFieldNames ? '' : 'issuedAtMs')
    ..aInt64(3, _omitFieldNames ? '' : 'expiryMs')
    ..aOM<DeliveryReceipt>(10, _omitFieldNames ? '' : 'receipt',
        subBuilder: DeliveryReceipt.$_createMessage)
    ..aOM<HqAlert>(11, _omitFieldNames ? '' : 'alert',
        subBuilder: HqAlert.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HqNotice clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HqNotice copyWith(void Function(HqNotice) updates) =>
      super.copyWith((message) => updates(message as HqNotice)) as HqNotice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HqNotice() / HqNotice.new instead')
  static HqNotice create() => HqNotice._();
  static $pb.GeneratedMessage $_createMessage() => HqNotice._();
  @$core.override
  HqNotice createEmptyInstance() => HqNotice._();
  @$core.pragma('dart2js:noInline')
  static HqNotice getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HqNotice>(HqNotice.$_createMessage);
  static HqNotice? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  HqNotice_Kind whichKind() => _HqNotice_KindByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  void clearKind() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get noticeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set noticeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNoticeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNoticeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get issuedAtMs => $_getI64(1);
  @$pb.TagNumber(2)
  set issuedAtMs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIssuedAtMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearIssuedAtMs() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expiryMs => $_getI64(2);
  @$pb.TagNumber(3)
  set expiryMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiryMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiryMs() => $_clearField(3);

  @$pb.TagNumber(10)
  DeliveryReceipt get receipt => $_getN(3);
  @$pb.TagNumber(10)
  set receipt(DeliveryReceipt value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasReceipt() => $_has(3);
  @$pb.TagNumber(10)
  void clearReceipt() => $_clearField(10);
  @$pb.TagNumber(10)
  DeliveryReceipt ensureReceipt() => $_ensure(3);

  @$pb.TagNumber(11)
  HqAlert get alert => $_getN(4);
  @$pb.TagNumber(11)
  set alert(HqAlert value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasAlert() => $_has(4);
  @$pb.TagNumber(11)
  void clearAlert() => $_clearField(11);
  @$pb.TagNumber(11)
  HqAlert ensureAlert() => $_ensure(4);
}

/// Tells the sender what happened to their message. Relay phones that still
/// carry the message also stop forwarding it: it has arrived.
class DeliveryReceipt extends $pb.GeneratedMessage {
  factory DeliveryReceipt({
    $core.String? messageId,
    ReceiptStatus? status,
    $core.String? teamName,
  }) {
    final result = DeliveryReceipt._();
    if (messageId != null) result.messageId = messageId;
    if (status != null) result.status = status;
    if (teamName != null) result.teamName = teamName;
    return result;
  }

  DeliveryReceipt._();

  factory DeliveryReceipt.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeliveryReceipt()..mergeFromBuffer(data, registry);
  factory DeliveryReceipt.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeliveryReceipt()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeliveryReceipt',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'emergencymesh'),
      createEmptyInstance: DeliveryReceipt.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aE<ReceiptStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: ReceiptStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'teamName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeliveryReceipt clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeliveryReceipt copyWith(void Function(DeliveryReceipt) updates) =>
      super.copyWith((message) => updates(message as DeliveryReceipt))
          as DeliveryReceipt;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeliveryReceipt() / DeliveryReceipt.new instead')
  static DeliveryReceipt create() => DeliveryReceipt._();
  static $pb.GeneratedMessage $_createMessage() => DeliveryReceipt._();
  @$core.override
  DeliveryReceipt createEmptyInstance() => DeliveryReceipt._();
  @$core.pragma('dart2js:noInline')
  static DeliveryReceipt getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeliveryReceipt>(
          DeliveryReceipt.$_createMessage);
  static DeliveryReceipt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  ReceiptStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(ReceiptStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get teamName => $_getSZ(2);
  @$pb.TagNumber(3)
  set teamName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTeamName() => $_has(2);
  @$pb.TagNumber(3)
  void clearTeamName() => $_clearField(3);
}

/// A broadcast from responders to everyone in the mesh.
class HqAlert extends $pb.GeneratedMessage {
  factory HqAlert({
    AlertLevel? level,
    $core.String? title,
    $core.String? body,
  }) {
    final result = HqAlert._();
    if (level != null) result.level = level;
    if (title != null) result.title = title;
    if (body != null) result.body = body;
    return result;
  }

  HqAlert._();

  factory HqAlert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HqAlert()..mergeFromBuffer(data, registry);
  factory HqAlert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HqAlert()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HqAlert',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'emergencymesh'),
      createEmptyInstance: HqAlert.$_createMessage)
    ..aE<AlertLevel>(1, _omitFieldNames ? '' : 'level',
        enumValues: AlertLevel.values)
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'body')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HqAlert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HqAlert copyWith(void Function(HqAlert) updates) =>
      super.copyWith((message) => updates(message as HqAlert)) as HqAlert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HqAlert() / HqAlert.new instead')
  static HqAlert create() => HqAlert._();
  static $pb.GeneratedMessage $_createMessage() => HqAlert._();
  @$core.override
  HqAlert createEmptyInstance() => HqAlert._();
  @$core.pragma('dart2js:noInline')
  static HqAlert getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HqAlert>(HqAlert.$_createMessage);
  static HqAlert? _defaultInstance;

  @$pb.TagNumber(1)
  AlertLevel get level => $_getN(0);
  @$pb.TagNumber(1)
  set level(AlertLevel value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLevel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLevel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get body => $_getSZ(2);
  @$pb.TagNumber(3)
  set body($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBody() => $_has(2);
  @$pb.TagNumber(3)
  void clearBody() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
