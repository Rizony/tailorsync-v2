import '../measurements/garment_type.dart';

class GarmentPricing {
  static double laborCost(GarmentType garment) {
    switch (garment) {
      case GarmentType.shirt:
        return 10.0;
      case GarmentType.trousers:
        return 12.0;
      case GarmentType.kaftan:
        return 18.0;
      case GarmentType.suit:
        return 35.0;
      case GarmentType.agbada:
        return 25.0;
      case GarmentType.dress:
        return 20.0;
      case GarmentType.skirt:
        return 15.0;
      case GarmentType.blouse:
        return 20.0;
      case GarmentType.coat:
        return 25.0;
      case GarmentType.jacket:
        return 20.0;
      case GarmentType.other:
        return 15.0;
    }
  }
}
