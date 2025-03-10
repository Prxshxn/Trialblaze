import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reviews = [];

  List<Map<String, dynamic>> get reviews => _reviews;

  // Fetch reviews from Supabase
  Future<void> fetchReviews() async {
    final response = await _supabase.from('reviews').select().execute();
    if (response.error == null) {
      // Store the reviews in _reviews
      _reviews = List<Map<String, dynamic>>.from(response.data);
      notifyListeners(); // Notify listeners to update UI
    } else {
      print('Error fetching reviews: ${response.error!.message}');
    }
  }

  // Add a new review to Supabase
  Future<void> addReview(String reviewText) async {
    final response =
        await _supabase.from('reviews').insert({
          'review_text': reviewText,
          'created_at': DateTime.now().toIso8601String(),
        }).execute();

    if (response.error == null) {
      fetchReviews(); // Refresh the review list after adding
    } else {
      print('Error adding review: ${response.error!.message}');
    }
  }
}
