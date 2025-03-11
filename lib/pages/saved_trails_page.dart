import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'offline_map.dart';

class SavedTrailsPage extends StatefulWidget {
  const SavedTrailsPage({super.key});

  @override
  State<SavedTrailsPage> createState() => _SavedTrailsPageState();
}

class _SavedTrailsPageState extends State<SavedTrailsPage> {
  List<Map<String, String>> savedTrails = [];

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
        title: const Text('Saved Trails'),
      ),
      body: ListView.builder(
        itemCount: savedTrails.length,
        itemBuilder: (context, index) {
          final trail = savedTrails[index];
          return ListTile(
            title: Text(trail['trailName'] ?? 'Unknown Trail'),
            subtitle:
                Text(trail['trailDescription'] ?? 'No description available'),
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
          );
        },
      ),
    );
  }
}
