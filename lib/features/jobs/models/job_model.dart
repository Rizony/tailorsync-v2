import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'job_model.freezed.dart';
part 'job_model.g.dart';

@freezed
@HiveType(typeId: 1)
class JobItem with _$JobItem {
  const factory JobItem({
    @HiveField(0) required String name,
    @Default(1) @HiveField(1) int quantity,
    @Default(0) @HiveField(2) double price,
  }) = _JobItem;

  factory JobItem.fromJson(Map<String, dynamic> json) => _$JobItemFromJson(json);
}

@freezed
@HiveType(typeId: 2)
class Payment with _$Payment {
  const factory Payment({
    @HiveField(0) required double amount,
    @HiveField(1) required DateTime date,
    @HiveField(2) String? note,
    @JsonKey(name: 'payment_method') @HiveField(3) String? paymentMethod,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}

@freezed
@HiveType(typeId: 3)
class JobModel with _$JobModel {
  const factory JobModel({
    @HiveField(0) required String id,
    @JsonKey(name: 'user_id') @HiveField(1) required String userId,
    @JsonKey(name: 'customer_id') @HiveField(2) required String customerId,
    @HiveField(3) required String title,
    @Default(0) @HiveField(4) double price,
    @JsonKey(name: 'balance_due') @Default(0) @HiveField(5) double balanceDue,
    @JsonKey(name: 'due_date') @HiveField(6) required DateTime dueDate,
    @Default('pending') @HiveField(7) String status,
    @Default([]) @HiveField(8) List<String> images,
    @Default([]) @HiveField(9) List<JobItem> items,
    @Default([]) @HiveField(10) List<Payment> payments,
    @JsonKey(name: 'fabric_status') @Default('not_received') @HiveField(11) String fabricStatus,
    @JsonKey(name: 'fabric_source') @HiveField(12) String? fabricSource,
    @HiveField(13) String? notes,
    @JsonKey(name: 'created_at') @HiveField(14) required DateTime createdAt,
    @JsonKey(name: 'assigned_to') @HiveField(15) String? assignedTo,
    @JsonKey(name: 'is_outsourced') @Default(false) @HiveField(16) bool isOutsourced,
    @JsonKey(readValue: _readCustomerName, includeToJson: false) @HiveField(17) String? customerName,
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
