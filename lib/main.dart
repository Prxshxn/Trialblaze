import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized before Supabase

  // Initialize Supabase with your project's URL and anonKey
  await Supabase.initialize(
    url:
        "https://your-supabase-url.supabase.co", // Replace with your Supabase URL
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpZm5rdGNvcmhveHJ3b3d5bmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE0NDI0MTcsImV4cCI6MjA1NzAxODQxN30.TUAFCq9q44omU11XyWK4jcmxO0opv63qYlxO1CAlwj0", // Replace with your Supabase anon key
  );

  runApp(const MyApp()); // Start the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), // Material theme for the app
      home: const HomeScreen(), // The initial screen of the app
    );
  }
}

// Define HomeScreen widget
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: const Center(child: Text('Welcome to the Home Screen')),
    );
  }
}
