import 'package:flutter/material.dart';
import 'navigation_page.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> trails;

  const SearchPage({super.key, required this.trails});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredTrails = [];

  @override
  void initState() {
    super.initState();
    _filteredTrails = widget.trails;
  }

  void _filterTrails(String query) {
    setState(() {
      _searchQuery = query;
      _filteredTrails = widget.trails
          .where((trail) =>
              trail['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Trails'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterTrails,
              decoration: const InputDecoration(
                labelText: 'Search Trails',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredTrails.isEmpty
                ? const Center(
                    child: Text('No trails found.'),
                  )
                : ListView.builder(
                    itemCount: _filteredTrails.length,
                    itemBuilder: (context, index) {
                      final trail = _filteredTrails[index];
                      return ListTile(
                        title: Text(trail['name']),
                        subtitle: Text(trail['description']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NavigationPage(
                                trailId: trail['id'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
