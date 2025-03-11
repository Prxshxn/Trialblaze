import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/home_page.dart'; // Import the HomePage widget

void main() async {
  await setup(); // Ensure the setup is completed before running the app
  WidgetsFlutterBinding.ensureInitialized(); // Initialize the widgets
  await Supabase.initialize(
    url: 'https://ajicktjizxgwtsoqiqbi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqaWNrdGppenhnd3Rzb3FpcWJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAzMTY5NTEsImV4cCI6MjA1NTg5Mjk1MX0.Irp4Jkv8ZvTZlCWxwyiialQigXHlM7VMrGTmMd5I0MA',
  );
  runApp(const MyApp());
}

Future<void> setup() async {
  await dotenv.load(
    fileName: ".env",
  );
  MapboxOptions.setAccessToken(
    dotenv.env["MAPBOX_ACCESS_TOKEN"]!,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(), // Start from HomePage
    );
  }
}
