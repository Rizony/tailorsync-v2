class SmartMeasurementEngine {
  /// Generates over 50+ body proportions based on 3-5 core inputs.
  static Map<String, dynamic> generateMeasurements({
    required String gender,
    required double height,
    required double chest, // For female, this is Bust
    double? waist,
    double? hip,
    String fitType = 'Regular', // 'Slim', 'Regular', 'Loose'
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
    results['Shoulder Slope'] = 2.5;

    // Armhole
    final double armholeDepth = (c / 6) + 7;
    results['Armhole Depth'] = r(armholeDepth);
    results['Armhole Round'] = r(c * 0.45);

    // Chest Width
    results['Chest Width'] = r(c / 2);
    results['Across Back'] = r((c / 4) - 1);
    results['Across Front'] = r((c / 4) - 1.5);

    // --- 2. Sleeve Measurement Generator ---
    final double bicep = c * 0.33;
    results['Bicep'] = r(bicep);
    results['Elbow'] = r(bicep - 3);
    results['Wrist'] = r(bicep * 0.55);
    results['Sleeve Length'] = r(height * 0.36);
    results['Sleeve Cap Height'] = r(armholeDepth * 0.7);

    // --- 3. Torso Measurements ---
    final double backLength = height * 0.25;
    results['Back Length'] = r(backLength);
    results['Front Length'] = r(backLength + 2);
    results['Shirt Length'] = r(height * 0.45);

    // --- 4. Female Body Logic ---
    if (gender == 'Female') {
      final bustDepth = c / 6;
      results['Bust Span'] = r(c / 8);
      results['Bust Depth'] = r(bustDepth);
      results['Under Bust'] = r(c - 5);
      results['Princess Line'] = r(bustDepth + 3);
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
    final double crotchDepth = (h / 4) + 2;
    results['Crotch Depth'] = r(crotchDepth);
    
    final double trouserLength = height * 0.50;
    results['Trouser Length'] = r(trouserLength);
    
    results['Inseam'] = r(trouserLength - crotchDepth);
    results['Rise'] = r(crotchDepth + 3);

    // --- 7. Native Wear Generator (African) ---
    results['Native Length'] = r(height * 0.50);
    results['Agbada Width'] = r(c * 2);
    results['Agbada Sleeve'] = r(height * 0.25);

    // --- 8. Ease Engine (Fit Type) ---
    double chestEase = 6;
    double waistEase = 5;
    double hipEase = 5;

    switch (fitType) {
      case 'Slim':
        chestEase = 4;
        waistEase = 3;
        hipEase = 3;
        break;
      case 'Loose':
        chestEase = 10;
        waistEase = 8;
        hipEase = 8;
        break;
      case 'Regular':
      default:
        chestEase = 6;
        waistEase = 5;
        hipEase = 5;
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
