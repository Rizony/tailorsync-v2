import 'package:tailorsync_v2/core_v2/measurements/measurement_unit.dart';

import 'measurement_field.dart';

enum MeasurementConfidence {
  verified,        // measured by tailor
  customerProvided,
  adjustedAfterFitting,
}

class MeasurementValue {
  final MeasurementField field;
  final double value;
  final MeasurementConfidence confidence;

  const MeasurementValue({
    required this.field,
    required this.value,
    required this.confidence,
  });
  MeasurementUnit get unit => field.unit;

  /// ✅ ADD THIS
  MeasurementValue copy() {
    return MeasurementValue(
      field: field,
      value: value,
      confidence: confidence,
    );
  }

  MeasurementValue copyWith({
    double? value,
    MeasurementConfidence? confidence,
  }) {
    return MeasurementValue(
      field: field,
      value: value ?? this.value,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() => {
        'field': field.name,
        'value': value,
        'confidence': confidence.name,
      };

  factory MeasurementValue.fromJson(Map<String, dynamic> json) {
    return MeasurementValue(
      field: MeasurementField.values
          .firstWhere((f) => f.name == json['field']),
      value: (json['value'] as num).toDouble(),
      confidence: MeasurementConfidence.values
          .firstWhere((c) => c.name == json['confidence']),
    );
  }
}
