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

  factory Trail.fromJson(Map<String, dynamic> json) {
    return Trail(
      id: json['id']?.toString() ?? 'Unknown ID',
      name: json['name'] ?? 'Unknown Name',
      description: json['description'] ?? 'No description available',
      distanceMeters: (json['distanceMeters'] ?? 0)
          .toDouble(), // Changed from distance_meters
      durationSeconds:
          json['durationSeconds'] ?? 0, // Changed from duration_seconds
      district: json['district'] ?? 'Unknown District',
      difficultyLevel: json['difficultyLevel'] ??
          'Unknown Difficulty', // Changed from difficulty_level
      imageUrl: json['imageUrl'], // Changed from image_url
      mapUrl: json['mapUrl'], // Changed from map_url
    );
  }
}
