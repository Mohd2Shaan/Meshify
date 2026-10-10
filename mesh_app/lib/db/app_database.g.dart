// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, StoredMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderDeviceIdMeta = const VerificationMeta(
    'senderDeviceId',
  );
  @override
  late final GeneratedColumn<String> senderDeviceId = GeneratedColumn<String>(
    'sender_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<NeedType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<NeedType>($MessagesTable.$convertertype);
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ttlExpiryMeta = const VerificationMeta(
    'ttlExpiry',
  );
  @override
  late final GeneratedColumn<DateTime> ttlExpiry = GeneratedColumn<DateTime>(
    'ttl_expiry',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hopCountMeta = const VerificationMeta(
    'hopCount',
  );
  @override
  late final GeneratedColumn<int> hopCount = GeneratedColumn<int>(
    'hop_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityScoreMeta = const VerificationMeta(
    'priorityScore',
  );
  @override
  late final GeneratedColumn<double> priorityScore = GeneratedColumn<double>(
    'priority_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MessageStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MessageStatus>($MessagesTable.$converterstatus);
  static const VerificationMeta _sealedPayloadMeta = const VerificationMeta(
    'sealedPayload',
  );
  @override
  late final GeneratedColumn<Uint8List> sealedPayload =
      GeneratedColumn<Uint8List>(
        'sealed_payload',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageId,
    senderDeviceId,
    type,
    latitude,
    longitude,
    note,
    timestamp,
    ttlExpiry,
    hopCount,
    priorityScore,
    status,
    sealedPayload,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('sender_device_id')) {
      context.handle(
        _senderDeviceIdMeta,
        senderDeviceId.isAcceptableOrUnknown(
          data['sender_device_id']!,
          _senderDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderDeviceIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('ttl_expiry')) {
      context.handle(
        _ttlExpiryMeta,
        ttlExpiry.isAcceptableOrUnknown(data['ttl_expiry']!, _ttlExpiryMeta),
      );
    } else if (isInserting) {
      context.missing(_ttlExpiryMeta);
    }
    if (data.containsKey('hop_count')) {
      context.handle(
        _hopCountMeta,
        hopCount.isAcceptableOrUnknown(data['hop_count']!, _hopCountMeta),
      );
    } else if (isInserting) {
      context.missing(_hopCountMeta);
    }
    if (data.containsKey('priority_score')) {
      context.handle(
        _priorityScoreMeta,
        priorityScore.isAcceptableOrUnknown(
          data['priority_score']!,
          _priorityScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_priorityScoreMeta);
    }
    if (data.containsKey('sealed_payload')) {
      context.handle(
        _sealedPayloadMeta,
        sealedPayload.isAcceptableOrUnknown(
          data['sealed_payload']!,
          _sealedPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sealedPayloadMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  StoredMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredMessage(
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      senderDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_device_id'],
      )!,
      type: $MessagesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      ttlExpiry: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ttl_expiry'],
      )!,
      hopCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hop_count'],
      )!,
      priorityScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}priority_score'],
      )!,
      status: $MessagesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      sealedPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}sealed_payload'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NeedType, String, String> $convertertype =
      const EnumNameConverter<NeedType>(NeedType.values);
  static JsonTypeConverter2<MessageStatus, String, String> $converterstatus =
      const EnumNameConverter<MessageStatus>(MessageStatus.values);
}

class StoredMessage extends DataClass implements Insertable<StoredMessage> {
  final String messageId;
  final String senderDeviceId;
  final NeedType type;
  final double? latitude;
  final double? longitude;
  final String? note;
  final DateTime timestamp;
  final DateTime ttlExpiry;
  final int hopCount;
  final double priorityScore;
  final MessageStatus status;
  final Uint8List sealedPayload;
  final DateTime receivedAt;
  const StoredMessage({
    required this.messageId,
    required this.senderDeviceId,
    required this.type,
    this.latitude,
    this.longitude,
    this.note,
    required this.timestamp,
    required this.ttlExpiry,
    required this.hopCount,
    required this.priorityScore,
    required this.status,
    required this.sealedPayload,
    required this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['sender_device_id'] = Variable<String>(senderDeviceId);
    {
      map['type'] = Variable<String>($MessagesTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['ttl_expiry'] = Variable<DateTime>(ttlExpiry);
    map['hop_count'] = Variable<int>(hopCount);
    map['priority_score'] = Variable<double>(priorityScore);
    {
      map['status'] = Variable<String>(
        $MessagesTable.$converterstatus.toSql(status),
      );
    }
    map['sealed_payload'] = Variable<Uint8List>(sealedPayload);
    map['received_at'] = Variable<DateTime>(receivedAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      messageId: Value(messageId),
      senderDeviceId: Value(senderDeviceId),
      type: Value(type),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      timestamp: Value(timestamp),
      ttlExpiry: Value(ttlExpiry),
      hopCount: Value(hopCount),
      priorityScore: Value(priorityScore),
      status: Value(status),
      sealedPayload: Value(sealedPayload),
      receivedAt: Value(receivedAt),
    );
  }

  factory StoredMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredMessage(
      messageId: serializer.fromJson<String>(json['messageId']),
      senderDeviceId: serializer.fromJson<String>(json['senderDeviceId']),
      type: $MessagesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      note: serializer.fromJson<String?>(json['note']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      ttlExpiry: serializer.fromJson<DateTime>(json['ttlExpiry']),
      hopCount: serializer.fromJson<int>(json['hopCount']),
      priorityScore: serializer.fromJson<double>(json['priorityScore']),
      status: $MessagesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      sealedPayload: serializer.fromJson<Uint8List>(json['sealedPayload']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'senderDeviceId': serializer.toJson<String>(senderDeviceId),
      'type': serializer.toJson<String>(
        $MessagesTable.$convertertype.toJson(type),
      ),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'note': serializer.toJson<String?>(note),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'ttlExpiry': serializer.toJson<DateTime>(ttlExpiry),
      'hopCount': serializer.toJson<int>(hopCount),
      'priorityScore': serializer.toJson<double>(priorityScore),
      'status': serializer.toJson<String>(
        $MessagesTable.$converterstatus.toJson(status),
      ),
      'sealedPayload': serializer.toJson<Uint8List>(sealedPayload),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
    };
  }

  StoredMessage copyWith({
    String? messageId,
    String? senderDeviceId,
    NeedType? type,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? timestamp,
    DateTime? ttlExpiry,
    int? hopCount,
    double? priorityScore,
    MessageStatus? status,
    Uint8List? sealedPayload,
    DateTime? receivedAt,
  }) => StoredMessage(
    messageId: messageId ?? this.messageId,
    senderDeviceId: senderDeviceId ?? this.senderDeviceId,
    type: type ?? this.type,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    note: note.present ? note.value : this.note,
    timestamp: timestamp ?? this.timestamp,
    ttlExpiry: ttlExpiry ?? this.ttlExpiry,
    hopCount: hopCount ?? this.hopCount,
    priorityScore: priorityScore ?? this.priorityScore,
    status: status ?? this.status,
    sealedPayload: sealedPayload ?? this.sealedPayload,
    receivedAt: receivedAt ?? this.receivedAt,
  );
  StoredMessage copyWithCompanion(MessagesCompanion data) {
    return StoredMessage(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      senderDeviceId: data.senderDeviceId.present
          ? data.senderDeviceId.value
          : this.senderDeviceId,
      type: data.type.present ? data.type.value : this.type,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      note: data.note.present ? data.note.value : this.note,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      ttlExpiry: data.ttlExpiry.present ? data.ttlExpiry.value : this.ttlExpiry,
      hopCount: data.hopCount.present ? data.hopCount.value : this.hopCount,
      priorityScore: data.priorityScore.present
          ? data.priorityScore.value
          : this.priorityScore,
      status: data.status.present ? data.status.value : this.status,
      sealedPayload: data.sealedPayload.present
          ? data.sealedPayload.value
          : this.sealedPayload,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredMessage(')
          ..write('messageId: $messageId, ')
          ..write('senderDeviceId: $senderDeviceId, ')
          ..write('type: $type, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('note: $note, ')
          ..write('timestamp: $timestamp, ')
          ..write('ttlExpiry: $ttlExpiry, ')
          ..write('hopCount: $hopCount, ')
          ..write('priorityScore: $priorityScore, ')
          ..write('status: $status, ')
          ..write('sealedPayload: $sealedPayload, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    messageId,
    senderDeviceId,
    type,
    latitude,
    longitude,
    note,
    timestamp,
    ttlExpiry,
    hopCount,
    priorityScore,
    status,
    $driftBlobEquality.hash(sealedPayload),
    receivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredMessage &&
          other.messageId == this.messageId &&
          other.senderDeviceId == this.senderDeviceId &&
          other.type == this.type &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.note == this.note &&
          other.timestamp == this.timestamp &&
          other.ttlExpiry == this.ttlExpiry &&
          other.hopCount == this.hopCount &&
          other.priorityScore == this.priorityScore &&
          other.status == this.status &&
          $driftBlobEquality.equals(other.sealedPayload, this.sealedPayload) &&
          other.receivedAt == this.receivedAt);
}

class MessagesCompanion extends UpdateCompanion<StoredMessage> {
  final Value<String> messageId;
  final Value<String> senderDeviceId;
  final Value<NeedType> type;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> note;
  final Value<DateTime> timestamp;
  final Value<DateTime> ttlExpiry;
  final Value<int> hopCount;
  final Value<double> priorityScore;
  final Value<MessageStatus> status;
  final Value<Uint8List> sealedPayload;
  final Value<DateTime> receivedAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.messageId = const Value.absent(),
    this.senderDeviceId = const Value.absent(),
    this.type = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.note = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.ttlExpiry = const Value.absent(),
    this.hopCount = const Value.absent(),
    this.priorityScore = const Value.absent(),
    this.status = const Value.absent(),
    this.sealedPayload = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String messageId,
    required String senderDeviceId,
    required NeedType type,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime timestamp,
    required DateTime ttlExpiry,
    required int hopCount,
    required double priorityScore,
    required MessageStatus status,
    required Uint8List sealedPayload,
    required DateTime receivedAt,
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       senderDeviceId = Value(senderDeviceId),
       type = Value(type),
       timestamp = Value(timestamp),
       ttlExpiry = Value(ttlExpiry),
       hopCount = Value(hopCount),
       priorityScore = Value(priorityScore),
       status = Value(status),
       sealedPayload = Value(sealedPayload),
       receivedAt = Value(receivedAt);
  static Insertable<StoredMessage> custom({
    Expression<String>? messageId,
    Expression<String>? senderDeviceId,
    Expression<String>? type,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? note,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? ttlExpiry,
    Expression<int>? hopCount,
    Expression<double>? priorityScore,
    Expression<String>? status,
    Expression<Uint8List>? sealedPayload,
    Expression<DateTime>? receivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (senderDeviceId != null) 'sender_device_id': senderDeviceId,
      if (type != null) 'type': type,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (note != null) 'note': note,
      if (timestamp != null) 'timestamp': timestamp,
      if (ttlExpiry != null) 'ttl_expiry': ttlExpiry,
      if (hopCount != null) 'hop_count': hopCount,
      if (priorityScore != null) 'priority_score': priorityScore,
      if (status != null) 'status': status,
      if (sealedPayload != null) 'sealed_payload': sealedPayload,
      if (receivedAt != null) 'received_at': receivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? messageId,
    Value<String>? senderDeviceId,
    Value<NeedType>? type,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? note,
    Value<DateTime>? timestamp,
    Value<DateTime>? ttlExpiry,
    Value<int>? hopCount,
    Value<double>? priorityScore,
    Value<MessageStatus>? status,
    Value<Uint8List>? sealedPayload,
    Value<DateTime>? receivedAt,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      messageId: messageId ?? this.messageId,
      senderDeviceId: senderDeviceId ?? this.senderDeviceId,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      ttlExpiry: ttlExpiry ?? this.ttlExpiry,
      hopCount: hopCount ?? this.hopCount,
      priorityScore: priorityScore ?? this.priorityScore,
      status: status ?? this.status,
      sealedPayload: sealedPayload ?? this.sealedPayload,
      receivedAt: receivedAt ?? this.receivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (senderDeviceId.present) {
      map['sender_device_id'] = Variable<String>(senderDeviceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $MessagesTable.$convertertype.toSql(type.value),
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (ttlExpiry.present) {
      map['ttl_expiry'] = Variable<DateTime>(ttlExpiry.value);
    }
    if (hopCount.present) {
      map['hop_count'] = Variable<int>(hopCount.value);
    }
    if (priorityScore.present) {
      map['priority_score'] = Variable<double>(priorityScore.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $MessagesTable.$converterstatus.toSql(status.value),
      );
    }
    if (sealedPayload.present) {
      map['sealed_payload'] = Variable<Uint8List>(sealedPayload.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('messageId: $messageId, ')
          ..write('senderDeviceId: $senderDeviceId, ')
          ..write('type: $type, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('note: $note, ')
          ..write('timestamp: $timestamp, ')
          ..write('ttlExpiry: $ttlExpiry, ')
          ..write('hopCount: $hopCount, ')
          ..write('priorityScore: $priorityScore, ')
          ..write('status: $status, ')
          ..write('sealedPayload: $sealedPayload, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelayLogTable extends RelayLog
    with TableInfo<$RelayLogTable, RelayLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelayLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _relayIdMeta = const VerificationMeta(
    'relayId',
  );
  @override
  late final GeneratedColumn<String> relayId = GeneratedColumn<String>(
    'relay_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relayDeviceIdMeta = const VerificationMeta(
    'relayDeviceId',
  );
  @override
  late final GeneratedColumn<String> relayDeviceId = GeneratedColumn<String>(
    'relay_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RelayDirection, String>
  direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<RelayDirection>($RelayLogTable.$converterdirection);
  static const VerificationMeta _relayTimestampMeta = const VerificationMeta(
    'relayTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> relayTimestamp =
      GeneratedColumn<DateTime>(
        'relay_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    relayId,
    messageId,
    relayDeviceId,
    direction,
    relayTimestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relay_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<RelayLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('relay_id')) {
      context.handle(
        _relayIdMeta,
        relayId.isAcceptableOrUnknown(data['relay_id']!, _relayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_relayIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('relay_device_id')) {
      context.handle(
        _relayDeviceIdMeta,
        relayDeviceId.isAcceptableOrUnknown(
          data['relay_device_id']!,
          _relayDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relayDeviceIdMeta);
    }
    if (data.containsKey('relay_timestamp')) {
      context.handle(
        _relayTimestampMeta,
        relayTimestamp.isAcceptableOrUnknown(
          data['relay_timestamp']!,
          _relayTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relayTimestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {relayId};
  @override
  RelayLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelayLogEntry(
      relayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relay_id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      relayDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relay_device_id'],
      )!,
      direction: $RelayLogTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      relayTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}relay_timestamp'],
      )!,
    );
  }

  @override
  $RelayLogTable createAlias(String alias) {
    return $RelayLogTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RelayDirection, String, String>
  $converterdirection = const EnumNameConverter<RelayDirection>(
    RelayDirection.values,
  );
}

class RelayLogEntry extends DataClass implements Insertable<RelayLogEntry> {
  final String relayId;
  final String messageId;
  final String relayDeviceId;
  final RelayDirection direction;
  final DateTime relayTimestamp;
  const RelayLogEntry({
    required this.relayId,
    required this.messageId,
    required this.relayDeviceId,
    required this.direction,
    required this.relayTimestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['relay_id'] = Variable<String>(relayId);
    map['message_id'] = Variable<String>(messageId);
    map['relay_device_id'] = Variable<String>(relayDeviceId);
    {
      map['direction'] = Variable<String>(
        $RelayLogTable.$converterdirection.toSql(direction),
      );
    }
    map['relay_timestamp'] = Variable<DateTime>(relayTimestamp);
    return map;
  }

  RelayLogCompanion toCompanion(bool nullToAbsent) {
    return RelayLogCompanion(
      relayId: Value(relayId),
      messageId: Value(messageId),
      relayDeviceId: Value(relayDeviceId),
      direction: Value(direction),
      relayTimestamp: Value(relayTimestamp),
    );
  }

  factory RelayLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelayLogEntry(
      relayId: serializer.fromJson<String>(json['relayId']),
      messageId: serializer.fromJson<String>(json['messageId']),
      relayDeviceId: serializer.fromJson<String>(json['relayDeviceId']),
      direction: $RelayLogTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      relayTimestamp: serializer.fromJson<DateTime>(json['relayTimestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'relayId': serializer.toJson<String>(relayId),
      'messageId': serializer.toJson<String>(messageId),
      'relayDeviceId': serializer.toJson<String>(relayDeviceId),
      'direction': serializer.toJson<String>(
        $RelayLogTable.$converterdirection.toJson(direction),
      ),
      'relayTimestamp': serializer.toJson<DateTime>(relayTimestamp),
    };
  }

  RelayLogEntry copyWith({
    String? relayId,
    String? messageId,
    String? relayDeviceId,
    RelayDirection? direction,
    DateTime? relayTimestamp,
  }) => RelayLogEntry(
    relayId: relayId ?? this.relayId,
    messageId: messageId ?? this.messageId,
    relayDeviceId: relayDeviceId ?? this.relayDeviceId,
    direction: direction ?? this.direction,
    relayTimestamp: relayTimestamp ?? this.relayTimestamp,
  );
  RelayLogEntry copyWithCompanion(RelayLogCompanion data) {
    return RelayLogEntry(
      relayId: data.relayId.present ? data.relayId.value : this.relayId,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      relayDeviceId: data.relayDeviceId.present
          ? data.relayDeviceId.value
          : this.relayDeviceId,
      direction: data.direction.present ? data.direction.value : this.direction,
      relayTimestamp: data.relayTimestamp.present
          ? data.relayTimestamp.value
          : this.relayTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelayLogEntry(')
          ..write('relayId: $relayId, ')
          ..write('messageId: $messageId, ')
          ..write('relayDeviceId: $relayDeviceId, ')
          ..write('direction: $direction, ')
          ..write('relayTimestamp: $relayTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(relayId, messageId, relayDeviceId, direction, relayTimestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelayLogEntry &&
          other.relayId == this.relayId &&
          other.messageId == this.messageId &&
          other.relayDeviceId == this.relayDeviceId &&
          other.direction == this.direction &&
          other.relayTimestamp == this.relayTimestamp);
}

class RelayLogCompanion extends UpdateCompanion<RelayLogEntry> {
  final Value<String> relayId;
  final Value<String> messageId;
  final Value<String> relayDeviceId;
  final Value<RelayDirection> direction;
  final Value<DateTime> relayTimestamp;
  final Value<int> rowid;
  const RelayLogCompanion({
    this.relayId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.relayDeviceId = const Value.absent(),
    this.direction = const Value.absent(),
    this.relayTimestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelayLogCompanion.insert({
    required String relayId,
    required String messageId,
    required String relayDeviceId,
    required RelayDirection direction,
    required DateTime relayTimestamp,
    this.rowid = const Value.absent(),
  }) : relayId = Value(relayId),
       messageId = Value(messageId),
       relayDeviceId = Value(relayDeviceId),
       direction = Value(direction),
       relayTimestamp = Value(relayTimestamp);
  static Insertable<RelayLogEntry> custom({
    Expression<String>? relayId,
    Expression<String>? messageId,
    Expression<String>? relayDeviceId,
    Expression<String>? direction,
    Expression<DateTime>? relayTimestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (relayId != null) 'relay_id': relayId,
      if (messageId != null) 'message_id': messageId,
      if (relayDeviceId != null) 'relay_device_id': relayDeviceId,
      if (direction != null) 'direction': direction,
      if (relayTimestamp != null) 'relay_timestamp': relayTimestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelayLogCompanion copyWith({
    Value<String>? relayId,
    Value<String>? messageId,
    Value<String>? relayDeviceId,
    Value<RelayDirection>? direction,
    Value<DateTime>? relayTimestamp,
    Value<int>? rowid,
  }) {
    return RelayLogCompanion(
      relayId: relayId ?? this.relayId,
      messageId: messageId ?? this.messageId,
      relayDeviceId: relayDeviceId ?? this.relayDeviceId,
      direction: direction ?? this.direction,
      relayTimestamp: relayTimestamp ?? this.relayTimestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (relayId.present) {
      map['relay_id'] = Variable<String>(relayId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (relayDeviceId.present) {
      map['relay_device_id'] = Variable<String>(relayDeviceId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $RelayLogTable.$converterdirection.toSql(direction.value),
      );
    }
    if (relayTimestamp.present) {
      map['relay_timestamp'] = Variable<DateTime>(relayTimestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelayLogCompanion(')
          ..write('relayId: $relayId, ')
          ..write('messageId: $messageId, ')
          ..write('relayDeviceId: $relayDeviceId, ')
          ..write('direction: $direction, ')
          ..write('relayTimestamp: $relayTimestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GatewayUploadsTable extends GatewayUploads
    with TableInfo<$GatewayUploadsTable, GatewayUploadEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GatewayUploadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uploadIdMeta = const VerificationMeta(
    'uploadId',
  );
  @override
  late final GeneratedColumn<String> uploadId = GeneratedColumn<String>(
    'upload_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gatewayDeviceIdMeta = const VerificationMeta(
    'gatewayDeviceId',
  );
  @override
  late final GeneratedColumn<String> gatewayDeviceId = GeneratedColumn<String>(
    'gateway_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadTimestampMeta = const VerificationMeta(
    'uploadTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> uploadTimestamp =
      GeneratedColumn<DateTime>(
        'upload_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _backendAckStatusMeta = const VerificationMeta(
    'backendAckStatus',
  );
  @override
  late final GeneratedColumn<String> backendAckStatus = GeneratedColumn<String>(
    'backend_ack_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uploadId,
    messageId,
    gatewayDeviceId,
    uploadTimestamp,
    backendAckStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gateway_uploads';
  @override
  VerificationContext validateIntegrity(
    Insertable<GatewayUploadEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('upload_id')) {
      context.handle(
        _uploadIdMeta,
        uploadId.isAcceptableOrUnknown(data['upload_id']!, _uploadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_uploadIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('gateway_device_id')) {
      context.handle(
        _gatewayDeviceIdMeta,
        gatewayDeviceId.isAcceptableOrUnknown(
          data['gateway_device_id']!,
          _gatewayDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gatewayDeviceIdMeta);
    }
    if (data.containsKey('upload_timestamp')) {
      context.handle(
        _uploadTimestampMeta,
        uploadTimestamp.isAcceptableOrUnknown(
          data['upload_timestamp']!,
          _uploadTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uploadTimestampMeta);
    }
    if (data.containsKey('backend_ack_status')) {
      context.handle(
        _backendAckStatusMeta,
        backendAckStatus.isAcceptableOrUnknown(
          data['backend_ack_status']!,
          _backendAckStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_backendAckStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uploadId};
  @override
  GatewayUploadEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GatewayUploadEntry(
      uploadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      gatewayDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gateway_device_id'],
      )!,
      uploadTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}upload_timestamp'],
      )!,
      backendAckStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backend_ack_status'],
      )!,
    );
  }

  @override
  $GatewayUploadsTable createAlias(String alias) {
    return $GatewayUploadsTable(attachedDatabase, alias);
  }
}

class GatewayUploadEntry extends DataClass
    implements Insertable<GatewayUploadEntry> {
  final String uploadId;
  final String messageId;
  final String gatewayDeviceId;
  final DateTime uploadTimestamp;
  final String backendAckStatus;
  const GatewayUploadEntry({
    required this.uploadId,
    required this.messageId,
    required this.gatewayDeviceId,
    required this.uploadTimestamp,
    required this.backendAckStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['upload_id'] = Variable<String>(uploadId);
    map['message_id'] = Variable<String>(messageId);
    map['gateway_device_id'] = Variable<String>(gatewayDeviceId);
    map['upload_timestamp'] = Variable<DateTime>(uploadTimestamp);
    map['backend_ack_status'] = Variable<String>(backendAckStatus);
    return map;
  }

  GatewayUploadsCompanion toCompanion(bool nullToAbsent) {
    return GatewayUploadsCompanion(
      uploadId: Value(uploadId),
      messageId: Value(messageId),
      gatewayDeviceId: Value(gatewayDeviceId),
      uploadTimestamp: Value(uploadTimestamp),
      backendAckStatus: Value(backendAckStatus),
    );
  }

  factory GatewayUploadEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GatewayUploadEntry(
      uploadId: serializer.fromJson<String>(json['uploadId']),
      messageId: serializer.fromJson<String>(json['messageId']),
      gatewayDeviceId: serializer.fromJson<String>(json['gatewayDeviceId']),
      uploadTimestamp: serializer.fromJson<DateTime>(json['uploadTimestamp']),
      backendAckStatus: serializer.fromJson<String>(json['backendAckStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uploadId': serializer.toJson<String>(uploadId),
      'messageId': serializer.toJson<String>(messageId),
      'gatewayDeviceId': serializer.toJson<String>(gatewayDeviceId),
      'uploadTimestamp': serializer.toJson<DateTime>(uploadTimestamp),
      'backendAckStatus': serializer.toJson<String>(backendAckStatus),
    };
  }

  GatewayUploadEntry copyWith({
    String? uploadId,
    String? messageId,
    String? gatewayDeviceId,
    DateTime? uploadTimestamp,
    String? backendAckStatus,
  }) => GatewayUploadEntry(
    uploadId: uploadId ?? this.uploadId,
    messageId: messageId ?? this.messageId,
    gatewayDeviceId: gatewayDeviceId ?? this.gatewayDeviceId,
    uploadTimestamp: uploadTimestamp ?? this.uploadTimestamp,
    backendAckStatus: backendAckStatus ?? this.backendAckStatus,
  );
  GatewayUploadEntry copyWithCompanion(GatewayUploadsCompanion data) {
    return GatewayUploadEntry(
      uploadId: data.uploadId.present ? data.uploadId.value : this.uploadId,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      gatewayDeviceId: data.gatewayDeviceId.present
          ? data.gatewayDeviceId.value
          : this.gatewayDeviceId,
      uploadTimestamp: data.uploadTimestamp.present
          ? data.uploadTimestamp.value
          : this.uploadTimestamp,
      backendAckStatus: data.backendAckStatus.present
          ? data.backendAckStatus.value
          : this.backendAckStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GatewayUploadEntry(')
          ..write('uploadId: $uploadId, ')
          ..write('messageId: $messageId, ')
          ..write('gatewayDeviceId: $gatewayDeviceId, ')
          ..write('uploadTimestamp: $uploadTimestamp, ')
          ..write('backendAckStatus: $backendAckStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uploadId,
    messageId,
    gatewayDeviceId,
    uploadTimestamp,
    backendAckStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GatewayUploadEntry &&
          other.uploadId == this.uploadId &&
          other.messageId == this.messageId &&
          other.gatewayDeviceId == this.gatewayDeviceId &&
          other.uploadTimestamp == this.uploadTimestamp &&
          other.backendAckStatus == this.backendAckStatus);
}

class GatewayUploadsCompanion extends UpdateCompanion<GatewayUploadEntry> {
  final Value<String> uploadId;
  final Value<String> messageId;
  final Value<String> gatewayDeviceId;
  final Value<DateTime> uploadTimestamp;
  final Value<String> backendAckStatus;
  final Value<int> rowid;
  const GatewayUploadsCompanion({
    this.uploadId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.gatewayDeviceId = const Value.absent(),
    this.uploadTimestamp = const Value.absent(),
    this.backendAckStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GatewayUploadsCompanion.insert({
    required String uploadId,
    required String messageId,
    required String gatewayDeviceId,
    required DateTime uploadTimestamp,
    required String backendAckStatus,
    this.rowid = const Value.absent(),
  }) : uploadId = Value(uploadId),
       messageId = Value(messageId),
       gatewayDeviceId = Value(gatewayDeviceId),
       uploadTimestamp = Value(uploadTimestamp),
       backendAckStatus = Value(backendAckStatus);
  static Insertable<GatewayUploadEntry> custom({
    Expression<String>? uploadId,
    Expression<String>? messageId,
    Expression<String>? gatewayDeviceId,
    Expression<DateTime>? uploadTimestamp,
    Expression<String>? backendAckStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uploadId != null) 'upload_id': uploadId,
      if (messageId != null) 'message_id': messageId,
      if (gatewayDeviceId != null) 'gateway_device_id': gatewayDeviceId,
      if (uploadTimestamp != null) 'upload_timestamp': uploadTimestamp,
      if (backendAckStatus != null) 'backend_ack_status': backendAckStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GatewayUploadsCompanion copyWith({
    Value<String>? uploadId,
    Value<String>? messageId,
    Value<String>? gatewayDeviceId,
    Value<DateTime>? uploadTimestamp,
    Value<String>? backendAckStatus,
    Value<int>? rowid,
  }) {
    return GatewayUploadsCompanion(
      uploadId: uploadId ?? this.uploadId,
      messageId: messageId ?? this.messageId,
      gatewayDeviceId: gatewayDeviceId ?? this.gatewayDeviceId,
      uploadTimestamp: uploadTimestamp ?? this.uploadTimestamp,
      backendAckStatus: backendAckStatus ?? this.backendAckStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uploadId.present) {
      map['upload_id'] = Variable<String>(uploadId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (gatewayDeviceId.present) {
      map['gateway_device_id'] = Variable<String>(gatewayDeviceId.value);
    }
    if (uploadTimestamp.present) {
      map['upload_timestamp'] = Variable<DateTime>(uploadTimestamp.value);
    }
    if (backendAckStatus.present) {
      map['backend_ack_status'] = Variable<String>(backendAckStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GatewayUploadsCompanion(')
          ..write('uploadId: $uploadId, ')
          ..write('messageId: $messageId, ')
          ..write('gatewayDeviceId: $gatewayDeviceId, ')
          ..write('uploadTimestamp: $uploadTimestamp, ')
          ..write('backendAckStatus: $backendAckStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoticesTable extends Notices
    with TableInfo<$NoticesTable, StoredNotice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoticesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noticeIdMeta = const VerificationMeta(
    'noticeId',
  );
  @override
  late final GeneratedColumn<String> noticeId = GeneratedColumn<String>(
    'notice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<NoticeKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<NoticeKind>($NoticesTable.$converterkind);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReceiptState?, String>
  receiptState = GeneratedColumn<String>(
    'receipt_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<ReceiptState?>($NoticesTable.$converterreceiptStaten);
  static const VerificationMeta _teamNameMeta = const VerificationMeta(
    'teamName',
  );
  @override
  late final GeneratedColumn<String> teamName = GeneratedColumn<String>(
    'team_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AlertLevel?, String> alertLevel =
      GeneratedColumn<String>(
        'alert_level',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<AlertLevel?>($NoticesTable.$converteralertLeveln);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
    'issued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryMeta = const VerificationMeta('expiry');
  @override
  late final GeneratedColumn<DateTime> expiry = GeneratedColumn<DateTime>(
    'expiry',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signedBodyMeta = const VerificationMeta(
    'signedBody',
  );
  @override
  late final GeneratedColumn<Uint8List> signedBody = GeneratedColumn<Uint8List>(
    'signed_body',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<Uint8List> signature = GeneratedColumn<Uint8List>(
    'signature',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supersededMeta = const VerificationMeta(
    'superseded',
  );
  @override
  late final GeneratedColumn<bool> superseded = GeneratedColumn<bool>(
    'superseded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("superseded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _seenMeta = const VerificationMeta('seen');
  @override
  late final GeneratedColumn<bool> seen = GeneratedColumn<bool>(
    'seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    noticeId,
    kind,
    messageId,
    receiptState,
    teamName,
    alertLevel,
    title,
    body,
    issuedAt,
    expiry,
    receivedAt,
    signedBody,
    signature,
    superseded,
    seen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notices';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredNotice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('notice_id')) {
      context.handle(
        _noticeIdMeta,
        noticeId.isAcceptableOrUnknown(data['notice_id']!, _noticeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noticeIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    }
    if (data.containsKey('team_name')) {
      context.handle(
        _teamNameMeta,
        teamName.isAcceptableOrUnknown(data['team_name']!, _teamNameMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_issuedAtMeta);
    }
    if (data.containsKey('expiry')) {
      context.handle(
        _expiryMeta,
        expiry.isAcceptableOrUnknown(data['expiry']!, _expiryMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('signed_body')) {
      context.handle(
        _signedBodyMeta,
        signedBody.isAcceptableOrUnknown(data['signed_body']!, _signedBodyMeta),
      );
    } else if (isInserting) {
      context.missing(_signedBodyMeta);
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    } else if (isInserting) {
      context.missing(_signatureMeta);
    }
    if (data.containsKey('superseded')) {
      context.handle(
        _supersededMeta,
        superseded.isAcceptableOrUnknown(data['superseded']!, _supersededMeta),
      );
    }
    if (data.containsKey('seen')) {
      context.handle(
        _seenMeta,
        seen.isAcceptableOrUnknown(data['seen']!, _seenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noticeId};
  @override
  StoredNotice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredNotice(
      noticeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notice_id'],
      )!,
      kind: $NoticesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      ),
      receiptState: $NoticesTable.$converterreceiptStaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}receipt_state'],
        ),
      ),
      teamName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_name'],
      ),
      alertLevel: $NoticesTable.$converteralertLeveln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}alert_level'],
        ),
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issued_at'],
      )!,
      expiry: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      signedBody: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signed_body'],
      )!,
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signature'],
      )!,
      superseded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}superseded'],
      )!,
      seen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}seen'],
      )!,
    );
  }

  @override
  $NoticesTable createAlias(String alias) {
    return $NoticesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NoticeKind, String, String> $converterkind =
      const EnumNameConverter<NoticeKind>(NoticeKind.values);
  static JsonTypeConverter2<ReceiptState, String, String>
  $converterreceiptState = const EnumNameConverter<ReceiptState>(
    ReceiptState.values,
  );
  static JsonTypeConverter2<ReceiptState?, String?, String?>
  $converterreceiptStaten = JsonTypeConverter2.asNullable(
    $converterreceiptState,
  );
  static JsonTypeConverter2<AlertLevel, String, String> $converteralertLevel =
      const EnumNameConverter<AlertLevel>(AlertLevel.values);
  static JsonTypeConverter2<AlertLevel?, String?, String?>
  $converteralertLeveln = JsonTypeConverter2.asNullable($converteralertLevel);
}

class StoredNotice extends DataClass implements Insertable<StoredNotice> {
  final String noticeId;
  final NoticeKind kind;

  /// Receipts: which message, what happened to it, and the team (if any).
  final String? messageId;
  final ReceiptState? receiptState;
  final String? teamName;

  /// Alerts.
  final AlertLevel? alertLevel;
  final String? title;
  final String? body;
  final DateTime issuedAt;
  final DateTime expiry;
  final DateTime receivedAt;
  final Uint8List signedBody;
  final Uint8List signature;

  /// A newer receipt for the same message exists, so this one isn't relayed.
  final bool superseded;

  /// Alerts: the user has opened the Alerts tab since it arrived.
  final bool seen;
  const StoredNotice({
    required this.noticeId,
    required this.kind,
    this.messageId,
    this.receiptState,
    this.teamName,
    this.alertLevel,
    this.title,
    this.body,
    required this.issuedAt,
    required this.expiry,
    required this.receivedAt,
    required this.signedBody,
    required this.signature,
    required this.superseded,
    required this.seen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['notice_id'] = Variable<String>(noticeId);
    {
      map['kind'] = Variable<String>($NoticesTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<String>(messageId);
    }
    if (!nullToAbsent || receiptState != null) {
      map['receipt_state'] = Variable<String>(
        $NoticesTable.$converterreceiptStaten.toSql(receiptState),
      );
    }
    if (!nullToAbsent || teamName != null) {
      map['team_name'] = Variable<String>(teamName);
    }
    if (!nullToAbsent || alertLevel != null) {
      map['alert_level'] = Variable<String>(
        $NoticesTable.$converteralertLeveln.toSql(alertLevel),
      );
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['issued_at'] = Variable<DateTime>(issuedAt);
    map['expiry'] = Variable<DateTime>(expiry);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['signed_body'] = Variable<Uint8List>(signedBody);
    map['signature'] = Variable<Uint8List>(signature);
    map['superseded'] = Variable<bool>(superseded);
    map['seen'] = Variable<bool>(seen);
    return map;
  }

  NoticesCompanion toCompanion(bool nullToAbsent) {
    return NoticesCompanion(
      noticeId: Value(noticeId),
      kind: Value(kind),
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      receiptState: receiptState == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptState),
      teamName: teamName == null && nullToAbsent
          ? const Value.absent()
          : Value(teamName),
      alertLevel: alertLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(alertLevel),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      issuedAt: Value(issuedAt),
      expiry: Value(expiry),
      receivedAt: Value(receivedAt),
      signedBody: Value(signedBody),
      signature: Value(signature),
      superseded: Value(superseded),
      seen: Value(seen),
    );
  }

  factory StoredNotice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredNotice(
      noticeId: serializer.fromJson<String>(json['noticeId']),
      kind: $NoticesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      messageId: serializer.fromJson<String?>(json['messageId']),
      receiptState: $NoticesTable.$converterreceiptStaten.fromJson(
        serializer.fromJson<String?>(json['receiptState']),
      ),
      teamName: serializer.fromJson<String?>(json['teamName']),
      alertLevel: $NoticesTable.$converteralertLeveln.fromJson(
        serializer.fromJson<String?>(json['alertLevel']),
      ),
      title: serializer.fromJson<String?>(json['title']),
      body: serializer.fromJson<String?>(json['body']),
      issuedAt: serializer.fromJson<DateTime>(json['issuedAt']),
      expiry: serializer.fromJson<DateTime>(json['expiry']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      signedBody: serializer.fromJson<Uint8List>(json['signedBody']),
      signature: serializer.fromJson<Uint8List>(json['signature']),
      superseded: serializer.fromJson<bool>(json['superseded']),
      seen: serializer.fromJson<bool>(json['seen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noticeId': serializer.toJson<String>(noticeId),
      'kind': serializer.toJson<String>(
        $NoticesTable.$converterkind.toJson(kind),
      ),
      'messageId': serializer.toJson<String?>(messageId),
      'receiptState': serializer.toJson<String?>(
        $NoticesTable.$converterreceiptStaten.toJson(receiptState),
      ),
      'teamName': serializer.toJson<String?>(teamName),
      'alertLevel': serializer.toJson<String?>(
        $NoticesTable.$converteralertLeveln.toJson(alertLevel),
      ),
      'title': serializer.toJson<String?>(title),
      'body': serializer.toJson<String?>(body),
      'issuedAt': serializer.toJson<DateTime>(issuedAt),
      'expiry': serializer.toJson<DateTime>(expiry),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'signedBody': serializer.toJson<Uint8List>(signedBody),
      'signature': serializer.toJson<Uint8List>(signature),
      'superseded': serializer.toJson<bool>(superseded),
      'seen': serializer.toJson<bool>(seen),
    };
  }

  StoredNotice copyWith({
    String? noticeId,
    NoticeKind? kind,
    Value<String?> messageId = const Value.absent(),
    Value<ReceiptState?> receiptState = const Value.absent(),
    Value<String?> teamName = const Value.absent(),
    Value<AlertLevel?> alertLevel = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> body = const Value.absent(),
    DateTime? issuedAt,
    DateTime? expiry,
    DateTime? receivedAt,
    Uint8List? signedBody,
    Uint8List? signature,
    bool? superseded,
    bool? seen,
  }) => StoredNotice(
    noticeId: noticeId ?? this.noticeId,
    kind: kind ?? this.kind,
    messageId: messageId.present ? messageId.value : this.messageId,
    receiptState: receiptState.present ? receiptState.value : this.receiptState,
    teamName: teamName.present ? teamName.value : this.teamName,
    alertLevel: alertLevel.present ? alertLevel.value : this.alertLevel,
    title: title.present ? title.value : this.title,
    body: body.present ? body.value : this.body,
    issuedAt: issuedAt ?? this.issuedAt,
    expiry: expiry ?? this.expiry,
    receivedAt: receivedAt ?? this.receivedAt,
    signedBody: signedBody ?? this.signedBody,
    signature: signature ?? this.signature,
    superseded: superseded ?? this.superseded,
    seen: seen ?? this.seen,
  );
  StoredNotice copyWithCompanion(NoticesCompanion data) {
    return StoredNotice(
      noticeId: data.noticeId.present ? data.noticeId.value : this.noticeId,
      kind: data.kind.present ? data.kind.value : this.kind,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      receiptState: data.receiptState.present
          ? data.receiptState.value
          : this.receiptState,
      teamName: data.teamName.present ? data.teamName.value : this.teamName,
      alertLevel: data.alertLevel.present
          ? data.alertLevel.value
          : this.alertLevel,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      expiry: data.expiry.present ? data.expiry.value : this.expiry,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      signedBody: data.signedBody.present
          ? data.signedBody.value
          : this.signedBody,
      signature: data.signature.present ? data.signature.value : this.signature,
      superseded: data.superseded.present
          ? data.superseded.value
          : this.superseded,
      seen: data.seen.present ? data.seen.value : this.seen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredNotice(')
          ..write('noticeId: $noticeId, ')
          ..write('kind: $kind, ')
          ..write('messageId: $messageId, ')
          ..write('receiptState: $receiptState, ')
          ..write('teamName: $teamName, ')
          ..write('alertLevel: $alertLevel, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('expiry: $expiry, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('signedBody: $signedBody, ')
          ..write('signature: $signature, ')
          ..write('superseded: $superseded, ')
          ..write('seen: $seen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    noticeId,
    kind,
    messageId,
    receiptState,
    teamName,
    alertLevel,
    title,
    body,
    issuedAt,
    expiry,
    receivedAt,
    $driftBlobEquality.hash(signedBody),
    $driftBlobEquality.hash(signature),
    superseded,
    seen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredNotice &&
          other.noticeId == this.noticeId &&
          other.kind == this.kind &&
          other.messageId == this.messageId &&
          other.receiptState == this.receiptState &&
          other.teamName == this.teamName &&
          other.alertLevel == this.alertLevel &&
          other.title == this.title &&
          other.body == this.body &&
          other.issuedAt == this.issuedAt &&
          other.expiry == this.expiry &&
          other.receivedAt == this.receivedAt &&
          $driftBlobEquality.equals(other.signedBody, this.signedBody) &&
          $driftBlobEquality.equals(other.signature, this.signature) &&
          other.superseded == this.superseded &&
          other.seen == this.seen);
}

class NoticesCompanion extends UpdateCompanion<StoredNotice> {
  final Value<String> noticeId;
  final Value<NoticeKind> kind;
  final Value<String?> messageId;
  final Value<ReceiptState?> receiptState;
  final Value<String?> teamName;
  final Value<AlertLevel?> alertLevel;
  final Value<String?> title;
  final Value<String?> body;
  final Value<DateTime> issuedAt;
  final Value<DateTime> expiry;
  final Value<DateTime> receivedAt;
  final Value<Uint8List> signedBody;
  final Value<Uint8List> signature;
  final Value<bool> superseded;
  final Value<bool> seen;
  final Value<int> rowid;
  const NoticesCompanion({
    this.noticeId = const Value.absent(),
    this.kind = const Value.absent(),
    this.messageId = const Value.absent(),
    this.receiptState = const Value.absent(),
    this.teamName = const Value.absent(),
    this.alertLevel = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.expiry = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.signedBody = const Value.absent(),
    this.signature = const Value.absent(),
    this.superseded = const Value.absent(),
    this.seen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoticesCompanion.insert({
    required String noticeId,
    required NoticeKind kind,
    this.messageId = const Value.absent(),
    this.receiptState = const Value.absent(),
    this.teamName = const Value.absent(),
    this.alertLevel = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    required DateTime issuedAt,
    required DateTime expiry,
    required DateTime receivedAt,
    required Uint8List signedBody,
    required Uint8List signature,
    this.superseded = const Value.absent(),
    this.seen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : noticeId = Value(noticeId),
       kind = Value(kind),
       issuedAt = Value(issuedAt),
       expiry = Value(expiry),
       receivedAt = Value(receivedAt),
       signedBody = Value(signedBody),
       signature = Value(signature);
  static Insertable<StoredNotice> custom({
    Expression<String>? noticeId,
    Expression<String>? kind,
    Expression<String>? messageId,
    Expression<String>? receiptState,
    Expression<String>? teamName,
    Expression<String>? alertLevel,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? issuedAt,
    Expression<DateTime>? expiry,
    Expression<DateTime>? receivedAt,
    Expression<Uint8List>? signedBody,
    Expression<Uint8List>? signature,
    Expression<bool>? superseded,
    Expression<bool>? seen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noticeId != null) 'notice_id': noticeId,
      if (kind != null) 'kind': kind,
      if (messageId != null) 'message_id': messageId,
      if (receiptState != null) 'receipt_state': receiptState,
      if (teamName != null) 'team_name': teamName,
      if (alertLevel != null) 'alert_level': alertLevel,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (expiry != null) 'expiry': expiry,
      if (receivedAt != null) 'received_at': receivedAt,
      if (signedBody != null) 'signed_body': signedBody,
      if (signature != null) 'signature': signature,
      if (superseded != null) 'superseded': superseded,
      if (seen != null) 'seen': seen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoticesCompanion copyWith({
    Value<String>? noticeId,
    Value<NoticeKind>? kind,
    Value<String?>? messageId,
    Value<ReceiptState?>? receiptState,
    Value<String?>? teamName,
    Value<AlertLevel?>? alertLevel,
    Value<String?>? title,
    Value<String?>? body,
    Value<DateTime>? issuedAt,
    Value<DateTime>? expiry,
    Value<DateTime>? receivedAt,
    Value<Uint8List>? signedBody,
    Value<Uint8List>? signature,
    Value<bool>? superseded,
    Value<bool>? seen,
    Value<int>? rowid,
  }) {
    return NoticesCompanion(
      noticeId: noticeId ?? this.noticeId,
      kind: kind ?? this.kind,
      messageId: messageId ?? this.messageId,
      receiptState: receiptState ?? this.receiptState,
      teamName: teamName ?? this.teamName,
      alertLevel: alertLevel ?? this.alertLevel,
      title: title ?? this.title,
      body: body ?? this.body,
      issuedAt: issuedAt ?? this.issuedAt,
      expiry: expiry ?? this.expiry,
      receivedAt: receivedAt ?? this.receivedAt,
      signedBody: signedBody ?? this.signedBody,
      signature: signature ?? this.signature,
      superseded: superseded ?? this.superseded,
      seen: seen ?? this.seen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noticeId.present) {
      map['notice_id'] = Variable<String>(noticeId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $NoticesTable.$converterkind.toSql(kind.value),
      );
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (receiptState.present) {
      map['receipt_state'] = Variable<String>(
        $NoticesTable.$converterreceiptStaten.toSql(receiptState.value),
      );
    }
    if (teamName.present) {
      map['team_name'] = Variable<String>(teamName.value);
    }
    if (alertLevel.present) {
      map['alert_level'] = Variable<String>(
        $NoticesTable.$converteralertLeveln.toSql(alertLevel.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (expiry.present) {
      map['expiry'] = Variable<DateTime>(expiry.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (signedBody.present) {
      map['signed_body'] = Variable<Uint8List>(signedBody.value);
    }
    if (signature.present) {
      map['signature'] = Variable<Uint8List>(signature.value);
    }
    if (superseded.present) {
      map['superseded'] = Variable<bool>(superseded.value);
    }
    if (seen.present) {
      map['seen'] = Variable<bool>(seen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoticesCompanion(')
          ..write('noticeId: $noticeId, ')
          ..write('kind: $kind, ')
          ..write('messageId: $messageId, ')
          ..write('receiptState: $receiptState, ')
          ..write('teamName: $teamName, ')
          ..write('alertLevel: $alertLevel, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('expiry: $expiry, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('signedBody: $signedBody, ')
          ..write('signature: $signature, ')
          ..write('superseded: $superseded, ')
          ..write('seen: $seen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $RelayLogTable relayLog = $RelayLogTable(this);
  late final $GatewayUploadsTable gatewayUploads = $GatewayUploadsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $NoticesTable notices = $NoticesTable(this);
  late final Index relayLogMsgPeer = Index(
    'relay_log_msg_peer',
    'CREATE INDEX relay_log_msg_peer ON relay_log (message_id, relay_device_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messages,
    relayLog,
    gatewayUploads,
    appSettings,
    notices,
    relayLogMsgPeer,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String messageId,
      required String senderDeviceId,
      required NeedType type,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> note,
      required DateTime timestamp,
      required DateTime ttlExpiry,
      required int hopCount,
      required double priorityScore,
      required MessageStatus status,
      required Uint8List sealedPayload,
      required DateTime receivedAt,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> messageId,
      Value<String> senderDeviceId,
      Value<NeedType> type,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> note,
      Value<DateTime> timestamp,
      Value<DateTime> ttlExpiry,
      Value<int> hopCount,
      Value<double> priorityScore,
      Value<MessageStatus> status,
      Value<Uint8List> sealedPayload,
      Value<DateTime> receivedAt,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderDeviceId => $composableBuilder(
    column: $table.senderDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NeedType, NeedType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ttlExpiry => $composableBuilder(
    column: $table.ttlExpiry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hopCount => $composableBuilder(
    column: $table.hopCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priorityScore => $composableBuilder(
    column: $table.priorityScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MessageStatus, MessageStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<Uint8List> get sealedPayload => $composableBuilder(
    column: $table.sealedPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderDeviceId => $composableBuilder(
    column: $table.senderDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ttlExpiry => $composableBuilder(
    column: $table.ttlExpiry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hopCount => $composableBuilder(
    column: $table.hopCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priorityScore => $composableBuilder(
    column: $table.priorityScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get sealedPayload => $composableBuilder(
    column: $table.sealedPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get senderDeviceId => $composableBuilder(
    column: $table.senderDeviceId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<NeedType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<DateTime> get ttlExpiry =>
      $composableBuilder(column: $table.ttlExpiry, builder: (column) => column);

  GeneratedColumn<int> get hopCount =>
      $composableBuilder(column: $table.hopCount, builder: (column) => column);

  GeneratedColumn<double> get priorityScore => $composableBuilder(
    column: $table.priorityScore,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MessageStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<Uint8List> get sealedPayload => $composableBuilder(
    column: $table.sealedPayload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          StoredMessage,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (
            StoredMessage,
            BaseReferences<_$AppDatabase, $MessagesTable, StoredMessage>,
          ),
          StoredMessage,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageId = const Value.absent(),
                Value<String> senderDeviceId = const Value.absent(),
                Value<NeedType> type = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<DateTime> ttlExpiry = const Value.absent(),
                Value<int> hopCount = const Value.absent(),
                Value<double> priorityScore = const Value.absent(),
                Value<MessageStatus> status = const Value.absent(),
                Value<Uint8List> sealedPayload = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                messageId: messageId,
                senderDeviceId: senderDeviceId,
                type: type,
                latitude: latitude,
                longitude: longitude,
                note: note,
                timestamp: timestamp,
                ttlExpiry: ttlExpiry,
                hopCount: hopCount,
                priorityScore: priorityScore,
                status: status,
                sealedPayload: sealedPayload,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageId,
                required String senderDeviceId,
                required NeedType type,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime timestamp,
                required DateTime ttlExpiry,
                required int hopCount,
                required double priorityScore,
                required MessageStatus status,
                required Uint8List sealedPayload,
                required DateTime receivedAt,
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                messageId: messageId,
                senderDeviceId: senderDeviceId,
                type: type,
                latitude: latitude,
                longitude: longitude,
                note: note,
                timestamp: timestamp,
                ttlExpiry: ttlExpiry,
                hopCount: hopCount,
                priorityScore: priorityScore,
                status: status,
                sealedPayload: sealedPayload,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      StoredMessage,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (
        StoredMessage,
        BaseReferences<_$AppDatabase, $MessagesTable, StoredMessage>,
      ),
      StoredMessage,
      PrefetchHooks Function()
    >;
typedef $$RelayLogTableCreateCompanionBuilder =
    RelayLogCompanion Function({
      required String relayId,
      required String messageId,
      required String relayDeviceId,
      required RelayDirection direction,
      required DateTime relayTimestamp,
      Value<int> rowid,
    });
typedef $$RelayLogTableUpdateCompanionBuilder =
    RelayLogCompanion Function({
      Value<String> relayId,
      Value<String> messageId,
      Value<String> relayDeviceId,
      Value<RelayDirection> direction,
      Value<DateTime> relayTimestamp,
      Value<int> rowid,
    });

class $$RelayLogTableFilterComposer
    extends Composer<_$AppDatabase, $RelayLogTable> {
  $$RelayLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get relayId => $composableBuilder(
    column: $table.relayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relayDeviceId => $composableBuilder(
    column: $table.relayDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RelayDirection, RelayDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get relayTimestamp => $composableBuilder(
    column: $table.relayTimestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RelayLogTableOrderingComposer
    extends Composer<_$AppDatabase, $RelayLogTable> {
  $$RelayLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get relayId => $composableBuilder(
    column: $table.relayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relayDeviceId => $composableBuilder(
    column: $table.relayDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get relayTimestamp => $composableBuilder(
    column: $table.relayTimestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RelayLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelayLogTable> {
  $$RelayLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get relayId =>
      $composableBuilder(column: $table.relayId, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get relayDeviceId => $composableBuilder(
    column: $table.relayDeviceId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RelayDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<DateTime> get relayTimestamp => $composableBuilder(
    column: $table.relayTimestamp,
    builder: (column) => column,
  );
}

class $$RelayLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RelayLogTable,
          RelayLogEntry,
          $$RelayLogTableFilterComposer,
          $$RelayLogTableOrderingComposer,
          $$RelayLogTableAnnotationComposer,
          $$RelayLogTableCreateCompanionBuilder,
          $$RelayLogTableUpdateCompanionBuilder,
          (
            RelayLogEntry,
            BaseReferences<_$AppDatabase, $RelayLogTable, RelayLogEntry>,
          ),
          RelayLogEntry,
          PrefetchHooks Function()
        > {
  $$RelayLogTableTableManager(_$AppDatabase db, $RelayLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelayLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelayLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelayLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> relayId = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> relayDeviceId = const Value.absent(),
                Value<RelayDirection> direction = const Value.absent(),
                Value<DateTime> relayTimestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelayLogCompanion(
                relayId: relayId,
                messageId: messageId,
                relayDeviceId: relayDeviceId,
                direction: direction,
                relayTimestamp: relayTimestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String relayId,
                required String messageId,
                required String relayDeviceId,
                required RelayDirection direction,
                required DateTime relayTimestamp,
                Value<int> rowid = const Value.absent(),
              }) => RelayLogCompanion.insert(
                relayId: relayId,
                messageId: messageId,
                relayDeviceId: relayDeviceId,
                direction: direction,
                relayTimestamp: relayTimestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RelayLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RelayLogTable,
      RelayLogEntry,
      $$RelayLogTableFilterComposer,
      $$RelayLogTableOrderingComposer,
      $$RelayLogTableAnnotationComposer,
      $$RelayLogTableCreateCompanionBuilder,
      $$RelayLogTableUpdateCompanionBuilder,
      (
        RelayLogEntry,
        BaseReferences<_$AppDatabase, $RelayLogTable, RelayLogEntry>,
      ),
      RelayLogEntry,
      PrefetchHooks Function()
    >;
typedef $$GatewayUploadsTableCreateCompanionBuilder =
    GatewayUploadsCompanion Function({
      required String uploadId,
      required String messageId,
      required String gatewayDeviceId,
      required DateTime uploadTimestamp,
      required String backendAckStatus,
      Value<int> rowid,
    });
typedef $$GatewayUploadsTableUpdateCompanionBuilder =
    GatewayUploadsCompanion Function({
      Value<String> uploadId,
      Value<String> messageId,
      Value<String> gatewayDeviceId,
      Value<DateTime> uploadTimestamp,
      Value<String> backendAckStatus,
      Value<int> rowid,
    });

class $$GatewayUploadsTableFilterComposer
    extends Composer<_$AppDatabase, $GatewayUploadsTable> {
  $$GatewayUploadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uploadId => $composableBuilder(
    column: $table.uploadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gatewayDeviceId => $composableBuilder(
    column: $table.gatewayDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get uploadTimestamp => $composableBuilder(
    column: $table.uploadTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backendAckStatus => $composableBuilder(
    column: $table.backendAckStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GatewayUploadsTableOrderingComposer
    extends Composer<_$AppDatabase, $GatewayUploadsTable> {
  $$GatewayUploadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uploadId => $composableBuilder(
    column: $table.uploadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gatewayDeviceId => $composableBuilder(
    column: $table.gatewayDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get uploadTimestamp => $composableBuilder(
    column: $table.uploadTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backendAckStatus => $composableBuilder(
    column: $table.backendAckStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GatewayUploadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GatewayUploadsTable> {
  $$GatewayUploadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uploadId =>
      $composableBuilder(column: $table.uploadId, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get gatewayDeviceId => $composableBuilder(
    column: $table.gatewayDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get uploadTimestamp => $composableBuilder(
    column: $table.uploadTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backendAckStatus => $composableBuilder(
    column: $table.backendAckStatus,
    builder: (column) => column,
  );
}

class $$GatewayUploadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GatewayUploadsTable,
          GatewayUploadEntry,
          $$GatewayUploadsTableFilterComposer,
          $$GatewayUploadsTableOrderingComposer,
          $$GatewayUploadsTableAnnotationComposer,
          $$GatewayUploadsTableCreateCompanionBuilder,
          $$GatewayUploadsTableUpdateCompanionBuilder,
          (
            GatewayUploadEntry,
            BaseReferences<
              _$AppDatabase,
              $GatewayUploadsTable,
              GatewayUploadEntry
            >,
          ),
          GatewayUploadEntry,
          PrefetchHooks Function()
        > {
  $$GatewayUploadsTableTableManager(
    _$AppDatabase db,
    $GatewayUploadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GatewayUploadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GatewayUploadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GatewayUploadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uploadId = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> gatewayDeviceId = const Value.absent(),
                Value<DateTime> uploadTimestamp = const Value.absent(),
                Value<String> backendAckStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GatewayUploadsCompanion(
                uploadId: uploadId,
                messageId: messageId,
                gatewayDeviceId: gatewayDeviceId,
                uploadTimestamp: uploadTimestamp,
                backendAckStatus: backendAckStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uploadId,
                required String messageId,
                required String gatewayDeviceId,
                required DateTime uploadTimestamp,
                required String backendAckStatus,
                Value<int> rowid = const Value.absent(),
              }) => GatewayUploadsCompanion.insert(
                uploadId: uploadId,
                messageId: messageId,
                gatewayDeviceId: gatewayDeviceId,
                uploadTimestamp: uploadTimestamp,
                backendAckStatus: backendAckStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GatewayUploadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GatewayUploadsTable,
      GatewayUploadEntry,
      $$GatewayUploadsTableFilterComposer,
      $$GatewayUploadsTableOrderingComposer,
      $$GatewayUploadsTableAnnotationComposer,
      $$GatewayUploadsTableCreateCompanionBuilder,
      $$GatewayUploadsTableUpdateCompanionBuilder,
      (
        GatewayUploadEntry,
        BaseReferences<_$AppDatabase, $GatewayUploadsTable, GatewayUploadEntry>,
      ),
      GatewayUploadEntry,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$NoticesTableCreateCompanionBuilder =
    NoticesCompanion Function({
      required String noticeId,
      required NoticeKind kind,
      Value<String?> messageId,
      Value<ReceiptState?> receiptState,
      Value<String?> teamName,
      Value<AlertLevel?> alertLevel,
      Value<String?> title,
      Value<String?> body,
      required DateTime issuedAt,
      required DateTime expiry,
      required DateTime receivedAt,
      required Uint8List signedBody,
      required Uint8List signature,
      Value<bool> superseded,
      Value<bool> seen,
      Value<int> rowid,
    });
typedef $$NoticesTableUpdateCompanionBuilder =
    NoticesCompanion Function({
      Value<String> noticeId,
      Value<NoticeKind> kind,
      Value<String?> messageId,
      Value<ReceiptState?> receiptState,
      Value<String?> teamName,
      Value<AlertLevel?> alertLevel,
      Value<String?> title,
      Value<String?> body,
      Value<DateTime> issuedAt,
      Value<DateTime> expiry,
      Value<DateTime> receivedAt,
      Value<Uint8List> signedBody,
      Value<Uint8List> signature,
      Value<bool> superseded,
      Value<bool> seen,
      Value<int> rowid,
    });

class $$NoticesTableFilterComposer
    extends Composer<_$AppDatabase, $NoticesTable> {
  $$NoticesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get noticeId => $composableBuilder(
    column: $table.noticeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NoticeKind, NoticeKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReceiptState?, ReceiptState, String>
  get receiptState => $composableBuilder(
    column: $table.receiptState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get teamName => $composableBuilder(
    column: $table.teamName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AlertLevel?, AlertLevel, String>
  get alertLevel => $composableBuilder(
    column: $table.alertLevel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiry => $composableBuilder(
    column: $table.expiry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get signedBody => $composableBuilder(
    column: $table.signedBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get superseded => $composableBuilder(
    column: $table.superseded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoticesTableOrderingComposer
    extends Composer<_$AppDatabase, $NoticesTable> {
  $$NoticesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get noticeId => $composableBuilder(
    column: $table.noticeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptState => $composableBuilder(
    column: $table.receiptState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamName => $composableBuilder(
    column: $table.teamName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertLevel => $composableBuilder(
    column: $table.alertLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiry => $composableBuilder(
    column: $table.expiry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signedBody => $composableBuilder(
    column: $table.signedBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get superseded => $composableBuilder(
    column: $table.superseded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoticesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoticesTable> {
  $$NoticesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get noticeId =>
      $composableBuilder(column: $table.noticeId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NoticeKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReceiptState?, String> get receiptState =>
      $composableBuilder(
        column: $table.receiptState,
        builder: (column) => column,
      );

  GeneratedColumn<String> get teamName =>
      $composableBuilder(column: $table.teamName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AlertLevel?, String> get alertLevel =>
      $composableBuilder(
        column: $table.alertLevel,
        builder: (column) => column,
      );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiry =>
      $composableBuilder(column: $table.expiry, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get signedBody => $composableBuilder(
    column: $table.signedBody,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<bool> get superseded => $composableBuilder(
    column: $table.superseded,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get seen =>
      $composableBuilder(column: $table.seen, builder: (column) => column);
}

class $$NoticesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoticesTable,
          StoredNotice,
          $$NoticesTableFilterComposer,
          $$NoticesTableOrderingComposer,
          $$NoticesTableAnnotationComposer,
          $$NoticesTableCreateCompanionBuilder,
          $$NoticesTableUpdateCompanionBuilder,
          (
            StoredNotice,
            BaseReferences<_$AppDatabase, $NoticesTable, StoredNotice>,
          ),
          StoredNotice,
          PrefetchHooks Function()
        > {
  $$NoticesTableTableManager(_$AppDatabase db, $NoticesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoticesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoticesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoticesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> noticeId = const Value.absent(),
                Value<NoticeKind> kind = const Value.absent(),
                Value<String?> messageId = const Value.absent(),
                Value<ReceiptState?> receiptState = const Value.absent(),
                Value<String?> teamName = const Value.absent(),
                Value<AlertLevel?> alertLevel = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<DateTime> issuedAt = const Value.absent(),
                Value<DateTime> expiry = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<Uint8List> signedBody = const Value.absent(),
                Value<Uint8List> signature = const Value.absent(),
                Value<bool> superseded = const Value.absent(),
                Value<bool> seen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoticesCompanion(
                noticeId: noticeId,
                kind: kind,
                messageId: messageId,
                receiptState: receiptState,
                teamName: teamName,
                alertLevel: alertLevel,
                title: title,
                body: body,
                issuedAt: issuedAt,
                expiry: expiry,
                receivedAt: receivedAt,
                signedBody: signedBody,
                signature: signature,
                superseded: superseded,
                seen: seen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String noticeId,
                required NoticeKind kind,
                Value<String?> messageId = const Value.absent(),
                Value<ReceiptState?> receiptState = const Value.absent(),
                Value<String?> teamName = const Value.absent(),
                Value<AlertLevel?> alertLevel = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> body = const Value.absent(),
                required DateTime issuedAt,
                required DateTime expiry,
                required DateTime receivedAt,
                required Uint8List signedBody,
                required Uint8List signature,
                Value<bool> superseded = const Value.absent(),
                Value<bool> seen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoticesCompanion.insert(
                noticeId: noticeId,
                kind: kind,
                messageId: messageId,
                receiptState: receiptState,
                teamName: teamName,
                alertLevel: alertLevel,
                title: title,
                body: body,
                issuedAt: issuedAt,
                expiry: expiry,
                receivedAt: receivedAt,
                signedBody: signedBody,
                signature: signature,
                superseded: superseded,
                seen: seen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoticesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoticesTable,
      StoredNotice,
      $$NoticesTableFilterComposer,
      $$NoticesTableOrderingComposer,
      $$NoticesTableAnnotationComposer,
      $$NoticesTableCreateCompanionBuilder,
      $$NoticesTableUpdateCompanionBuilder,
      (
        StoredNotice,
        BaseReferences<_$AppDatabase, $NoticesTable, StoredNotice>,
      ),
      StoredNotice,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$RelayLogTableTableManager get relayLog =>
      $$RelayLogTableTableManager(_db, _db.relayLog);
  $$GatewayUploadsTableTableManager get gatewayUploads =>
      $$GatewayUploadsTableTableManager(_db, _db.gatewayUploads);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$NoticesTableTableManager get notices =>
      $$NoticesTableTableManager(_db, _db.notices);
}
