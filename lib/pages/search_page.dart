import 'package:flutter/material.dart';
import 'navigation_page.dart';
import 'annotate_page.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Search Trails', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterTrails,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Search Trails',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: _filteredTrails.isEmpty
                ? const Center(
                    child: Text('No trails found.', style: TextStyle(color: Colors.white)),
                  )
                : ListView.builder(
                    itemCount: _filteredTrails.length,
                    itemBuilder: (context, index) {
                      final trail = _filteredTrails[index];
                      return ListTile(
                        title: Text(trail['name'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text(trail['description'], style: const TextStyle(color: Colors.grey)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnotatePage(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                color: Colors.white,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.search),
                color: Colors.grey,
                onPressed: () {},
              ),
              const SizedBox(width: 48), // Space for the FAB
              IconButton(
                icon: const Icon(Icons.favorite_border),
                color: Colors.grey,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                color: Colors.grey,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
