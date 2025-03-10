// review_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _reviews = [];

  List<Map<String, dynamic>> get reviews => _reviews;

  // Fetch reviews from Supabase with error handling
  Future<void> fetchReviews() async {
    try {
      final response = await _supabase.from('reviews').select().execute();
      if (response.error != null) {
        throw response.error!;
      }
      _reviews = List<Map<String, dynamic>>.from(response.data);
      notifyListeners();
    } catch (error) {
      print('Error fetching reviews: $error');
    }
  }

  // Add a new review to Supabase
  Future<void> addReview(String reviewText) async {
    try {
      final response =
          await _supabase.from('reviews').insert({
            'review_text': reviewText,
            'created_at': DateTime.now().toIso8601String(),
          }).execute();

      if (response.error != null) {
        throw response.error!;
      }

      await fetchReviews(); // Refresh the review list after adding
    } catch (error) {
      print('Error adding review: $error');
    }
  }
}
