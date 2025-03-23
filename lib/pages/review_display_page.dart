import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewDisplayPage extends StatefulWidget {
  final String trailId;
  const ReviewDisplayPage({super.key, required this.trailId});

  @override
  State<ReviewDisplayPage> createState() => _ReviewDisplayPageState();
}

class _ReviewDisplayPageState extends State<ReviewDisplayPage> {
  List<dynamic> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    final url =
        Uri.parse('http://13.53.173.93:5000/api/v1/reviews/${widget.trailId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _reviews = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load reviews")),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Reviews"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? const Center(
                  child: Text("No reviews yet",
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(review['review_text'],
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < review['rating']
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.yellow,
                              size: 18,
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
