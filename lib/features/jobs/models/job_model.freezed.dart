// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

JobItem _$JobItemFromJson(Map<String, dynamic> json) {
  return _JobItem.fromJson(json);
}

/// @nodoc
mixin _$JobItem {
  String get name => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;

  /// Serializes this JobItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobItemCopyWith<JobItem> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobItemCopyWith<$Res> {
  factory $JobItemCopyWith(JobItem value, $Res Function(JobItem) then) =
      _$JobItemCopyWithImpl<$Res, JobItem>;
  @useResult
  $Res call({String name, int quantity, double price});
}

/// @nodoc
class _$JobItemCopyWithImpl<$Res, $Val extends JobItem>
    implements $JobItemCopyWith<$Res> {
  _$JobItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobItem
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
abstract class _$$JobItemImplCopyWith<$Res> implements $JobItemCopyWith<$Res> {
  factory _$$JobItemImplCopyWith(
          _$JobItemImpl value, $Res Function(_$JobItemImpl) then) =
      __$$JobItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int quantity, double price});
}

/// @nodoc
class __$$JobItemImplCopyWithImpl<$Res>
    extends _$JobItemCopyWithImpl<$Res, _$JobItemImpl>
    implements _$$JobItemImplCopyWith<$Res> {
  __$$JobItemImplCopyWithImpl(
      _$JobItemImpl _value, $Res Function(_$JobItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of JobItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? price = null,
  }) {
    return _then(_$JobItemImpl(
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
class _$JobItemImpl implements _JobItem {
  const _$JobItemImpl({required this.name, this.quantity = 1, this.price = 0});

  factory _$JobItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobItemImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final int quantity;
  @override
  @JsonKey()
  final double price;

  @override
  String toString() {
    return 'JobItem(name: $name, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, quantity, price);

  /// Create a copy of JobItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobItemImplCopyWith<_$JobItemImpl> get copyWith =>
      __$$JobItemImplCopyWithImpl<_$JobItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobItemImplToJson(
      this,
    );
  }
}

abstract class _JobItem implements JobItem {
  const factory _JobItem(
      {required final String name,
      final int quantity,
      final double price}) = _$JobItemImpl;

  factory _JobItem.fromJson(Map<String, dynamic> json) = _$JobItemImpl.fromJson;

  @override
  String get name;
  @override
  int get quantity;
  @override
  double get price;

  /// Create a copy of JobItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobItemImplCopyWith<_$JobItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JobModel _$JobModelFromJson(Map<String, dynamic> json) {
  return _JobModel.fromJson(json);
}

/// @nodoc
mixin _$JobModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String get customerId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'balance_due')
  double get balanceDue => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  DateTime get dueDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  List<JobItem> get items =>
      throw _privateConstructorUsedError; // Added items list
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'assigned_to')
  String? get assignedTo => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_outsourced')
  bool get isOutsourced => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readCustomerName, includeToJson: false)
  String? get customerName => throw _privateConstructorUsedError;

  /// Serializes this JobModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobModelCopyWith<JobModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobModelCopyWith<$Res> {
  factory $JobModelCopyWith(JobModel value, $Res Function(JobModel) then) =
      _$JobModelCopyWithImpl<$Res, JobModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'customer_id') String customerId,
      String title,
      double price,
      @JsonKey(name: 'balance_due') double balanceDue,
      @JsonKey(name: 'due_date') DateTime dueDate,
      String status,
      List<String> images,
      List<JobItem> items,
      String? notes,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'assigned_to') String? assignedTo,
      @JsonKey(name: 'is_outsourced') bool isOutsourced,
      @JsonKey(readValue: _readCustomerName, includeToJson: false)
      String? customerName});
}

/// @nodoc
class _$JobModelCopyWithImpl<$Res, $Val extends JobModel>
    implements $JobModelCopyWith<$Res> {
  _$JobModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobModel
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
              as List<JobItem>,
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
abstract class _$$JobModelImplCopyWith<$Res>
    implements $JobModelCopyWith<$Res> {
  factory _$$JobModelImplCopyWith(
          _$JobModelImpl value, $Res Function(_$JobModelImpl) then) =
      __$$JobModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'customer_id') String customerId,
      String title,
      double price,
      @JsonKey(name: 'balance_due') double balanceDue,
      @JsonKey(name: 'due_date') DateTime dueDate,
      String status,
      List<String> images,
      List<JobItem> items,
      String? notes,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'assigned_to') String? assignedTo,
      @JsonKey(name: 'is_outsourced') bool isOutsourced,
      @JsonKey(readValue: _readCustomerName, includeToJson: false)
      String? customerName});
}

/// @nodoc
class __$$JobModelImplCopyWithImpl<$Res>
    extends _$JobModelCopyWithImpl<$Res, _$JobModelImpl>
    implements _$$JobModelImplCopyWith<$Res> {
  __$$JobModelImplCopyWithImpl(
      _$JobModelImpl _value, $Res Function(_$JobModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of JobModel
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
    Object? notes = freezed,
    Object? createdAt = null,
    Object? assignedTo = freezed,
    Object? isOutsourced = null,
    Object? customerName = freezed,
  }) {
    return _then(_$JobModelImpl(
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
              as List<JobItem>,
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
class _$JobModelImpl implements _JobModel {
  const _$JobModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'customer_id') required this.customerId,
      required this.title,
      this.price = 0,
      @JsonKey(name: 'balance_due') this.balanceDue = 0,
      @JsonKey(name: 'due_date') required this.dueDate,
      this.status = 'pending',
      final List<String> images = const [],
      final List<JobItem> items = const [],
      this.notes,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'assigned_to') this.assignedTo,
      @JsonKey(name: 'is_outsourced') this.isOutsourced = false,
      @JsonKey(readValue: _readCustomerName, includeToJson: false)
      this.customerName})
      : _images = images,
        _items = items;

  factory _$JobModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  @override
  final String title;
  @override
  @JsonKey()
  final double price;
  @override
  @JsonKey(name: 'balance_due')
  final double balanceDue;
  @override
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  @override
  @JsonKey()
  final String status;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<JobItem> _items;
  @override
  @JsonKey()
  List<JobItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

// Added items list
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'assigned_to')
  final String? assignedTo;
  @override
  @JsonKey(name: 'is_outsourced')
  final bool isOutsourced;
  @override
  @JsonKey(readValue: _readCustomerName, includeToJson: false)
  final String? customerName;

  @override
  String toString() {
    return 'JobModel(id: $id, userId: $userId, customerId: $customerId, title: $title, price: $price, balanceDue: $balanceDue, dueDate: $dueDate, status: $status, images: $images, items: $items, notes: $notes, createdAt: $createdAt, assignedTo: $assignedTo, isOutsourced: $isOutsourced, customerName: $customerName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobModelImpl &&
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
      notes,
      createdAt,
      assignedTo,
      isOutsourced,
      customerName);

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobModelImplCopyWith<_$JobModelImpl> get copyWith =>
      __$$JobModelImplCopyWithImpl<_$JobModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobModelImplToJson(
      this,
    );
  }
}

abstract class _JobModel implements JobModel {
  const factory _JobModel(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'customer_id') required final String customerId,
      required final String title,
      final double price,
      @JsonKey(name: 'balance_due') final double balanceDue,
      @JsonKey(name: 'due_date') required final DateTime dueDate,
      final String status,
      final List<String> images,
      final List<JobItem> items,
      final String? notes,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'assigned_to') final String? assignedTo,
      @JsonKey(name: 'is_outsourced') final bool isOutsourced,
      @JsonKey(readValue: _readCustomerName, includeToJson: false)
      final String? customerName}) = _$JobModelImpl;

  factory _JobModel.fromJson(Map<String, dynamic> json) =
      _$JobModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'customer_id')
  String get customerId;
  @override
  String get title;
  @override
  double get price;
  @override
  @JsonKey(name: 'balance_due')
  double get balanceDue;
  @override
  @JsonKey(name: 'due_date')
  DateTime get dueDate;
  @override
  String get status;
  @override
  List<String> get images;
  @override
  List<JobItem> get items; // Added items list
  @override
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'assigned_to')
  String? get assignedTo;
  @override
  @JsonKey(name: 'is_outsourced')
  bool get isOutsourced;
  @override
  @JsonKey(readValue: _readCustomerName, includeToJson: false)
  String? get customerName;

  /// Create a copy of JobModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobModelImplCopyWith<_$JobModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
