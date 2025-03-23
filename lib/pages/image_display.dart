import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserImagesPage extends StatefulWidget {
  const UserImagesPage({super.key});

  @override
  State<UserImagesPage> createState() => _UserImagesPageState();
}

class _UserImagesPageState extends State<UserImagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Images")),
      body: const Center(child: Text("User images will be displayed here")),
    );
  }
}
