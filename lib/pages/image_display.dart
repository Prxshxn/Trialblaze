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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    try {
      String? userId = await getUserId();
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User ID not found!")),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      List<String> paths = await fetchUserImages(userId);
      if (mounted) {
        setState(() {
          imagePaths = paths;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch images: $e")),
        );
      }
    }
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<List<String>> fetchUserImages(String userId) async {
    final response = await Supabase.instance.client
        .from('user_images')
        .select('image_path')
        .eq('user_id', userId);

    return response
        .map<String>((record) => record['image_path'] as String)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.purpleAccent,
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2D2D2D),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Images"),
          centerTitle: true,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : imagePaths.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No images found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Images you upload will appear here",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: imagePaths.length,
                      itemBuilder: (context, index) {
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                Supabase.instance.client.storage
                                    .from('images')
                                    .getPublicUrl(imagePaths[index]),
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[900],
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                        size: 42,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    "Image ${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
        backgroundColor: const Color(0xFF121212),
      ),
    );
  }
}
