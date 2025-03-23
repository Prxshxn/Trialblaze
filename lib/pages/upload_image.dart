import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _PictureUploadPageState extends State<PictureUploadPage> {
  // Retrieve user ID from SharedPreferences
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}

class _PictureUploadPageState extends State<PictureUploadPage> {
  // Upload image to Supabase
  Future uploadImage() async {
    if (_imageFile == null) return;

    // Retrieve user ID
    String? userId = await getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User ID not found!")));
      return;
    }

    // Generate a unique file path
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    // Upload image to Supabase storage
    await Supabase.instance.client.storage
        .from('images')
        .upload(path, _imageFile!)
        .then((value) async {
      // Store user ID and image path in a separate table
      await Supabase.instance.client.from('user_images').insert([
        {
          'user_id': userId,
          'image_path': path,
          'uploaded_at': DateTime.now().toIso8601String(),
        }
      ]).then((_) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload successful!"))));
    });
  }
}

class _PictureUploadPageState extends State<PictureUploadPage> {
  File? _imageFile;

  // Pick image from gallery
  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Page"),
      ),
      body: Center(
        child: Column(
          children: [
            // Image preview
            _imageFile != null
                ? Image.file(_imageFile!)
                : const Center(child: Text("No image selected...")),
          ],
        ),
      ),
    );
  }
}
