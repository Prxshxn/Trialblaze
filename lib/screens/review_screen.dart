import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/review_service.dart';
import '../models/review.dart';

// ignore: must_be_immutable
class ReviewScreen extends StatelessWidget {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;

  ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reviewService = Provider.of<ReviewService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Reviews')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Review>>(
              stream: reviewService.getReviews(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final reviews = snapshot.data!;
                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return ListTile(
                      title: Text(review.comment),
                      subtitle: Text('Rating: ${review.rating}'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(labelText: 'Leave a review'),
                ),
                Slider(
                  value: _rating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _rating.toString(),
                  onChanged: (value) {
                    _rating = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    final newReview = Review(
                      userId: 'user123',
                      comment: _commentController.text,
                      rating: _rating,
                      timestamp: DateTime.now(),
                    );
                    reviewService.addReview(newReview);
                    _commentController.clear();
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
