import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast

class TrailDetails extends StatefulWidget {
  final List<gl.Position> trackedPositions;
  final double totalDistanceInMeters;
  final Duration totalDuration;
  final VoidCallback? onTrailSaved;

  const TrailDetails({
    super.key,
    required this.trackedPositions,
    required this.totalDistanceInMeters,
    required this.totalDuration,
    this.onTrailSaved,
  });

  @override
  State<TrailDetails> createState() => _TrailDetailsState();
}

class _TrailDetailsState extends State<TrailDetails> {
  // List of districts in Sri Lanka
  final List<String> districts = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];

  // Variable to store the selected district
  String? selectedDistrict;
  // Variable to store the selected difficulty level
  String difficultyLevel = 'Easy';

  // Controllers for handling text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _elevationController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _nameController.dispose();
    _descriptionController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff161616),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(color: Colors.grey[400]),
        backgroundColor: Colors.grey[900],
        shadowColor: Colors.black,
        title: const Text(
          'Create a Trail',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trail Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Trail Name',
                hintText: 'Name this trail',
                filled: true,
                fillColor: Color(0xff373636),
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // District Dropdown
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: InputDecoration(
                labelText: 'Location',
                filled: true,
                fillColor: Color(0xff373636),
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: districts.map((String district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(
                    district,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDistrict = newValue;
                });
              },
              hint: Text(
                'Select a district',
                style: TextStyle(color: Colors.grey[400]),
              ),
              dropdownColor: Colors.grey[800],
            ),
            const SizedBox(height: 16),

            // Elevation Gain
            TextField(
              controller: _elevationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Elevation Gain (m)',
                hintText: 'Enter elevation gain',
                filled: true,
                fillColor: Color(0xff373636),
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Add a description',
                filled: true,
                fillColor: Color(0xff373636),
                labelStyle: TextStyle(color: Colors.white),
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),

            // Difficulty Level Selection
            const Text(
              'Difficulty Level',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDifficultyButton('Easy'),
                const SizedBox(width: 8),
                _buildDifficultyButton('Moderate'),
                const SizedBox(width: 8),
                _buildDifficultyButton('Hard'),
              ],
            ),
            const SizedBox(height: 24),

            // Upload Pictures Button
            ElevatedButton(
              onPressed: () {
                // TODO: Implement picture upload
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize:
                    const Size(double.infinity, 48), // Full width button
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Upload Pictures'),
            ),
            const SizedBox(height: 16),

            // Save Trail Button
            ElevatedButton(
              onPressed: () async {
                // Validate inputs
                if (_nameController.text.isEmpty ||
                    _descriptionController.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Please fill in all fields',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }

                // Get the user ID from SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getString('user_id');

                if (userId == null) {
                  Fluttertoast.showToast(
                    msg: 'User ID not found. Please log in again.',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }

                // Parse elevation gain (default to 0 if empty or invalid)
                final elevationGain =
                    double.tryParse(_elevationController.text) ?? 0.0;

                // Prepare the data to send to the backend
                final response = await saveTrail(
                  _nameController.text, // Trail name
                  _descriptionController.text, // Trail description
                  widget.totalDistanceInMeters, // Total distance
                  widget.totalDuration.inSeconds, // Total duration
                  userId, // User ID
                  widget.trackedPositions, // Tracked coordinates
                  selectedDistrict, // Selected district
                  difficultyLevel, // Difficulty level
                  elevationGain, // Elevation gain
                );

                if (response != null && response['trailId'] != null) {
                  Fluttertoast.showToast(
                    msg: 'Trail saved successfully!',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );

                  // Call the callback if it exists
                  if (widget.onTrailSaved != null) {
                    widget.onTrailSaved!();
                  }

                  Navigator.pop(context); // Go back to the previous page
                } else {
                  Fluttertoast.showToast(
                    msg: 'Failed to save trail. Please try again.',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize:
                    const Size(double.infinity, 55), // Full width button
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a difficulty level button
  Widget _buildDifficultyButton(String level) {
    bool isSelected = difficultyLevel == level;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(
            () => difficultyLevel = level), // Update selected difficulty
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[900] : Color(0xff373636),
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: Colors.grey[500]!) : null,
          ),
          child: Text(
            level,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.green
                  : Colors.grey[600], // Change text color if selected
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal, // Bold if selected
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> saveTrail(
    String name,
    String description,
    double distance,
    int durationSeconds,
    String userId,
    List<gl.Position> coordinates,
    String? district,
    String difficultyLevel,
    double elevationGain,
  ) async {
    final url = Uri.parse('http://192.168.1.6:5000/api/v1/trail/save');
    final body = jsonEncode({
      'name': name,
      'description': description,
      'distance': distance,
      'duration': durationSeconds,
      'user_id': userId,
      'coordinates': coordinates
          .map((pos) => {
                'latitude': pos.latitude,
                'longitude': pos.longitude,
              })
          .toList(),
      'district': district, // Add selected district
      'difficulty_level': difficultyLevel, // Add difficulty level
      'elevation_gain': elevationGain, // Add elevation gain
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to save trail: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error saving trail: $e');
      return null;
    }
  }
}
