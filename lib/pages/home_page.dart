import 'package:createtrial/pages/landing_page.dart';
import 'package:createtrial/pages/newhome_page.dart';
import 'package:createtrial/pages/location_marker.dart';
import 'package:createtrial/pages/annotate_page.dart';
import 'package:flutter/material.dart';
import 'navigatetotrail.dart';
import 'package:createtrial/models/trail.dart';
import 'downloadable_trails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'saved_trails_page.dart';
import 'package:createtrial/screens/trail_overview_screen.dart';
import 'package:createtrial/pages/splash-screen.dart';

class skHomePage extends StatefulWidget {
  const skHomePage({super.key});

  @override
  State<skHomePage> createState() => _skHomePageState();
}

class _skHomePageState extends State<skHomePage> {
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
        title: const Text("Home"),
      ),
      body: Column(
        children: [
          // List of Trails
          Expanded(
            child: ListView.builder(
              itemCount: trails.length,
              itemBuilder: (context, index) {
                final trail = trails[index];
                return ListTile(
                  title: Text(trail['name']),
                  subtitle: Text(trail['description']),
                  onTap: () {
                    // Navigate to NavigationPage with the selected trail's ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigatetoTrailPage(
                          trailId: trail['id'], // Pass the trail ID
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Existing Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnnotatePage(),
                      ),
                    );
                  },
                  child: const Text("Annotate Feature"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  child: const Text("Home Page"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationMarkerPage(),
                      ),
                    );
                  },
                  child: const Text("Location Marker Feature"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DownloadsViewPage(),
                      ),
                    );
                  },
                  child: const Text("Download maps"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedTrailsPage(),
                      ),
                    );
                  },
                  child: const Text("View Saved Trails"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrailOverviewScreen(
                            trail: Trail.getMockTrails()[0]),
                      ),
                    );
                  },
                  child: const Text("Trail Overview"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LandingPage(),
                      ),
                    );
                  },
                  child: const Text("landing page"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                    );
                  },
                  child: const Text("Splash Screen"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
