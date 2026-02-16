// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

import 'measurement_entry_engine.dart';
import 'garment_type.dart';
import 'measurement_profile.dart';

class MeasurementProfileFactory {
  static const _uuid = Uuid();

  static MeasurementProfile create({
    required GarmentType garment,
  }) {
    return MeasurementProfile(
      id: _uuid.v4(),
      garment: garment,
      measurements:
          MeasurementEntryEngine.initializeProfile(garment),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
