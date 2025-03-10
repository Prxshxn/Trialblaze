import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;

  //choose image
  Future pickImage() async {
    //picker
    final ImagePicker picker = ImagePicker();

    //choose from gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    //Update image preview
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  //upload
  Future uploadImage() async {
    if (_imageFile == null) return;

    //generate a unique file path
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "uploads/$fileName";

    //upload the image to supabase storage
    await Supabase.instance.client.storage
        //to this bucket
        .from('images')
        .upload(path, _imageFile!)
        .then(
          (value) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image Upload Successful!")),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Picture Upload page")),
      body: Center(
        child: Column(
          children: [
            //image perview
            _imageFile != null
                ? Image.file(_imageFile!)
                : const Text("No Image Selected..."),
            //choose image button
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Select Image"),
            ),
            //upload button
            ElevatedButton(onPressed: uploadImage, child: const Text("upload")),
          ],
        ),
      ),
    );
  }
}
