import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready before async operations

  await Supabase.initialize(
    url: "https://your-supabase-url.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpZm5rdGNvcmhveHJ3b3d5bmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE0NDI0MTcsImV4cCI6MjA1NzAxODQxN30.TUAFCq9q44omU11XyWK4jcmxO0opv63qYlxO1CAlwj0",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(), // Ensure HomeScreen is correctly defined
    );
  }
}

// Ensure HomeScreen properly extends StatelessWidget
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: const Center(child: Text('Welcome to Home Screen')),
    );
  }
}
