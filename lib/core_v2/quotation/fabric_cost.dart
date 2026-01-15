class FabricCost {
  final String fabricName;
  final double meters;
  final double pricePerMeter;

  const FabricCost({
    required this.fabricName,
    required this.meters,
    required this.pricePerMeter,
  });

  double get total => meters * pricePerMeter;
}
