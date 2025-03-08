import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class DownloadsViewPage extends StatefulWidget {
  const DownloadsViewPage({super.key});

  @override
  State<DownloadsViewPage> createState() => _DownloadsViewPageState();
}

class _DownloadsViewPageState extends State<DownloadsViewPage> {
  List<Map<String, dynamic>> trails = [];

  @override
  void initState() {
    super.initState();
    _fetchTrails();
  }

  Future<void> _fetchTrails() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.from('trails').select('*');
      setState(() {
        trails = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching trails: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloads"),
      ),
      body: ListView.builder(
        itemCount: trails.length,
        itemBuilder: (context, index) {
          final trail = trails[index];
          return ListTile(
            title: Text(trail['name']),
            subtitle: Text(trail['description']),
            onTap: () {
              //redirect to the download page WIP
            },
          );
        },
      ),
    );
  }
}
