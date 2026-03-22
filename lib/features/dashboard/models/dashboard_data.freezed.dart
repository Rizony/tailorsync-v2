// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DashboardData {
  int get activeOrders => throw _privateConstructorUsedError;
  int get completedOrders => throw _privateConstructorUsedError;
  int get totalCustomers => throw _privateConstructorUsedError;
  double get totalRevenue => throw _privateConstructorUsedError;
  List<OrderModel> get recentOrders => throw _privateConstructorUsedError;
  List<OrderModel> get urgentOrders => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardDataCopyWith<DashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardDataCopyWith<$Res> {
  factory $DashboardDataCopyWith(
          DashboardData value, $Res Function(DashboardData) then) =
      _$DashboardDataCopyWithImpl<$Res, DashboardData>;
  @useResult
  $Res call(
      {int activeOrders,
      int completedOrders,
      int totalCustomers,
      double totalRevenue,
      List<OrderModel> recentOrders,
      List<OrderModel> urgentOrders,
      String userName});
}

/// @nodoc
class _$DashboardDataCopyWithImpl<$Res, $Val extends DashboardData>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeOrders = null,
    Object? completedOrders = null,
    Object? totalCustomers = null,
    Object? totalRevenue = null,
    Object? recentOrders = null,
    Object? urgentOrders = null,
    Object? userName = null,
  }) {
    return _then(_value.copyWith(
      activeOrders: null == activeOrders
          ? _value.activeOrders
          : activeOrders // ignore: cast_nullable_to_non_nullable
              as int,
      completedOrders: null == completedOrders
          ? _value.completedOrders
          : completedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalCustomers: null == totalCustomers
          ? _value.totalCustomers
          : totalCustomers // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      recentOrders: null == recentOrders
          ? _value.recentOrders
          : recentOrders // ignore: cast_nullable_to_non_nullable
              as List<OrderModel>,
      urgentOrders: null == urgentOrders
          ? _value.urgentOrders
          : urgentOrders // ignore: cast_nullable_to_non_nullable
              as List<OrderModel>,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardDataImplCopyWith<$Res>
    implements $DashboardDataCopyWith<$Res> {
  factory _$$DashboardDataImplCopyWith(
          _$DashboardDataImpl value, $Res Function(_$DashboardDataImpl) then) =
      __$$DashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int activeOrders,
      int completedOrders,
      int totalCustomers,
      double totalRevenue,
      List<OrderModel> recentOrders,
      List<OrderModel> urgentOrders,
      String userName});
}

/// @nodoc
class __$$DashboardDataImplCopyWithImpl<$Res>
    extends _$DashboardDataCopyWithImpl<$Res, _$DashboardDataImpl>
    implements _$$DashboardDataImplCopyWith<$Res> {
  __$$DashboardDataImplCopyWithImpl(
      _$DashboardDataImpl _value, $Res Function(_$DashboardDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeOrders = null,
    Object? completedOrders = null,
    Object? totalCustomers = null,
    Object? totalRevenue = null,
    Object? recentOrders = null,
    Object? urgentOrders = null,
    Object? userName = null,
  }) {
    return _then(_$DashboardDataImpl(
      activeOrders: null == activeOrders
          ? _value.activeOrders
          : activeOrders // ignore: cast_nullable_to_non_nullable
              as int,
      completedOrders: null == completedOrders
          ? _value.completedOrders
          : completedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalCustomers: null == totalCustomers
          ? _value.totalCustomers
          : totalCustomers // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      recentOrders: null == recentOrders
          ? _value._recentOrders
          : recentOrders // ignore: cast_nullable_to_non_nullable
              as List<OrderModel>,
      urgentOrders: null == urgentOrders
          ? _value._urgentOrders
          : urgentOrders // ignore: cast_nullable_to_non_nullable
              as List<OrderModel>,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DashboardDataImpl implements _DashboardData {
  const _$DashboardDataImpl(
      {required this.activeOrders,
      required this.completedOrders,
      required this.totalCustomers,
      required this.totalRevenue,
      required final List<OrderModel> recentOrders,
      required final List<OrderModel> urgentOrders,
      required this.userName})
      : _recentOrders = recentOrders,
        _urgentOrders = urgentOrders;

  @override
  final int activeOrders;
  @override
  final int completedOrders;
  @override
  final int totalCustomers;
  @override
  final double totalRevenue;
  final List<OrderModel> _recentOrders;
  @override
  List<OrderModel> get recentOrders {
    if (_recentOrders is EqualUnmodifiableListView) return _recentOrders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentOrders);
  }

  final List<OrderModel> _urgentOrders;
  @override
  List<OrderModel> get urgentOrders {
    if (_urgentOrders is EqualUnmodifiableListView) return _urgentOrders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_urgentOrders);
  }

  @override
  final String userName;

  @override
  String toString() {
    return 'DashboardData(activeOrders: $activeOrders, completedOrders: $completedOrders, totalCustomers: $totalCustomers, totalRevenue: $totalRevenue, recentOrders: $recentOrders, urgentOrders: $urgentOrders, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardDataImpl &&
            (identical(other.activeOrders, activeOrders) ||
                other.activeOrders == activeOrders) &&
            (identical(other.completedOrders, completedOrders) ||
                other.completedOrders == completedOrders) &&
            (identical(other.totalCustomers, totalCustomers) ||
                other.totalCustomers == totalCustomers) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            const DeepCollectionEquality()
                .equals(other._recentOrders, _recentOrders) &&
            const DeepCollectionEquality()
                .equals(other._urgentOrders, _urgentOrders) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      activeOrders,
      completedOrders,
      totalCustomers,
      totalRevenue,
      const DeepCollectionEquality().hash(_recentOrders),
      const DeepCollectionEquality().hash(_urgentOrders),
      userName);

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      __$$DashboardDataImplCopyWithImpl<_$DashboardDataImpl>(this, _$identity);
}

abstract class _DashboardData implements DashboardData {
  const factory _DashboardData(
      {required final int activeOrders,
      required final int completedOrders,
      required final int totalCustomers,
      required final double totalRevenue,
      required final List<OrderModel> recentOrders,
      required final List<OrderModel> urgentOrders,
      required final String userName}) = _$DashboardDataImpl;

  @override
  int get activeOrders;
  @override
  int get completedOrders;
  @override
  int get totalCustomers;
  @override
  double get totalRevenue;
  @override
  List<OrderModel> get recentOrders;
  @override
  List<OrderModel> get urgentOrders;
  @override
  String get userName;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
