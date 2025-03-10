import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trailblaze Reviews")),
      body: Center(child: Text("Reviews will appear here.")),
    );
  }
}
