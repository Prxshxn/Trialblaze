import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationPage extends StatefulWidget {
  final String trailId;
  const NavigationPage({super.key, required this.trailId});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  @override
  void initState() {
    super.initState();
    _fetchAndNavigate();
  }

  Future<void> _fetchAndNavigate() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('coordinates')
          .select('latitude, longitude')
          .eq('trail_id', widget.trailId)
          .limit(1);

      if (response.isNotEmpty) {
        final firstCoord = response.first;
        final latitude = firstCoord['latitude'] as double;
        final longitude = firstCoord['longitude'] as double;

        _openGoogleMaps(latitude, longitude);
      } else {
        _showError("No coordinates found for this trail.");
      }
    } catch (e) {
      _showError("Error fetching coordinates: $e");
    }
  }

  void _openGoogleMaps(double latitude, double longitude) async {
    final googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      _showError("Could not open Google Maps.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigation"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
