class Trail {
  final String id;
  final String name;
  final String difficulty;
  final double length;
  final String estimatedTime;
  final int elevationGain;
  final String imageUrl;
  final List<Review> reviews;

  Trail({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.length,
    required this.estimatedTime,
    required this.elevationGain,
    required this.imageUrl,
    required this.reviews,
  });

  // Mock data for initial development
  static List<Trail> getMockTrails() {
    return [
      Trail(
        id: '1',
        name: 'Adams Peak',
        difficulty: 'Hard',
        length: 4.3,
        estimatedTime: '2 hours 45 minutes',
        elevationGain: 1279,
        imageUrl:
            'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
        reviews: [
          Review(
            id: '1',
            userId: 'user1',
            userName: 'Sophia',
            userImage: 'https://randomuser.me/api/portraits/women/1.jpg',
            date: 'Jan 2022',
            rating: 5,
            comment: 'Great hike, beautiful views of the bay area.',
            likes: 12,
          ),
          Review(
            id: '2',
            userId: 'user2',
            userName: 'Ava',
            userImage: 'https://randomuser.me/api/portraits/women/2.jpg',
            date: 'Dec 2021',
            rating: 5,
            comment: 'Nice trail with a lot of shade. The view was amazing.',
            likes: 8,
          ),
          Review(
            id: '3',
            userId: 'user3',
            userName: 'Emma',
            userImage: 'https://randomuser.me/api/portraits/women/3.jpg',
            date: 'Nov 2021',
            rating: 5,
            comment:
                'Love hiking here. It\'s not too long and it\'s really pretty.',
            likes: 7,
          ),
        ],
      ),
      Trail(
        id: '2',
        name: 'Crystal Lake Trail',
        difficulty: 'Moderate',
        length: 3.2,
        estimatedTime: '1 hour 30 minutes',
        elevationGain: 850,
        imageUrl:
            'https://images.unsplash.com/photo-1501555088652-021faa106b9b',
        reviews: [],
      ),
      Trail(
        id: '3',
        name: 'Mountain View Trail',
        difficulty: 'Easy',
        length: 2.5,
        estimatedTime: '1 hour',
        elevationGain: 500,
        imageUrl:
            'https://images.unsplash.com/photo-1519904981063-b0cf448d479e',
        reviews: [],
      ),
    ];
  }

  // This can be used later when connecting to the backend
  factory Trail.fromJson(Map<String, dynamic> json) {
    return Trail(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      difficulty: json['difficulty'],
      length: json['length'].toDouble(),
      estimatedTime: json['estimatedTime'],
      elevationGain: json['elevationGain'],
      imageUrl: json['imageUrl'],
      reviews: (json['reviews'] as List?)
              ?.map((review) => Review.fromJson(review))
              .toList() ??
          [],
    );
  }
}

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

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userImage: json['userImage'],
      date: json['date'],
      rating: json['rating'],
      comment: json['comment'],
      likes: json['likes'],
    );
  }
}
