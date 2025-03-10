import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/review_service.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch reviews when the screen is first loaded
    Provider.of<ReviewService>(context, listen: false).fetchReviews();

    return Scaffold(
      appBar: AppBar(title: Text('Trailblaze Reviews')),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ReviewService>(
              // Use Consumer to listen for changes
              builder: (context, reviewService, child) {
                return ListView.builder(
                  itemCount: reviewService.reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviewService.reviews[index];
                    return ListTile(
                      title: Text(review['review_text']),
                      subtitle: Text(review['created_at']),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Add a new review (example review)
                Provider.of<ReviewService>(
                  context,
                  listen: false,
                ).addReview('Great trail experience!');
              },
              child: Text('Add Review'),
            ),
          ),
        ],
      ),
    );
  }
}
