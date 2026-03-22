// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) {
  return _OrderItem.fromJson(json);
}

/// @nodoc
mixin _$OrderItem {
  @HiveField(0)
  String get name => throw _privateConstructorUsedError;
  @HiveField(1)
  int get quantity => throw _privateConstructorUsedError;
  @HiveField(2)
  double get price => throw _privateConstructorUsedError;

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemCopyWith<OrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemCopyWith<$Res> {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) then) =
      _$OrderItemCopyWithImpl<$Res, OrderItem>;
  @useResult
  $Res call(
      {@HiveField(0) String name,
      @HiveField(1) int quantity,
      @HiveField(2) double price});
}

/// @nodoc
class _$OrderItemCopyWithImpl<$Res, $Val extends OrderItem>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? price = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderItemImplCopyWith<$Res>
    implements $OrderItemCopyWith<$Res> {
  factory _$$OrderItemImplCopyWith(
          _$OrderItemImpl value, $Res Function(_$OrderItemImpl) then) =
      __$$OrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String name,
      @HiveField(1) int quantity,
      @HiveField(2) double price});
}

/// @nodoc
class __$$OrderItemImplCopyWithImpl<$Res>
    extends _$OrderItemCopyWithImpl<$Res, _$OrderItemImpl>
    implements _$$OrderItemImplCopyWith<$Res> {
  __$$OrderItemImplCopyWithImpl(
      _$OrderItemImpl _value, $Res Function(_$OrderItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? price = null,
  }) {
    return _then(_$OrderItemImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemImpl implements _OrderItem {
  const _$OrderItemImpl(
      {@HiveField(0) required this.name,
      @HiveField(1) this.quantity = 1,
      @HiveField(2) this.price = 0});

  factory _$OrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemImplFromJson(json);

  @override
  @HiveField(0)
  final String name;
  @override
  @JsonKey()
  @HiveField(1)
  final int quantity;
  @override
  @JsonKey()
  @HiveField(2)
  final double price;

  @override
  String toString() {
    return 'OrderItem(name: $name, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, quantity, price);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      __$$OrderItemImplCopyWithImpl<_$OrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemImplToJson(
      this,
    );
  }
}

abstract class _OrderItem implements OrderItem {
  const factory _OrderItem(
      {@HiveField(0) required final String name,
      @HiveField(1) final int quantity,
      @HiveField(2) final double price}) = _$OrderItemImpl;

  factory _OrderItem.fromJson(Map<String, dynamic> json) =
      _$OrderItemImpl.fromJson;

  @override
  @HiveField(0)
  String get name;
  @override
  @HiveField(1)
  int get quantity;
  @override
  @HiveField(2)
  double get price;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return _Payment.fromJson(json);
}

/// @nodoc
mixin _$Payment {
  @HiveField(0)
  double get amount => throw _privateConstructorUsedError;
  @HiveField(1)
  DateTime get date => throw _privateConstructorUsedError;
  @HiveField(2)
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  @HiveField(3)
  String? get paymentMethod => throw _privateConstructorUsedError;

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentCopyWith<Payment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentCopyWith<$Res> {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) then) =
      _$PaymentCopyWithImpl<$Res, Payment>;
  @useResult
  $Res call(
      {@HiveField(0) double amount,
      @HiveField(1) DateTime date,
      @HiveField(2) String? note,
      @JsonKey(name: 'payment_method') @HiveField(3) String? paymentMethod});
}

/// @nodoc
class _$PaymentCopyWithImpl<$Res, $Val extends Payment>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? date = null,
    Object? note = freezed,
    Object? paymentMethod = freezed,
  }) {
    return _then(_value.copyWith(
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentImplCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$$PaymentImplCopyWith(
          _$PaymentImpl value, $Res Function(_$PaymentImpl) then) =
      __$$PaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) double amount,
      @HiveField(1) DateTime date,
      @HiveField(2) String? note,
      @JsonKey(name: 'payment_method') @HiveField(3) String? paymentMethod});
}

/// @nodoc
class __$$PaymentImplCopyWithImpl<$Res>
    extends _$PaymentCopyWithImpl<$Res, _$PaymentImpl>
    implements _$$PaymentImplCopyWith<$Res> {
  __$$PaymentImplCopyWithImpl(
      _$PaymentImpl _value, $Res Function(_$PaymentImpl) _then)
      : super(_value, _then);

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? date = null,
    Object? note = freezed,
    Object? paymentMethod = freezed,
  }) {
    return _then(_$PaymentImpl(
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentImpl implements _Payment {
  const _$PaymentImpl(
      {@HiveField(0) required this.amount,
      @HiveField(1) required this.date,
      @HiveField(2) this.note,
      @JsonKey(name: 'payment_method') @HiveField(3) this.paymentMethod});

  factory _$PaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentImplFromJson(json);

  @override
  @HiveField(0)
  final double amount;
  @override
  @HiveField(1)
  final DateTime date;
  @override
  @HiveField(2)
  final String? note;
  @override
  @JsonKey(name: 'payment_method')
  @HiveField(3)
  final String? paymentMethod;

  @override
  String toString() {
    return 'Payment(amount: $amount, date: $date, note: $note, paymentMethod: $paymentMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, amount, date, note, paymentMethod);

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      __$$PaymentImplCopyWithImpl<_$PaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentImplToJson(
      this,
    );
  }
}

abstract class _Payment implements Payment {
  const factory _Payment(
      {@HiveField(0) required final double amount,
      @HiveField(1) required final DateTime date,
      @HiveField(2) final String? note,
      @JsonKey(name: 'payment_method')
      @HiveField(3)
      final String? paymentMethod}) = _$PaymentImpl;

  factory _Payment.fromJson(Map<String, dynamic> json) = _$PaymentImpl.fromJson;

  @override
  @HiveField(0)
  double get amount;
  @override
  @HiveField(1)
  DateTime get date;
  @override
  @HiveField(2)
  String? get note;
  @override
  @JsonKey(name: 'payment_method')
  @HiveField(3)
  String? get paymentMethod;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return _OrderModel.fromJson(json);
}

/// @nodoc
mixin _$OrderModel {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  @HiveField(1)
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  @HiveField(2)
  String get customerId => throw _privateConstructorUsedError;
  @HiveField(3)
  String get title => throw _privateConstructorUsedError;
  @HiveField(4)
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'balance_due')
  @HiveField(5)
  double get balanceDue => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  @HiveField(6)
  DateTime get dueDate => throw _privateConstructorUsedError;
  @HiveField(7)
  String get status => throw _privateConstructorUsedError;
  @HiveField(8)
  List<String> get images => throw _privateConstructorUsedError;
  @HiveField(9)
  List<OrderItem> get items => throw _privateConstructorUsedError;
  @HiveField(10)
  List<Payment> get payments => throw _privateConstructorUsedError;
  @JsonKey(name: 'fabric_status')
  @HiveField(11)
  String get fabricStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'fabric_source')
  @HiveField(12)
  String? get fabricSource => throw _privateConstructorUsedError;
  @HiveField(13)
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  @HiveField(14)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'assigned_to')
  @HiveField(15)
  String? get assignedTo => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_outsourced')
  @HiveField(16)
  bool get isOutsourced => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readCustomerName, includeToJson: false)
  @HiveField(17)
  String? get customerName => throw _privateConstructorUsedError;

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
          OrderModel value, $Res Function(OrderModel) then) =
      _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @JsonKey(name: 'user_id') @HiveField(1) String userId,
      @JsonKey(name: 'customer_id') @HiveField(2) String customerId,
      @HiveField(3) String title,
      @HiveField(4) double price,
      @JsonKey(name: 'balance_due') @HiveField(5) double balanceDue,
      @JsonKey(name: 'due_date') @HiveField(6) DateTime dueDate,
      @HiveField(7) String status,
      @HiveField(8) List<String> images,
      @HiveField(9) List<OrderItem> items,
      @HiveField(10) List<Payment> payments,
      @JsonKey(name: 'fabric_status') @HiveField(11) String fabricStatus,
      @JsonKey(name: 'fabric_source') @HiveField(12) String? fabricSource,
      @HiveField(13) String? notes,
      @JsonKey(name: 'created_at') @HiveField(14) DateTime createdAt,
      @JsonKey(name: 'assigned_to') @HiveField(15) String? assignedTo,
      @JsonKey(name: 'is_outsourced') @HiveField(16) bool isOutsourced,
      @JsonKey(readValue: _readCustomerName, includeToJson: false)
      @HiveField(17)
      String? customerName});
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? customerId = null,
    Object? title = null,
    Object? price = null,
    Object? balanceDue = null,
    Object? dueDate = null,
    Object? status = null,
    Object? images = null,
    Object? items = null,
    Object? payments = null,
    Object? fabricStatus = null,
    Object? fabricSource = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? assignedTo = freezed,
    Object? isOutsourced = null,
    Object? customerName = freezed,
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
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      balanceDue: null == balanceDue
          ? _value.balanceDue
          : balanceDue // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      payments: null == payments
          ? _value.payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<Payment>,
      fabricStatus: null == fabricStatus
          ? _value.fabricStatus
          : fabricStatus // ignore: cast_nullable_to_non_nullable
              as String,
      fabricSource: freezed == fabricSource
          ? _value.fabricSource
          : fabricSource // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String?,
      isOutsourced: null == isOutsourced
          ? _value.isOutsourced
          : isOutsourced // ignore: cast_nullable_to_non_nullable
              as bool,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
          _$OrderModelImpl value, $Res Function(_$OrderModelImpl) then) =
      __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @JsonKey(name: 'user_id') @HiveField(1) String userId,
      @JsonKey(name: 'customer_id') @HiveField(2) String customerId,
      @HiveField(3) String title,
      @HiveField(4) double price,
      @JsonKey(name: 'balance_due') @HiveField(5) double balanceDue,
      @JsonKey(name: 'due_date') @HiveField(6) DateTime dueDate,
      @HiveField(7) String status,
      @HiveField(8) List<String> images,
      @HiveField(9) List<OrderItem> items,
      @HiveField(10) List<Payment> payments,
      @JsonKey(name: 'fabric_status') @HiveField(11) String fabricStatus,
      @JsonKey(name: 'fabric_source') @HiveField(12) String? fabricSource,
      @HiveField(13) String? notes,
      @JsonKey(name: 'created_at') @HiveField(14) DateTime createdAt,
      @JsonKey(name: 'assigned_to') @HiveField(15) String? assignedTo,
      @JsonKey(name: 'is_outsourced') @HiveField(16) bool isOutsourced,
      @JsonKey(readValue: _readCustomerName, includeToJson: false)
      @HiveField(17)
      String? customerName});
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
      _$OrderModelImpl _value, $Res Function(_$OrderModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? customerId = null,
    Object? title = null,
    Object? price = null,
    Object? balanceDue = null,
    Object? dueDate = null,
    Object? status = null,
    Object? images = null,
    Object? items = null,
    Object? payments = null,
    Object? fabricStatus = null,
    Object? fabricSource = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? assignedTo = freezed,
    Object? isOutsourced = null,
    Object? customerName = freezed,
  }) {
    return _then(_$OrderModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      balanceDue: null == balanceDue
          ? _value.balanceDue
          : balanceDue // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      payments: null == payments
          ? _value._payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<Payment>,
      fabricStatus: null == fabricStatus
          ? _value.fabricStatus
          : fabricStatus // ignore: cast_nullable_to_non_nullable
              as String,
      fabricSource: freezed == fabricSource
          ? _value.fabricSource
          : fabricSource // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String?,
      isOutsourced: null == isOutsourced
          ? _value.isOutsourced
          : isOutsourced // ignore: cast_nullable_to_non_nullable
              as bool,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderModelImpl implements _OrderModel {
  const _$OrderModelImpl(
      {@HiveField(0) required this.id,
      @JsonKey(name: 'user_id') @HiveField(1) required this.userId,
      @JsonKey(name: 'customer_id') @HiveField(2) required this.customerId,
      @HiveField(3) required this.title,
      @HiveField(4) this.price = 0,
      @JsonKey(name: 'balance_due') @HiveField(5) this.balanceDue = 0,
      @JsonKey(name: 'due_date') @HiveField(6) required this.dueDate,
      @HiveField(7) this.status = 'pending',
      @HiveField(8) final List<String> images = const [],
      @HiveField(9) final List<OrderItem> items = const [],
      @HiveField(10) final List<Payment> payments = const [],
      @JsonKey(name: 'fabric_status')
      @HiveField(11)
      this.fabricStatus = 'not_received',
      @JsonKey(name: 'fabric_source') @HiveField(12) this.fabricSource,
      @HiveField(13) this.notes,
      @JsonKey(name: 'created_at') @HiveField(14) required this.createdAt,
      @JsonKey(name: 'assigned_to') @HiveField(15) this.assignedTo,
      @JsonKey(name: 'is_outsourced') @HiveField(16) this.isOutsourced = false,
      @JsonKey(readValue: _readCustomerName, includeToJson: false)
      @HiveField(17)
      this.customerName})
      : _images = images,
        _items = items,
        _payments = payments;

  factory _$OrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderModelImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @JsonKey(name: 'user_id')
  @HiveField(1)
  final String userId;
  @override
  @JsonKey(name: 'customer_id')
  @HiveField(2)
  final String customerId;
  @override
  @HiveField(3)
  final String title;
  @override
  @JsonKey()
  @HiveField(4)
  final double price;
  @override
  @JsonKey(name: 'balance_due')
  @HiveField(5)
  final double balanceDue;
  @override
  @JsonKey(name: 'due_date')
  @HiveField(6)
  final DateTime dueDate;
  @override
  @JsonKey()
  @HiveField(7)
  final String status;
  final List<String> _images;
  @override
  @JsonKey()
  @HiveField(8)
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<OrderItem> _items;
  @override
  @JsonKey()
  @HiveField(9)
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<Payment> _payments;
  @override
  @JsonKey()
  @HiveField(10)
  List<Payment> get payments {
    if (_payments is EqualUnmodifiableListView) return _payments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_payments);
  }

  @override
  @JsonKey(name: 'fabric_status')
  @HiveField(11)
  final String fabricStatus;
  @override
  @JsonKey(name: 'fabric_source')
  @HiveField(12)
  final String? fabricSource;
  @override
  @HiveField(13)
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  @HiveField(14)
  final DateTime createdAt;
  @override
  @JsonKey(name: 'assigned_to')
  @HiveField(15)
  final String? assignedTo;
  @override
  @JsonKey(name: 'is_outsourced')
  @HiveField(16)
  final bool isOutsourced;
  @override
  @JsonKey(readValue: _readCustomerName, includeToJson: false)
  @HiveField(17)
  final String? customerName;

  @override
  String toString() {
    return 'OrderModel(id: $id, userId: $userId, customerId: $customerId, title: $title, price: $price, balanceDue: $balanceDue, dueDate: $dueDate, status: $status, images: $images, items: $items, payments: $payments, fabricStatus: $fabricStatus, fabricSource: $fabricSource, notes: $notes, createdAt: $createdAt, assignedTo: $assignedTo, isOutsourced: $isOutsourced, customerName: $customerName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.balanceDue, balanceDue) ||
                other.balanceDue == balanceDue) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._payments, _payments) &&
            (identical(other.fabricStatus, fabricStatus) ||
                other.fabricStatus == fabricStatus) &&
            (identical(other.fabricSource, fabricSource) ||
                other.fabricSource == fabricSource) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.isOutsourced, isOutsourced) ||
                other.isOutsourced == isOutsourced) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      customerId,
      title,
      price,
      balanceDue,
      dueDate,
      status,
      const DeepCollectionEquality().hash(_images),
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_payments),
      fabricStatus,
      fabricSource,
      notes,
      createdAt,
      assignedTo,
      isOutsourced,
      customerName);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderModelImplToJson(
      this,
    );
  }
}

abstract class _OrderModel implements OrderModel {
  const factory _OrderModel(
      {@HiveField(0) required final String id,
      @JsonKey(name: 'user_id') @HiveField(1) required final String userId,
      @JsonKey(name: 'customer_id')
      @HiveField(2)
      required final String customerId,
      @HiveField(3) required final String title,
      @HiveField(4) final double price,
      @JsonKey(name: 'balance_due') @HiveField(5) final double balanceDue,
      @JsonKey(name: 'due_date') @HiveField(6) required final DateTime dueDate,
      @HiveField(7) final String status,
      @HiveField(8) final List<String> images,
      @HiveField(9) final List<OrderItem> items,
      @HiveField(10) final List<Payment> payments,
      @JsonKey(name: 'fabric_status') @HiveField(11) final String fabricStatus,
      @JsonKey(name: 'fabric_source') @HiveField(12) final String? fabricSource,
      @HiveField(13) final String? notes,
      @JsonKey(name: 'created_at')
      @HiveField(14)
      required final DateTime createdAt,
      @JsonKey(name: 'assigned_to') @HiveField(15) final String? assignedTo,
      @JsonKey(name: 'is_outsourced') @HiveField(16) final bool isOutsourced,
      @JsonKey(readValue: _readCustomerName, includeToJson: false)
      @HiveField(17)
      final String? customerName}) = _$OrderModelImpl;

  factory _OrderModel.fromJson(Map<String, dynamic> json) =
      _$OrderModelImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @JsonKey(name: 'user_id')
  @HiveField(1)
  String get userId;
  @override
  @JsonKey(name: 'customer_id')
  @HiveField(2)
  String get customerId;
  @override
  @HiveField(3)
  String get title;
  @override
  @HiveField(4)
  double get price;
  @override
  @JsonKey(name: 'balance_due')
  @HiveField(5)
  double get balanceDue;
  @override
  @JsonKey(name: 'due_date')
  @HiveField(6)
  DateTime get dueDate;
  @override
  @HiveField(7)
  String get status;
  @override
  @HiveField(8)
  List<String> get images;
  @override
  @HiveField(9)
  List<OrderItem> get items;
  @override
  @HiveField(10)
  List<Payment> get payments;
  @override
  @JsonKey(name: 'fabric_status')
  @HiveField(11)
  String get fabricStatus;
  @override
  @JsonKey(name: 'fabric_source')
  @HiveField(12)
  String? get fabricSource;
  @override
  @HiveField(13)
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  @HiveField(14)
  DateTime get createdAt;
  @override
  @JsonKey(name: 'assigned_to')
  @HiveField(15)
  String? get assignedTo;
  @override
  @JsonKey(name: 'is_outsourced')
  @HiveField(16)
  bool get isOutsourced;
  @override
  @JsonKey(readValue: _readCustomerName, includeToJson: false)
  @HiveField(17)
  String? get customerName;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
