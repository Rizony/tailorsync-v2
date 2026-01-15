import 'package:tailorsync_v2/core_v2/measurements/measurement_unit.dart';

enum MeasurementField {
  // Upper body
  neck,
  chest,
  shoulder,
  sleeveLength,
  armHole,
  bicep,
  wrist,
  topLength,

  // Lower body
  waist,
  hip,
  thigh,
  knee,
  ankle,
  inseam,
  outseam,
  trouserLength,

  // Traditional / special
  agbadaWidth,
  kaftanLength,
  wrapperLength,
}

extension MeasurementFieldLabel on MeasurementField {
  String get label {
    switch (this) {
      case MeasurementField.neck:
        return 'Neck';
      case MeasurementField.chest:
        return 'Chest';
      case MeasurementField.shoulder:
        return 'Shoulder';
      case MeasurementField.sleeveLength:
        return 'Sleeve Length';
      case MeasurementField.armHole:
        return 'Arm Hole';
      case MeasurementField.bicep:
        return 'Bicep';
      case MeasurementField.wrist:
        return 'Wrist';
      case MeasurementField.topLength:
        return 'Top Length';

      case MeasurementField.waist:
        return 'Waist';
      case MeasurementField.hip:
        return 'Hip';
      case MeasurementField.thigh:
        return 'Thigh';
      case MeasurementField.knee:
        return 'Knee';
      case MeasurementField.ankle:
        return 'Ankle';
      case MeasurementField.inseam:
        return 'Inseam';
      case MeasurementField.outseam:
        return 'Outseam';
      case MeasurementField.trouserLength:
        return 'Trouser Length';

      case MeasurementField.agbadaWidth:
        return 'Agbada Width';
      case MeasurementField.kaftanLength:
        return 'Kaftan Length';
      case MeasurementField.wrapperLength:
        return 'Wrapper Length';
    }
  }
}
extension MeasurementFieldUnit on MeasurementField {
  MeasurementUnit get unit {
    switch (this) {
      // Upper body
      case MeasurementField.neck:
      case MeasurementField.chest:
      case MeasurementField.shoulder:
      case MeasurementField.sleeveLength:
      case MeasurementField.armHole:
      case MeasurementField.bicep:
      case MeasurementField.wrist:
      case MeasurementField.topLength:

      // Lower body
      case MeasurementField.waist:
      case MeasurementField.hip:
      case MeasurementField.thigh:
      case MeasurementField.knee:
      case MeasurementField.ankle:
      case MeasurementField.inseam:
      case MeasurementField.outseam:
      case MeasurementField.trouserLength:

      // Traditional
      case MeasurementField.agbadaWidth:
      case MeasurementField.kaftanLength:
      case MeasurementField.wrapperLength:
        return MeasurementUnit.centimeters;
    }
  }
}