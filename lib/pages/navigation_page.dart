import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:geolocator/geolocator.dart' as gl;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NavigationPage extends StatefulWidget {
  final String trailId;
  const NavigationPage({super.key, required this.trailId});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  mp.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  gl.Position? currentPosition;
  double currentZoom = 15.0;

  // Tracking variables
  bool isTracking = true; // Automatically start tracking when navigation begins
  List<gl.Position> trackedPositions = [];
  double totalDistanceInMeters = 0.0;
  DateTime? hikeStartTime;

  @override
  void initState() {
    super.initState();
    _setupPositionTracking();
    hikeStartTime = DateTime.now();
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
              tag: 'backButton',
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
              tag: 'recenterButton',
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
              tag: 'zoomInButton',
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
              tag: 'zoomOutButton',
              child: FloatingActionButton(
                heroTag: null,
                onPressed: _zoomOut,
                child: const Icon(Icons.remove),
              ),
            ),
          ),
          Positioned(
            bottom: 260,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'sosButton',
              backgroundColor: Colors.red,
              onPressed: _sendSOS,
              child: const Icon(Icons.emergency),
            ),
          ),
          Positioned(
            bottom: 320,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'finishButton',
              backgroundColor: Colors.green,
              onPressed: _completeHike,
              child: const Icon(Icons.check_circle_rounded),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distance: $formattedDistance',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duration: $formattedDuration',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSOS() async {
    final position = await gl.Geolocator.getCurrentPosition();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      Fluttertoast.showToast(
        msg: 'User ID not found. Please log in again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final supabase = Supabase.instance.client;

    try {
      final userResponse = await supabase
          .from('users')
          .select('username, emergency_contact')
          .eq('id', userId)
          .single();

      if (userResponse == null) {
        Fluttertoast.showToast(
          msg: 'User details not found.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      final trailResponse = await supabase
          .from('trails')
          .select('name')
          .eq('id', widget.trailId)
          .single();

      if (trailResponse == null) {
        Fluttertoast.showToast(
          msg: 'Trail details not found.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      final trailName = trailResponse['name'] ?? 'Unknown Trail';
      final hikerName = userResponse['username'] ?? 'Unknown';
      final phone = userResponse['emergency_contact'] ?? 'N/A';

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

      await supabase.from('sos_requests').insert([sosData]);

      Fluttertoast.showToast(
        msg: 'SOS sent successfully!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to send SOS. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _completeHike() async {
    // Get user ID from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      Fluttertoast.showToast(
        msg: 'User not logged in',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    // Calculate current hike duration
    final hikeDuration = DateTime.now().difference(hikeStartTime!);
    final hikeDistanceKm = totalDistanceInMeters / 1000;

    try {
      final supabase = Supabase.instance.client;

      // 1. Get user's current stats
      final response = await supabase
          .from('users')
          .select('total_distance, total_hiking_time')
          .eq('id', userId)
          .single();

      // 2. Calculate new totals
      final currentDistance = (response['total_distance'] ?? 0).toDouble();
      final currentTime = (response['total_hiking_time'] ?? 0).toInt();

      final newDistance = currentDistance + hikeDistanceKm;
      final newTime = currentTime + hikeDuration.inSeconds;

      // 3. Update user record
      await supabase.from('users').update({
        'total_distance': newDistance,
        'total_hiking_time': newTime,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // 4. Record this hike in user_hikes table
      await supabase.from('user_hikes').insert({
        'user_id': userId,
        'trail_id': widget.trailId,
        'distance_km': hikeDistanceKm,
        'duration_seconds': hikeDuration.inSeconds,
        'completed_at': DateTime.now().toIso8601String(),
      });

      // Show success message
      Fluttertoast.showToast(
        msg: 'Hike completed! Stats updated.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Navigate back
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error saving hike: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

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

    final coordinates = await fetchCoordinates(widget.trailId);

    if (coordinates.isNotEmpty) {
      final firstCoord = coordinates.first;
      final firstLatitude = firstCoord['latitude'] as double;
      final firstLongitude = firstCoord['longitude'] as double;

      mapboxMapController?.flyTo(
        mp.CameraOptions(
          center: mp.Point(
            coordinates: mp.Position(firstLongitude, firstLatitude),
          ),
          zoom: currentZoom,
        ),
        mp.MapAnimationOptions(duration: 1000),
      );
    }

    List<mp.Position> polylineCoordinates = coordinates.map((coord) {
      final latitude = coord['latitude'] as double;
      final longitude = coord['longitude'] as double;
      return mp.Position(longitude, latitude);
    }).toList();

    final polylineAnnotationManager = await mapboxMapController?.annotations
        .createPolylineAnnotationManager();

    mp.PolylineAnnotationOptions polylineAnnotationOptions =
        mp.PolylineAnnotationOptions(
      geometry: mp.LineString(
        coordinates: polylineCoordinates,
      ),
      lineColor: Colors.blue.value,
      lineWidth: 5.0,
    );

    polylineAnnotationManager?.create(polylineAnnotationOptions);
  }

  void _setupPositionTracking() async {
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

    // Start tracking distance travelled
    // Configure settings for geolocator
    const locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    // Start listening users's position
    userPositionStream?.cancel();
    userPositionStream = gl.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      _handleNewPosition(position);
    });
  }

  void _handleNewPosition(gl.Position position) {
    if (!isTracking) return;

    setState(() {
      currentPosition = position;

      if (trackedPositions.isNotEmpty) {
        final lastPosition = trackedPositions.last;
        final distance = gl.Geolocator.distanceBetween(
          lastPosition.latitude,
          lastPosition.longitude,
          position.latitude,
          position.longitude,
        );
        totalDistanceInMeters += distance;
      }
      trackedPositions.add(position);

      _recenterCamera();
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

  String get formattedDistance {
    if (totalDistanceInMeters < 1000) {
      return '${totalDistanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(totalDistanceInMeters / 1000).toStringAsFixed(2)} km';
    }
  }

  String get formattedDuration {
    if (hikeStartTime == null) return '0:00';
    final duration = DateTime.now().difference(hikeStartTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
