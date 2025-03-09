import 'package:flutter/material.dart';
import '../models/trail.dart';

class TrailOverviewScreen extends StatefulWidget {
  final Trail trail;

  const TrailOverviewScreen({
    Key? key,
    required this.trail,
  }) : super(key: key);

  @override
  _TrailOverviewScreenState createState() => _TrailOverviewScreenState();
}

class _TrailOverviewScreenState extends State<TrailOverviewScreen> {
  final _commentController = TextEditingController();
  double _userRating = 0;
  late List<Review> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = List.from(widget.trail.reviews);
  }

  void _submitReview() {
    if (_commentController.text.isEmpty || _userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add both rating and comment')),
      );
      return;
    }

    final newReview = Review(
      id: DateTime.now().toString(),
      userId: 'current_user',
      userName: 'Current User',
      userImage: 'https://randomuser.me/api/portraits/lego/1.jpg',
      date: 'Just now',
      rating: _userRating.round(),
      comment: _commentController.text,
      likes: 0,
    );

    setState(() {
      _reviews.insert(0, newReview);
      _commentController.clear();
      _userRating = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review added successfully')),
    );
  }

  void _likeReview(int index) {
    setState(() {
      final review = _reviews[index];
      _reviews[index] = Review(
        id: review.id,
        userId: review.userId,
        userName: review.userName,
        userImage: review.userImage,
        date: review.date,
        rating: review.rating,
        comment: review.comment,
        likes: review.likes + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.trail.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.trail.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Difficulty', widget.trail.difficulty),
                      _buildInfoRow(
                          'Trail Length', '${widget.trail.length} miles'),
                      _buildInfoRow(
                          'Estimated Time', widget.trail.estimatedTime),
                      _buildInfoRow('Elevation Gain',
                          '${widget.trail.elevationGain} feet'),
                      const SizedBox(height: 20),
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildReviewInput(),
                      const SizedBox(height: 20),
                      ..._reviews.asMap().entries.map(
                            (entry) => _buildReviewCard(entry.value, entry.key),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Your Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _userRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        _userRating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Write your review...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Submit Review',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(review.userImage),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(review.date),
                  ],
                ),
                const Spacer(),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(review.comment),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined),
                  onPressed: () => _likeReview(index),
                ),
                Text('${review.likes}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
