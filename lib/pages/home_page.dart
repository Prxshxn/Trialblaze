import 'package:createtrial/pages/annotate_page.dart';
import 'package:createtrial/pages/location_markers.dart';
import 'package:flutter/material.dart';
import 'navigation_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NavigationPage(),
                  ),
                );
              },
              child: const Text("Go to Navigation"),
            ),
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
                    builder: (context) => const LocationMarkerPage(),
                  ),
                );
              },
              child: const Text("Location Marker Feature"),
            ),
          ],
        ),
      ),
    );
  }

  // void _showWIPDialog(BuildContext context, String featureName) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text("$featureName - WIP"),
  //       content: const Text("This feature is currently under development."),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("OK"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
