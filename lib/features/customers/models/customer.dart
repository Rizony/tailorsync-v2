// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    String? id,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    String? email,
    @Default({}) Map<String, dynamic> measurements,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'user_id') String? userId,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);

  static const List<String> maleMeasurements = [
    'Neck', 'Shoulder', 'Chest', 'Stomach', 'Top Length', 'Sleeve Length', 
    'Muscle', 'Forearm', 'Wrist', 'Waist', 'Hips', 'Thigh', 'Knee', 
    'Calf', 'Ankle', 'Trouser Length'
  ];

  static const List<String> femaleMeasurements = [
    'Bust', 'Waist', 'Hips', 'Shoulder', 'Sleeve', 'Nipple to Nipple', 
    'Shoulder to Nipple', 'Shoulder to Underbust', 'Shoulder to Waist', 
    'Gown Length', 'Skirt Length', 'Blouse Length', 'Wrapper Length'
  ];
}