import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/splash-screen.dart';
import 'pages/trail_details.dart';

void main() async {
  await setup();
  WidgetsFlutterBinding.ensureInitialized();
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

  // This widget is the root of your application.[]
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
    );
  }
}
