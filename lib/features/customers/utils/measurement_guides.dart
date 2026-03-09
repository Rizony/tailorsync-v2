class MeasurementGuide {
  final String title;
  final String description;
  final String imagePath;

  MeasurementGuide({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class BeSafeTailorGuides {
  static final Map<String, MeasurementGuide> guides = {
    'Chest': MeasurementGuide(
      title: 'Chest Measurement',
      description: 'Measure around the fullest part of the chest, keeping the tape horizontal under the arms.',
      imagePath: 'assets/guides/chest_measurement_guide.png',
    ),
    'Bust': MeasurementGuide(
      title: 'Bust Measurement',
      description: 'Measure around the fullest part of the bust, ensuring the tape is straight across the back.',
      imagePath: 'assets/guides/chest_measurement_guide.png',
    ),
    'Waist': MeasurementGuide(
      title: 'Waist Measurement',
      description: 'Measure around the narrowest part of the waistline, usually just above the navel.',
      imagePath: 'assets/guides/waist_measurement_guide.png',
    ),
    'Hip': MeasurementGuide(
      title: 'Hip Measurement',
      description: 'Measure around the fullest part of the hips and buttocks.',
      imagePath: 'assets/guides/hip_measurement_guide.png',
    ),
    'Shoulder': MeasurementGuide(
      title: 'Shoulder Width',
      description: 'Measure from one shoulder point to the other across the top of the back.',
      imagePath: 'assets/guides/shoulder_measurement_guide.png',
    ),
    // Fallback or generic guide for others
    'Default': MeasurementGuide(
      title: 'Tailoring Guide',
      description: 'Follow the on-screen prompts to capture accurate body proportions for a perfect fit.',
      imagePath: 'assets/logo.png', // Fallback to logo or a generic icon
    ),
  };

  static MeasurementGuide getGuide(String key) {
    if (key.contains('Chest') || key.contains('Bust')) return guides['Chest']!;
    if (key.contains('Waist')) return guides['Waist']!;
    if (key.contains('Hip')) return guides['Hip']!;
    if (key.contains('Shoulder')) return guides['Shoulder']!;
    return guides['Default']!;
  }
}
