import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/review_service.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController reviewController = TextEditingController();
  double rating = 3.0;
  final ReviewService _reviewService = ReviewService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reviews & Ratings")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _reviewService.getReviews(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['review']),
                      subtitle: Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < (doc['rating'] ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: reviewController,
                  decoration: InputDecoration(
                    hintText: "Enter your review",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          rating = index + 1.0;
                        });
                      },
                      child: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (reviewController.text.isNotEmpty) {
                      _reviewService.addReview(reviewController.text, rating);
                      reviewController.clear();
                      setState(() {
                        rating = 3.0;
                      });
                    }
                  },
                  child: Text("Submit Review"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
