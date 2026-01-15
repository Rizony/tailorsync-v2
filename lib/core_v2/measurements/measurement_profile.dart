import 'measurement_value.dart';
import 'measurement_unit.dart';

class MeasurementProfile {
  final String id;
  final String name; // e.g. "Agbada", "Office Shirt"
  final String garmentType;
  final MeasurementUnit unit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final List<MeasurementValue> values;

  const MeasurementProfile({
    required this.id,
    required this.name,
    required this.garmentType,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
    required this.values,
    this.notes,
  });

  MeasurementProfile copyWith({
    String? name,
    String? garmentType,
    MeasurementUnit? unit,
    List<MeasurementValue>? values,
    String? notes,
  }) {
    return MeasurementProfile(
      id: id,
      name: name ?? this.name,
      garmentType: garmentType ?? this.garmentType,
      unit: unit ?? this.unit,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      values: values ?? this.values,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'garmentType': garmentType,
        'unit': unit.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'notes': notes,
        'values': values.map((v) => v.toJson()).toList(),
      };

  factory MeasurementProfile.fromJson(Map<String, dynamic> json) {
    return MeasurementProfile(
      id: json['id'],
      name: json['name'],
      garmentType: json['garmentType'],
      unit: MeasurementUnit.values
          .firstWhere((u) => u.name == json['unit']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      notes: json['notes'],
      values: (json['values'] as List)
          .map((v) => MeasurementValue.fromJson(v))
          .toList(),
    );
  }
}
