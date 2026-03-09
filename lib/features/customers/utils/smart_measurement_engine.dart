class SmartMeasurementEngine {
  /// Generates over 50+ body proportions based on 3-5 core inputs.
  static Map<String, dynamic> generateMeasurements({
    required String gender,
    required double height,
    required double chest, // For female, this is Bust
    double? waist,
    double? hip,
    String fitType = 'Regular', // 'Slim', 'Regular', 'Loose'
    bool isCm = true,
  }) {
    final Map<String, dynamic> results = {};

    // Core ratios if waist/hip is missing
    final double w = waist ?? (chest * 0.85);
    final double h = hip ?? (chest * 1.02);
    final double c = chest;

    // Helper to round to 1 decimal place
    double r(double val) => (val * 10).roundToDouble() / 10;

    // --- 1. Upper Body Generation ---
    // Neck
    final double neckWidth = c / 12;
    results['Neck Width'] = r(neckWidth);
    results['Neck Round'] = r(c * 0.37);
    results['Neck Depth Front'] = r(neckWidth * 2);
    results['Neck Depth Back'] = r(neckWidth / 2);

    // Shoulder
    results['Shoulder'] = r(c * 0.26);
    results['Shoulder Slope'] = r(isCm ? 2.5 : 1.0);

    // Armhole
    final double armholeOffset = isCm ? 7.0 : 2.75;
    final double armholeDepth = (c / 6) + armholeOffset;
    results['Armhole Depth'] = r(armholeDepth);
    results['Armhole Round'] = r(c * 0.45);

    // Chest Width
    results['Chest Width'] = r(c / 2);
    results['Across Back'] = r((c / 4) - (isCm ? 1.0 : 0.4));
    results['Across Front'] = r((c / 4) - (isCm ? 1.5 : 0.6));

    // --- 2. Sleeve Measurement Generator ---
    final double bicep = c * 0.33;
    results['Bicep'] = r(bicep);
    results['Elbow'] = r(bicep - (isCm ? 3.0 : 1.2));
    results['Wrist'] = r(bicep * 0.55);
    results['Sleeve Length'] = r(height * 0.36);
    results['Sleeve Cap Height'] = r(armholeDepth * 0.7);

    // --- 3. Torso Measurements ---
    final double backLength = height * 0.25;
    results['Back Length'] = r(backLength);
    results['Front Length'] = r(backLength + (isCm ? 2.0 : 0.8));
    results['Shirt Length'] = r(height * 0.45);

    // --- 4. Female Body Logic ---
    if (gender == 'Female') {
      final bustDepth = c / 6;
      results['Bust Span'] = r(c / 8);
      results['Bust Depth'] = r(bustDepth);
      results['Under Bust'] = r(c - (isCm ? 5.0 : 2.0));
      results['Princess Line'] = r(bustDepth + (isCm ? 3.0 : 1.2));
    }

    // --- 5. Lower Body Generator ---
    results['Waist Width'] = r(w / 2);
    results['Hip Width'] = r(h / 2);

    final double thigh = h * 0.62;
    results['Thigh'] = r(thigh);

    final double knee = thigh * 0.75;
    results['Knee'] = r(knee);

    final double calf = thigh * 0.70;
    results['Calf'] = r(calf);

    results['Ankle'] = r(calf * 0.60);

    // --- 6. Trouser Generator ---
    final double crotchDepth = (h / 4) + (isCm ? 2.0 : 0.8);
    results['Crotch Depth'] = r(crotchDepth);

    final double trouserLength = height * 0.50;
    results['Trouser Length'] = r(trouserLength);

    results['Inseam'] = r(trouserLength - crotchDepth);
    results['Rise'] = r(crotchDepth + (isCm ? 3.0 : 1.2));

    // --- 7. Native Wear Generator (African) ---
    results['Native Length'] = r(height * 0.50);
    results['Agbada Width'] = r(c * 2);
    results['Agbada Sleeve'] = r(height * 0.25);

    // --- 8. Ease Engine (Fit Type) ---
    double chestEase = isCm ? 6 : 2.4;
    double waistEase = isCm ? 5 : 2.0;
    double hipEase = isCm ? 5 : 2.0;

    switch (fitType) {
      case 'Slim':
        chestEase = isCm ? 4 : 1.6;
        waistEase = isCm ? 3 : 1.2;
        hipEase = isCm ? 3 : 1.2;
        break;
      case 'Loose':
        chestEase = isCm ? 10 : 4.0;
        waistEase = isCm ? 8 : 3.1;
        hipEase = isCm ? 8 : 3.1;
        break;
      case 'Regular':
      default:
        chestEase = isCm ? 6 : 2.4;
        waistEase = isCm ? 5 : 2.0;
        hipEase = isCm ? 5 : 2.0;
        break;
    }

    results['Final Chest'] = r(c + chestEase);
    results['Final Waist'] = r(w + waistEase);
    results['Final Hip'] = r(h + hipEase);

    // Include the original inputs too for clarity
    results['Input Height'] = height;
    results['Input Chest'] = c;
    results['Input Waist'] = w;
    results['Input Hip'] = h;

    return results;
  }
}
