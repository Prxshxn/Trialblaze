import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PictureUploadPage extends StatefulWidget {
  const PictureUploadPage({super.key});

  @override
  State<PictureUploadPage> createState() => _PictureUploadPageState();
}

class _PictureUploadPageState extends State<PictureUploadPage> {
  File? _imageFile;

  //pick image
  Future pickImage() async {
    //picker
    final ImagePicker picker = ImagePicker();

    //pick from gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    //update image preview
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // upload
  Future uploadImage() async {
    if (_imageFile == null) return;

    // Retrieve user ID from SharedPreferences
    String? userId = await getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User ID not found!")));
      return;
    }

    //generate a unique file path
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    //upload the image to supabase storage
    await Supabase.instance.client.storage
        .from('images')
        .upload(path, _imageFile!)
        .then((value) async {
      // Optionally, store the user ID and image path in a separate table
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Upload Page"),
        ),
        body: Center(
          child: Column(
            children: [
              //image preview
              _imageFile != null
                  ? Image.file(_imageFile!)
                  : Center(child: const Text("No image selected...")),

              //pick image button
              ElevatedButton(
                  onPressed: pickImage, child: const Text("Pick Image")),

              //upload button
              ElevatedButton(
                  onPressed: uploadImage, child: const Text("Upload"))
            ],
          ),
        ));
  }
}
