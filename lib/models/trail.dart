class Trail {
  final String id;
  final String name;
  final String description;
  final double distanceMeters;
  final int durationSeconds;
  final String district;
  final String difficultyLevel;
  final String? imageUrl; // Optional field
  final String? mapUrl; // Optional field

  Trail({
    required this.id,
    required this.name,
    required this.description,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.district,
    required this.difficultyLevel,
    this.imageUrl,
    this.mapUrl,
  });
}
