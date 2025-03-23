import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddReviewPage extends StatefulWidget {
  final String trailId;
  const AddReviewPage({super.key, required this.trailId});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  bool _isLoading = false;

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rating and review")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final url = Uri.parse('http://13.53.173.93:5000/api/v1/reviews');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'trail_id': widget.trailId,
        'rating': _rating,
        'review_text': _reviewController.text,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      _reviewController.clear();
      setState(() => _rating = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review added successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add review")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Add Review"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rate this trail",
                style: TextStyle(fontSize: 18, color: Colors.white)),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.yellow),
                  onPressed: () => setState(() => _rating = index + 1.0),
                );
              }),
            ),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Write your review...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade800,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
