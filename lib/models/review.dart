class Review {
  String userId;
  String comment;
  double rating;
  DateTime timestamp;

  Review(
      {required this.userId,
      required this.comment,
      required this.rating,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'comment': comment,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static Review fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'],
      comment: map['comment'],
      rating: map['rating'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
