import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddReviewPage extends StatefulWidget {
  final String trailId;
  final String userId;

  AddReviewPage({required this.trailId, required this.userId});

  @override
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _ratingController = TextEditingController();
  final _reviewTextController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  // Submit review function with detailed debugging
  Future<void> submitReview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = 'http://10.0.2.2:5000/api/v1/reviews';

    final int? rating = int.tryParse(_ratingController.text);
    if (rating == null || rating < 1 || rating > 5) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter a valid rating between 1 and 5.';
      });
      return;
    }

    final Map<String, dynamic> requestBody = {
      'user_id': widget.userId,
      'trail_id': widget.trailId,
      'rating': rating,
      'review_text': _reviewTextController.text.trim(),
    };

    print('📤 Sending request to: $url');
    print('📦 Request Body: ${json.encode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📜 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ Review submitted successfully!');
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to submit review: ${response.body}';
        });
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to connect to the server. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Review")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ratingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Rating (1-5)'),
            ),
            TextField(
              controller: _reviewTextController,
              decoration: InputDecoration(labelText: 'Review'),
            ),
            SizedBox(height: 20),
            if (_isLoading) CircularProgressIndicator(),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : submitReview,
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
