import 'measurement_field.dart';
import 'garment_type.dart';

class GarmentMeasurementSchema {
  final GarmentType garment;
  final List<MeasurementField> fields;

  const GarmentMeasurementSchema({
    required this.garment,
    required this.fields,
  });
}

const garmentSchemas = [
  GarmentMeasurementSchema(
    garment: GarmentType.shirt,
    fields: [
      MeasurementField.neck,
      MeasurementField.shoulder,
      MeasurementField.chest,
      MeasurementField.sleeveLength,
      MeasurementField.armHole,
      MeasurementField.bicep,
      MeasurementField.wrist,
      MeasurementField.topLength,
    ],
  ),

  GarmentMeasurementSchema(
    garment: GarmentType.trousers,
    fields: [
      MeasurementField.waist,
      MeasurementField.hip,
      MeasurementField.thigh,
      MeasurementField.knee,
      MeasurementField.ankle,
      MeasurementField.inseam,
      MeasurementField.trouserLength,
    ],
  ),

  GarmentMeasurementSchema(
    garment: GarmentType.kaftan,
    fields: [
      MeasurementField.neck,
      MeasurementField.shoulder,
      MeasurementField.chest,
      MeasurementField.sleeveLength,
      MeasurementField.kaftanLength,
    ],
  ),

  GarmentMeasurementSchema(
    garment: GarmentType.agbada,
    fields: [
      MeasurementField.neck,
      MeasurementField.shoulder,
      MeasurementField.chest,
      MeasurementField.agbadaWidth,
      MeasurementField.topLength,
    ],
  ),
];
  