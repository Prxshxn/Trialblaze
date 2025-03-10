import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase package
import 'package:provider/provider.dart'; // Import Provider package
import 'services/review_service.dart'; // Import ReviewService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://fifnktcorhoxrwowynls.supabase.co", // Your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpZm5rdGNvcmhveHJ3b3d5bmxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE0NDI0MTcsImV4cCI6MjA1NzAxODQxN30.TUAFCq9q44omU11XyWK4jcmxO0opv63qYlxO1CAlwj0', // Your Supabase anon key
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ReviewService())],
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
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
