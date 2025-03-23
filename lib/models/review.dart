class Review {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String date;
  final int rating;
  final String comment;
  final int likes;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.date,
    required this.rating,
    required this.comment,
    required this.likes,
  });
}
