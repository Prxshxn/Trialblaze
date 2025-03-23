import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PictureUploadPageState extends State<PictureUploadPage> {
  // Retrieve user ID from SharedPreferences
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
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
