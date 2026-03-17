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
    'Sleeve': MeasurementGuide(
      title: 'Sleeve Length',
      description: 'Measure from the shoulder point down to the wrist with the arm slightly bent.',
      imagePath: 'assets/guides/sleeve_length_guide.png',
    ),
    'Inseam': MeasurementGuide(
      title: 'Inseam',
      description: 'Measure from the crotch point down to the ankle along the inside of the leg.',
      imagePath: 'assets/guides/inseam_guide.png',
    ),
    'Neck': MeasurementGuide(
      title: 'Neck Round',
      description: 'Measure around the base of the neck where a shirt collar would sit.',
      imagePath: 'assets/guides/shoulder_measurement_guide.png',
    ),
    'Bicep': MeasurementGuide(
      title: 'Bicep / Upper Arm',
      description: 'Measure around the widest part of the upper arm.',
      imagePath: 'assets/guides/sleeve_length_guide.png',
    ),
    'Thigh': MeasurementGuide(
      title: 'Thigh',
      description: 'Measure around the widest part of the thigh.',
      imagePath: 'assets/guides/hip_measurement_guide.png',
    ),
    'Height': MeasurementGuide(
      title: 'Body Height',
      description: 'Measure total height from the floor to the top of the head while standing straight.',
      imagePath: 'assets/guides/inseam_guide.png',
    ),
    // Fallback or generic guide for others
    'Default': MeasurementGuide(
      title: 'Tailoring Guide',
      description: 'Follow the on-screen prompts to capture accurate body proportions for a perfect fit.',
      imagePath: 'assets/guides/chest_measurement_guide.png',
    ),
  };

  static MeasurementGuide getGuide(String key) {
    if (key.contains('Chest') || key.contains('Bust')) return guides['Chest']!;
    if (key.contains('Waist')) return guides['Waist']!;
    if (key.contains('Hip')) return guides['Hip']!;
    if (key.contains('Shoulder')) return guides['Shoulder']!;
    if (key.contains('Sleeve')) return guides['Sleeve']!;
    if (key.contains('Inseam')) return guides['Inseam']!;
    if (key.contains('Neck')) return guides['Neck']!;
    if (key.contains('Bicep')) return guides['Bicep']!;
    if (key.contains('Thigh')) return guides['Thigh']!;
    if (key.contains('Height')) return guides['Height']!;
    return guides['Default']!;
  }
}
