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

import 'package:protobuf/protobuf.dart' as $pb;

/// FR-1 need types. STATUS is the routine, lowest-priority type (FR-7).
class MessageType extends $pb.ProtobufEnum {
  static const MessageType MESSAGE_TYPE_UNSPECIFIED =
      MessageType._(0, _omitEnumNames ? '' : 'MESSAGE_TYPE_UNSPECIFIED');
  static const MessageType MEDICAL =
      MessageType._(1, _omitEnumNames ? '' : 'MEDICAL');
  static const MessageType TRAPPED =
      MessageType._(2, _omitEnumNames ? '' : 'TRAPPED');
  static const MessageType SUPPLIES =
      MessageType._(3, _omitEnumNames ? '' : 'SUPPLIES');
  static const MessageType STATUS =
      MessageType._(4, _omitEnumNames ? '' : 'STATUS');

  static const $core.List<MessageType> values = <MessageType>[
    MESSAGE_TYPE_UNSPECIFIED,
    MEDICAL,
    TRAPPED,
    SUPPLIES,
    STATUS,
  ];

  static final $core.List<MessageType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static MessageType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MessageType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
