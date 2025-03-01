import 'package:flutter/material.dart';
import 'package:trailblaze_reviews/models/review.dart' as model;

class ReviewService extends ChangeNotifier {
  final List<model.Review> _reviews = [];

  List<model.Review> get reviews => _reviews;

  void addReview(model.Review review) {
    _reviews.add(review);
    notifyListeners(); // Notify UI to update
  }

  getReviews() {}
}
