import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trailblaze_reviews/services/review_service.dart';
import 'screens/review_screen.dart'; // Import your ReviewScreen

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => ReviewService()), // Add your provider here
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trailblaze Reviews',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ReviewScreen(), // Ensure this screen is within the Provider scope
    );
  }
}
