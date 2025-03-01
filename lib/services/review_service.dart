import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final CollectionReference reviews =
      FirebaseFirestore.instance.collection('reviews');

  /// Add a new review to Firestore
  Future<void> addReview(String review, double rating) async {
    await reviews.add({
      'review': review,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get all reviews as a stream
  Stream<QuerySnapshot> getReviews() {
    return reviews.orderBy('timestamp', descending: true).snapshots();
  }
}
