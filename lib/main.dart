import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized before Supabase

  const supabaseUrl =
      "https://your-supabase-url.supabase.co"; // Replace with your Supabase URL
  const supabaseAnonKey =
      "your-anon-key"; // Replace with your Supabase anon key

  // Check if URL or anonKey is missing
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint("ERROR: Supabase URL or Key is missing!");
    return; // Exit early if URL or key is missing
  }

  try {
    // Initialize Supabase with your project's URL and anonKey
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    runApp(
      const MyApp(),
    ); // Start the app after successful Supabase initialization
  } catch (e) {
    debugPrint(
      "Supabase Initialization Error: $e",
    ); // Log any errors during initialization
  }
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
