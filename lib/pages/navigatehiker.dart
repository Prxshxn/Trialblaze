import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigateHikerPage extends StatefulWidget {
  final double latitude; // Add latitude as a parameter
  final double longitude; // Add longitude as a parameter

  const NavigateHikerPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<NavigateHikerPage> createState() => _NavigateHikerPageState();
}

class _NavigateHikerPageState extends State<NavigateHikerPage> {
  @override
  void initState() {
    super.initState();
    _openGoogleMaps(
        widget.latitude, widget.longitude); // Use the passed coordinates
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
