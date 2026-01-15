
enum MeasurementUnit {
  inches,
  centimeters,
}

extension MeasurementUnitLabel on MeasurementUnit {
  String get symbol {
    switch (this) {
      case MeasurementUnit.inches:
        return 'in';
      case MeasurementUnit.centimeters:
        return 'cm';
    }
  }
}


