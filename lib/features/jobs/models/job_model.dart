// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_model.freezed.dart';
part 'job_model.g.dart';

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
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    @JsonKey(name: 'is_outsourced') @Default(false) bool isOutsourced,
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
