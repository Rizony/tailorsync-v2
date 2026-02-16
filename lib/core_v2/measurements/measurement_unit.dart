
enum MeasurementUnit {
  inches,
  centimeters,
}

extension MeasurementUnitSymbol on MeasurementUnit {
  String get symbol {
    switch (this) {
      case MeasurementUnit.centimeters:
        return 'cm';
      case MeasurementUnit.inches:
        return 'in';
    }
  }
}



