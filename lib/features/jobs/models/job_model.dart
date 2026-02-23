// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_model.freezed.dart';
part 'job_model.g.dart';

@freezed
class JobItem with _$JobItem {
  const factory JobItem({
    required String name,
    @Default(1) int quantity,
    @Default(0) double price,
  }) = _JobItem;

  factory JobItem.fromJson(Map<String, dynamic> json) => _$JobItemFromJson(json);
}

@freezed
class JobModel with _$JobModel {
  const factory JobModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'customer_id') required String customerId,
    required String title,
    @Default(0) double price,
    @JsonKey(name: 'balance_due') @Default(0) double balanceDue,
    @JsonKey(name: 'due_date') required DateTime dueDate,
    @Default('pending') String status,
    @Default([]) List<String> images,
    @Default([]) List<JobItem> items, // Added items list
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    @JsonKey(name: 'is_outsourced') @Default(false) bool isOutsourced,
    @JsonKey(readValue: _readCustomerName, includeToJson: false) String? customerName,
  }) = _JobModel;

  factory JobModel.fromJson(Map<String, dynamic> json) => _$JobModelFromJson(json);

  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusFitting = 'fitting';
  static const String statusAdjustment = 'adjustment';
  static const String statusCompleted = 'completed'; // Ready for pickup
  static const String statusDelivered = 'delivered'; // Picked up
  static const String statusCanceled = 'canceled';
  static const String statusQuote = 'quote';

  static const List<String> activeStatuses = [
    statusPending,
    statusInProgress,
    statusFitting,
    statusAdjustment,
  ];

  static const List<String> allStatuses = [
    statusPending,
    statusInProgress,
    statusFitting,
    statusAdjustment,
    statusCompleted,
    statusDelivered,
    statusCanceled,
    statusQuote,
  ];
}

Object? _readCustomerName(Map map, String key) {
  if (map['customers'] is Map) {
    return map['customers']['full_name'];
  }
  return null;
}
