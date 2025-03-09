import 'package:flutter/material.dart';

class TrailDetails extends StatefulWidget {
  const TrailDetails({Key? key}) : super(key: key);

  @override
  State<TrailDetails> createState() => _TrailDetailsState();
}

class _TrailDetailsState extends State<TrailDetails> {
  String difficultyLevel = 'Easy';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _elevationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            

            // Estimated Time
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Estimated Time (hours)',
                hintText: 'Enter estimated time',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
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
            const SizedBox(height: 24),

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
                backgroundColor: Colors.grey[200],
                minimumSize: const Size(double.infinity, 48), // Full width button
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Upload Pictures'),
            ),
            const SizedBox(height: 16),

            // Start Annotating and Start Tracking buttons in a row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      //TODO: Implement annotation feature
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Start Annotating'),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement tracking feature
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Start Tracking'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String level) {
    bool isSelected = difficultyLevel == level;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => difficultyLevel = level),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
              ? Border.all(color: Colors.grey[300]!)
              : null,
          ),
          child: Text(
            level,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}