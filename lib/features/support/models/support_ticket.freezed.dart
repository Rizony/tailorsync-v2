// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_ticket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SupportTicket _$SupportTicketFromJson(Map<String, dynamic> json) {
  return _SupportTicket.fromJson(json);
}

/// @nodoc
mixin _$SupportTicket {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'priority')
  String get priority => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SupportTicket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportTicket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportTicketCopyWith<SupportTicket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportTicketCopyWith<$Res> {
  factory $SupportTicketCopyWith(
          SupportTicket value, $Res Function(SupportTicket) then) =
      _$SupportTicketCopyWithImpl<$Res, SupportTicket>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String subject,
      String status,
      @JsonKey(name: 'priority') String priority,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$SupportTicketCopyWithImpl<$Res, $Val extends SupportTicket>
    implements $SupportTicketCopyWith<$Res> {
  _$SupportTicketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportTicket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subject = null,
    Object? status = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SupportTicketImplCopyWith<$Res>
    implements $SupportTicketCopyWith<$Res> {
  factory _$$SupportTicketImplCopyWith(
          _$SupportTicketImpl value, $Res Function(_$SupportTicketImpl) then) =
      __$$SupportTicketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String subject,
      String status,
      @JsonKey(name: 'priority') String priority,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$SupportTicketImplCopyWithImpl<$Res>
    extends _$SupportTicketCopyWithImpl<$Res, _$SupportTicketImpl>
    implements _$$SupportTicketImplCopyWith<$Res> {
  __$$SupportTicketImplCopyWithImpl(
      _$SupportTicketImpl _value, $Res Function(_$SupportTicketImpl) _then)
      : super(_value, _then);

  /// Create a copy of SupportTicket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subject = null,
    Object? status = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SupportTicketImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupportTicketImpl implements _SupportTicket {
  const _$SupportTicketImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.subject,
      required this.status,
      @JsonKey(name: 'priority') this.priority = 'medium',
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$SupportTicketImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportTicketImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String subject;
  @override
  final String status;
  @override
  @JsonKey(name: 'priority')
  final String priority;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SupportTicket(id: $id, userId: $userId, subject: $subject, status: $status, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportTicketImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, subject, status, priority, createdAt, updatedAt);

  /// Create a copy of SupportTicket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportTicketImplCopyWith<_$SupportTicketImpl> get copyWith =>
      __$$SupportTicketImplCopyWithImpl<_$SupportTicketImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportTicketImplToJson(
      this,
    );
  }
}

abstract class _SupportTicket implements SupportTicket {
  const factory _SupportTicket(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String subject,
          required final String status,
          @JsonKey(name: 'priority') final String priority,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$SupportTicketImpl;

  factory _SupportTicket.fromJson(Map<String, dynamic> json) =
      _$SupportTicketImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get subject;
  @override
  String get status;
  @override
  @JsonKey(name: 'priority')
  String get priority;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of SupportTicket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportTicketImplCopyWith<_$SupportTicketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SupportMessage _$SupportMessageFromJson(Map<String, dynamic> json) {
  return _SupportMessage.fromJson(json);
}

/// @nodoc
mixin _$SupportMessage {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'ticket_id')
  String get ticketId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender_id')
  String get senderId => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_admin_reply')
  bool get isAdminReply => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SupportMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupportMessageCopyWith<SupportMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupportMessageCopyWith<$Res> {
  factory $SupportMessageCopyWith(
          SupportMessage value, $Res Function(SupportMessage) then) =
      _$SupportMessageCopyWithImpl<$Res, SupportMessage>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'ticket_id') String ticketId,
      @JsonKey(name: 'sender_id') String senderId,
      String message,
      @JsonKey(name: 'is_admin_reply') bool isAdminReply,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$SupportMessageCopyWithImpl<$Res, $Val extends SupportMessage>
    implements $SupportMessageCopyWith<$Res> {
  _$SupportMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ticketId = null,
    Object? senderId = null,
    Object? message = null,
    Object? isAdminReply = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ticketId: null == ticketId
          ? _value.ticketId
          : ticketId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isAdminReply: null == isAdminReply
          ? _value.isAdminReply
          : isAdminReply // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SupportMessageImplCopyWith<$Res>
    implements $SupportMessageCopyWith<$Res> {
  factory _$$SupportMessageImplCopyWith(_$SupportMessageImpl value,
          $Res Function(_$SupportMessageImpl) then) =
      __$$SupportMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'ticket_id') String ticketId,
      @JsonKey(name: 'sender_id') String senderId,
      String message,
      @JsonKey(name: 'is_admin_reply') bool isAdminReply,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$SupportMessageImplCopyWithImpl<$Res>
    extends _$SupportMessageCopyWithImpl<$Res, _$SupportMessageImpl>
    implements _$$SupportMessageImplCopyWith<$Res> {
  __$$SupportMessageImplCopyWithImpl(
      _$SupportMessageImpl _value, $Res Function(_$SupportMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ticketId = null,
    Object? senderId = null,
    Object? message = null,
    Object? isAdminReply = null,
    Object? createdAt = null,
  }) {
    return _then(_$SupportMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ticketId: null == ticketId
          ? _value.ticketId
          : ticketId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isAdminReply: null == isAdminReply
          ? _value.isAdminReply
          : isAdminReply // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupportMessageImpl implements _SupportMessage {
  const _$SupportMessageImpl(
      {required this.id,
      @JsonKey(name: 'ticket_id') required this.ticketId,
      @JsonKey(name: 'sender_id') required this.senderId,
      required this.message,
      @JsonKey(name: 'is_admin_reply') required this.isAdminReply,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$SupportMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupportMessageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'ticket_id')
  final String ticketId;
  @override
  @JsonKey(name: 'sender_id')
  final String senderId;
  @override
  final String message;
  @override
  @JsonKey(name: 'is_admin_reply')
  final bool isAdminReply;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'SupportMessage(id: $id, ticketId: $ticketId, senderId: $senderId, message: $message, isAdminReply: $isAdminReply, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupportMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ticketId, ticketId) ||
                other.ticketId == ticketId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isAdminReply, isAdminReply) ||
                other.isAdminReply == isAdminReply) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, ticketId, senderId, message, isAdminReply, createdAt);

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupportMessageImplCopyWith<_$SupportMessageImpl> get copyWith =>
      __$$SupportMessageImplCopyWithImpl<_$SupportMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupportMessageImplToJson(
      this,
    );
  }
}

abstract class _SupportMessage implements SupportMessage {
  const factory _SupportMessage(
          {required final String id,
          @JsonKey(name: 'ticket_id') required final String ticketId,
          @JsonKey(name: 'sender_id') required final String senderId,
          required final String message,
          @JsonKey(name: 'is_admin_reply') required final bool isAdminReply,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$SupportMessageImpl;

  factory _SupportMessage.fromJson(Map<String, dynamic> json) =
      _$SupportMessageImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'ticket_id')
  String get ticketId;
  @override
  @JsonKey(name: 'sender_id')
  String get senderId;
  @override
  String get message;
  @override
  @JsonKey(name: 'is_admin_reply')
  bool get isAdminReply;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of SupportMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupportMessageImplCopyWith<_$SupportMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
