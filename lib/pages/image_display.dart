import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserImagesPage extends StatefulWidget {
  const UserImagesPage({super.key});

  @override
  State<UserImagesPage> createState() => _UserImagesPageState();
}

class _UserImagesPageState extends State<UserImagesPage> {
  List<String> imagePaths = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    try {
      String? userId = await getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User ID not found!")),
        );
        return;
      }

      List<String> paths = await fetchUserImages(userId);
      setState(() {
        imagePaths = paths;
        isLoading = false; // Data has been loaded
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch images: $e")),
      );
    }
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
        'user_id'); // Assuming you stored the user ID with key 'userId'
  }

  Future<List<String>> fetchUserImages(String userId) async {
    final response = await Supabase.instance.client
        .from('user_images')
        .select('image_path')
        .eq('user_id', userId);

    // Extract image paths from the response
    return response
        .map<String>((record) => record['image_path'] as String)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Images"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : imagePaths.isEmpty
              ? const Center(
                  child: Text("No images found.")) // Show message if no images
              : ListView.builder(
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      Supabase.instance.client.storage
                          .from('images')
                          .getPublicUrl(imagePaths[index]),
                      fit: BoxFit.cover,
                    );
                  },
                ),
    );
  }
}
