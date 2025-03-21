import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'offline_map.dart';
import 'newhome_page.dart'; // Import the HomePage or other pages if needed
import 'search_page.dart';
import 'annotate_page.dart';

class SavedTrailsPage extends StatefulWidget {
  const SavedTrailsPage({super.key});

  @override
  State<SavedTrailsPage> createState() => _SavedTrailsPageState();
}

class _SavedTrailsPageState extends State<SavedTrailsPage> {
  List<Map<String, String>> savedTrails = [];
  List<Map<String, dynamic>> trails = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTrails();
  }

  Future<void> _loadSavedTrails() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      print('External storage directory not found');
      return;
    }

    final files = Directory(directory.path).listSync();

    for (var file in files) {
      if (file is File &&
          file.path.endsWith('.txt') &&
          file.path.contains('trail_')) {
        final content = await file.readAsString();
        final lines = content.split('\n');

        if (lines.length >= 3) {
          final trailId = file.path.split('_').last.replaceAll('.txt', '');
          final trailName = lines[0].replaceAll('Trail Name: ', '');
          final trailDescription = lines[1].replaceAll('Description: ', '');

          setState(() {
            savedTrails.add({
              'trailId': trailId,
              'trailName': trailName,
              'trailDescription': trailDescription,
            });
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Saved Trails',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: savedTrails.length,
        itemBuilder: (context, index) {
          final trail = savedTrails[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Colors.grey[850],
            child: InkWell(
              borderRadius: BorderRadius.circular(15.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfflineNavigationPage(
                      trailId: trail['trailId']
                          .toString(), // Ensure trailId is a String
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trail['trailName'] ?? 'Unknown Trail',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            trail['trailDescription'] ??
                                'No description available',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.navigation, // Navigation arrow icon
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Add the BottomAppBar here
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnnotatePage(),
              ),
            );
          },
          elevation: 0,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 56,
        padding: EdgeInsets.zero,
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: Colors.grey,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              color: Colors.grey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(trails: trails),
                  ),
                );
              },
            ),
            const SizedBox(width: 48), // Space for the FAB
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              color: Colors.white,
              onPressed: () {
                // Already on SavedTrailsPage, no need to navigate
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              color: Colors.grey,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
