import 'measurement_field.dart';
import 'measurement_value.dart';
import 'garment_measurement_schema.dart';
import 'garment_type.dart';

class MeasurementEntryEngine {
  static List<MeasurementField> fieldsForGarment(GarmentType garment) {
    return garmentSchemas
        .firstWhere((s) => s.garment == garment)
        .fields;
  }

  static MeasurementValue createEmptyValue(
    MeasurementField field,
  ) {
    return MeasurementValue(
      field: field,
      value: 0,
      confidence: MeasurementConfidence.customerProvided,
    );
  }

  static bool isValidValue(double value) {
    return value > 0 && value < 500; // sanity limit
  }

  static List<MeasurementValue> initializeProfile(
    GarmentType garment,
  ) {
    return fieldsForGarment(garment)
        .map(createEmptyValue)
        .toList();
  }

  static MeasurementValue updateValue({
    required MeasurementValue current,
    required double newValue,
  }) {
    if (!isValidValue(newValue)) {
      throw ArgumentError('Invalid measurement value');
    }

    return current.copyWith(
      value: newValue,
      confidence: MeasurementConfidence.verified,
    );
  }
}
