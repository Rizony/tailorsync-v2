import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
@HiveType(typeId: 0)
class Customer with _$Customer {
  const factory Customer({
    @HiveField(0) String? id,
    @JsonKey(name: 'full_name') @HiveField(1) required String fullName,
    @JsonKey(name: 'phone_number') @HiveField(2) String? phoneNumber,
    @HiveField(3) String? email,
    @JsonKey(name: 'photo_url') @HiveField(4) String? photoUrl,
    @Default({}) @HiveField(5) Map<String, dynamic> measurements,
    @JsonKey(name: 'created_at') @HiveField(6) DateTime? createdAt,
    @JsonKey(name: 'user_id') @HiveField(7) String? userId,
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