import 'package:flutter/material.dart';

//Main widget for creating a trail details page
class TrailDetails extends StatefulWidget {
  const TrailDetails({Key? key}) : super(key: key);

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
  //Variable to store the selected difficulty level
  String difficultyLevel = 'Easy';

  //Controllers for handling text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _elevationController = TextEditingController();

  @override
  void dispose() {
    //Dispose controllers to free up resources 
    _nameController.dispose();
    _descriptionController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBar with a back button and title
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 227, 228, 227),
        shadowColor: const Color.fromARGB(255, 74, 77, 75),
        title: const Text(
          'Create a Trail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      //Body of the page with a SingleChildScrollView for scrollable content
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
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // District Dropdown
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: InputDecoration(
                labelText: 'Location',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: districts.map((String district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDistrict = newValue;
                });
              },
              hint: const Text('Select a district'),
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
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
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
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // Difficulty Level Selection
            const Text(
              'Difficulty Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                minimumSize: const Size(double.infinity, 48), // Full width button
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Upload Pictures'),
            ),
            const SizedBox(height: 16),

            //Start annotating Button
            ElevatedButton(
              onPressed: () {
                // TODO: Implement tracking feature
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48), // Full width button
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Start Tracking'),
            ),
          ],
        ),
      ),
    );       
  }

  //Helper method to build a difficulty level button
  Widget _buildDifficultyButton(String level) {
    bool isSelected = difficultyLevel == level;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => difficultyLevel = level), // Update selected difficulty
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.grey[50], // Change color if selected
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
              ? Border.all(color: Colors.grey[300]!) // Add border if selected
              : null,
          ),
          child: Text(
            level,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.grey[600],  // Change text color if selected
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold if selected
            ),
          ),
        ),
      ),
    );
  }
}                