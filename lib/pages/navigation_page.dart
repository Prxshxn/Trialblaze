import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:geolocator/geolocator.dart' as gl;
import 'package:supabase_flutter/supabase_flutter.dart'; // Add Supabase import
import 'package:shared_preferences/shared_preferences.dart';

class NavigationPage extends StatefulWidget {
  final String trailId; // Add trailId as a parameter
  const NavigationPage({super.key, required this.trailId});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  mp.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  gl.Position? currentPosition;
  double currentZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _setupPositionTracking();
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mp.MapWidget(
            onMapCreated: _onMapCreated,
            styleUri: mp.MapboxStyles.OUTDOORS,
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Hero(
              tag: 'backButton', // Unique tag
              child: FloatingActionButton(
                heroTag: null,
                mini: true,
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: Hero(
              tag: 'recenterButton', // Unique tag
              child: FloatingActionButton(
                heroTag: null,
                onPressed: _recenterCamera,
                child: const Icon(Icons.my_location),
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            right: 20,
            child: Hero(
              tag: 'zoomInButton', // Unique tag
              child: FloatingActionButton(
                heroTag: null,
                onPressed: _zoomIn,
                child: const Icon(Icons.add),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: 20,
            child: Hero(
              tag: 'zoomOutButton', // Unique tag
              child: FloatingActionButton(
                heroTag: null,
                onPressed: _zoomOut,
                child: const Icon(Icons.remove),
              ),
            ),
          ),
          Positioned(
            bottom: 260, // Adjust the position as needed
            right: 20,
            child: FloatingActionButton(
              heroTag: 'sosButton', // Unique tag
              backgroundColor: Colors.red, // Red color for SOS
              onPressed: _sendSOS, // Call the _sendSOS method
              child: const Icon(Icons.emergency),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSOS() async {
    // Get the user's current position
    final position = await gl.Geolocator.getCurrentPosition();

    // Get the user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      print('User ID not found. Please log in again.');
      return;
    }

    final supabase = Supabase.instance.client;

    try {
      // Fetch hiker's name and phone number from Supabase
      final userResponse = await supabase
          .from(
              'users') // Replace with the actual table name where user data is stored
          .select('username, emergency_contact')
          .eq('id', userId)
          .single();

      if (userResponse == null) {
        print('User details not found.');
        return;
      }
      // Fetch trail name using trailId
      final trailResponse = await supabase
          .from('trails') // Replace with the actual trails table name
          .select('name')
          .eq('id', widget.trailId)
          .single();

      if (trailResponse == null) {
        print('Trail details not found.');
        return;
      }
      final trailName = trailResponse['name'] ?? 'Unknown Trail';
      final hikerName = userResponse['name'] ?? 'Unknown';
      final phone = userResponse['phone'] ?? 'N/A';

      // Prepare the SOS data
      final sosData = {
        'hikername': hikerName,
        'trail': trailName,
        'phone': phone,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        'status': "Awaiting",
        'user_id': userId,
      };

      // Send the data to Supabase
      final response = await supabase.from('sos_requests').insert([sosData]);

      if (response != null) {
        print('SOS data sent successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SOS sent successfully!')),
        );
      } else {
        print('Failed to send SOS data');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to send SOS. Please try again.')),
        );
      }
    } catch (e) {
      print('Error fetching user details or sending SOS: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending SOS. Please try again.')),
      );
    }
  }

  // Define the fetchCoordinates method
  Future<List<Map<String, dynamic>>> fetchCoordinates(String trailId) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('coordinates')
          .select('latitude, longitude')
          .eq('trail_id', trailId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching coordinates: $e');
      return [];
    }
  }

  void _onMapCreated(mp.MapboxMap controller) async {
    setState(() {
      mapboxMapController = controller;
    });
    mapboxMapController?.location.updateSettings(
      mp.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );

    // Fetch coordinates for the specific trail
    final coordinates = await fetchCoordinates(widget.trailId);

    if (coordinates.isNotEmpty) {
      // Get the first coordinate
      final firstCoord = coordinates.first;
      final firstLatitude = firstCoord['latitude'] as double;
      final firstLongitude = firstCoord['longitude'] as double;

      // Set the camera position to the first coordinate
      mapboxMapController?.flyTo(
        mp.CameraOptions(
          center: mp.Point(
            coordinates: mp.Position(firstLongitude, firstLatitude),
          ),
          zoom: currentZoom, // Use the current zoom level
        ),
        mp.MapAnimationOptions(duration: 1000),
      );
    }

    // Convert coordinates to a list of `mp.Position`
    List<mp.Position> polylineCoordinates = coordinates.map((coord) {
      final latitude = coord['latitude'] as double;
      final longitude = coord['longitude'] as double;
      return mp.Position(longitude, latitude);
    }).toList();

    // Create a polyline annotation manager
    final polylineAnnotationManager = await mapboxMapController?.annotations
        .createPolylineAnnotationManager();

    // Create polyline annotation options
    mp.PolylineAnnotationOptions polylineAnnotationOptions =
        mp.PolylineAnnotationOptions(
      geometry: mp.LineString(
        coordinates: polylineCoordinates,
      ),
      lineColor: Colors.blue.value,
      lineWidth: 5.0,
    );

    // Add the polyline annotation to the map
    polylineAnnotationManager?.create(polylineAnnotationOptions);
  }

  Future<void> _setupPositionTracking() async {
    bool serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    gl.LocationPermission permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        return Future.error('Location permission is denied');
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      return Future.error(
          'Location permission is permanently denied, we cannot request permission.');
    }

    gl.LocationSettings locationSettings = const gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100,
    );

    userPositionStream?.cancel();
    userPositionStream =
        gl.Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((gl.Position? position) {
      if (position != null) {
        setState(() {
          currentPosition = position;
        });
      }
    });
  }

  void _recenterCamera() {
    if (currentPosition != null && mapboxMapController != null) {
      mapboxMapController?.flyTo(
        mp.CameraOptions(
          zoom: currentZoom,
          center: mp.Point(
            coordinates: mp.Position(
                currentPosition!.longitude, currentPosition!.latitude),
          ),
        ),
        mp.MapAnimationOptions(duration: 1000),
      );
    }
  }

  void _zoomIn() {
    setState(() {
      currentZoom += 1;
    });
    mapboxMapController?.flyTo(
      mp.CameraOptions(
        zoom: currentZoom,
      ),
      mp.MapAnimationOptions(duration: 1000),
    );
  }

  void _zoomOut() {
    setState(() {
      currentZoom -= 1;
    });
    mapboxMapController?.flyTo(
      mp.CameraOptions(
        zoom: currentZoom,
      ),
      mp.MapAnimationOptions(duration: 1000),
    );
  }
}
