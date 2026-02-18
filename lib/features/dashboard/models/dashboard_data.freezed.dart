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
  int get activeJobs => throw _privateConstructorUsedError;
  int get completedJobs => throw _privateConstructorUsedError;
  int get totalCustomers => throw _privateConstructorUsedError;
  double get totalRevenue => throw _privateConstructorUsedError;
  List<JobModel> get recentJobs => throw _privateConstructorUsedError;
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
      {int activeJobs,
      int completedJobs,
      int totalCustomers,
      double totalRevenue,
      List<JobModel> recentJobs,
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
    Object? activeJobs = null,
    Object? completedJobs = null,
    Object? totalCustomers = null,
    Object? totalRevenue = null,
    Object? recentJobs = null,
    Object? userName = null,
  }) {
    return _then(_value.copyWith(
      activeJobs: null == activeJobs
          ? _value.activeJobs
          : activeJobs // ignore: cast_nullable_to_non_nullable
              as int,
      completedJobs: null == completedJobs
          ? _value.completedJobs
          : completedJobs // ignore: cast_nullable_to_non_nullable
              as int,
      totalCustomers: null == totalCustomers
          ? _value.totalCustomers
          : totalCustomers // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      recentJobs: null == recentJobs
          ? _value.recentJobs
          : recentJobs // ignore: cast_nullable_to_non_nullable
              as List<JobModel>,
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
      {int activeJobs,
      int completedJobs,
      int totalCustomers,
      double totalRevenue,
      List<JobModel> recentJobs,
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
    Object? activeJobs = null,
    Object? completedJobs = null,
    Object? totalCustomers = null,
    Object? totalRevenue = null,
    Object? recentJobs = null,
    Object? userName = null,
  }) {
    return _then(_$DashboardDataImpl(
      activeJobs: null == activeJobs
          ? _value.activeJobs
          : activeJobs // ignore: cast_nullable_to_non_nullable
              as int,
      completedJobs: null == completedJobs
          ? _value.completedJobs
          : completedJobs // ignore: cast_nullable_to_non_nullable
              as int,
      totalCustomers: null == totalCustomers
          ? _value.totalCustomers
          : totalCustomers // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      recentJobs: null == recentJobs
          ? _value._recentJobs
          : recentJobs // ignore: cast_nullable_to_non_nullable
              as List<JobModel>,
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
      {required this.activeJobs,
      required this.completedJobs,
      required this.totalCustomers,
      required this.totalRevenue,
      required final List<JobModel> recentJobs,
      required this.userName})
      : _recentJobs = recentJobs;

  @override
  final int activeJobs;
  @override
  final int completedJobs;
  @override
  final int totalCustomers;
  @override
  final double totalRevenue;
  final List<JobModel> _recentJobs;
  @override
  List<JobModel> get recentJobs {
    if (_recentJobs is EqualUnmodifiableListView) return _recentJobs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentJobs);
  }

  @override
  final String userName;

  @override
  String toString() {
    return 'DashboardData(activeJobs: $activeJobs, completedJobs: $completedJobs, totalCustomers: $totalCustomers, totalRevenue: $totalRevenue, recentJobs: $recentJobs, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardDataImpl &&
            (identical(other.activeJobs, activeJobs) ||
                other.activeJobs == activeJobs) &&
            (identical(other.completedJobs, completedJobs) ||
                other.completedJobs == completedJobs) &&
            (identical(other.totalCustomers, totalCustomers) ||
                other.totalCustomers == totalCustomers) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            const DeepCollectionEquality()
                .equals(other._recentJobs, _recentJobs) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      activeJobs,
      completedJobs,
      totalCustomers,
      totalRevenue,
      const DeepCollectionEquality().hash(_recentJobs),
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
      {required final int activeJobs,
      required final int completedJobs,
      required final int totalCustomers,
      required final double totalRevenue,
      required final List<JobModel> recentJobs,
      required final String userName}) = _$DashboardDataImpl;

  @override
  int get activeJobs;
  @override
  int get completedJobs;
  @override
  int get totalCustomers;
  @override
  double get totalRevenue;
  @override
  List<JobModel> get recentJobs;
  @override
  String get userName;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
