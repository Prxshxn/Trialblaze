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
  StreamSubscription? trackingStream;
  gl.Position? currentPosition;
  double currentZoom = 15.0;

  // Tracking variables
  bool isTracking = true; // Automatically start tracking when navigation begins
  List<gl.Position> trackedPositions = [];
  double totalDistanceInMeters = 0.0;
  Duration totalDuration = Duration.zero;
  DateTime? trackingStartTime;
  DateTime? hikeStartTime;

  @override
  void initState() {
    super.initState();
    _setupPositionTracking();
    _startTracking(); // Start tracking immediately
    hikeStartTime = DateTime.now();
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    trackingStream?.cancel();
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
              onPressed: _finishHike,
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

  Future<void> _finishHike() async {
    // Stop tracking
    trackingStream?.cancel();
    isTracking = false;

    // Calculate final duration
    final hikeDuration = DateTime.now().difference(hikeStartTime!);

    // Get user ID
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
      // Get user's existing stats
      final userResponse = await supabase
          .from('users')
          .select('total_distance, total_hiking_time')
          .eq('id', userId)
          .single();

      // Calculate new totals
      double existingDistance =
          (userResponse['total_distance'] ?? 0).toDouble();
      int existingTimeInSeconds =
          (userResponse['total_hiking_time'] ?? 0).toInt();

      double newDistance =
          existingDistance + (totalDistanceInMeters / 1000); // Convert to km
      int newTimeInSeconds = existingTimeInSeconds + hikeDuration.inSeconds;

      // Update user stats
      await supabase.from('users').update({
        'total_distance': newDistance,
        'total_hiking_time': newTimeInSeconds,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Record this hike
      await supabase.from('user_hikes').insert({
        'user_id': userId,
        'trail_id': widget.trailId,
        'distance_km': totalDistanceInMeters / 1000,
        'duration_seconds': hikeDuration.inSeconds,
        'completed_at': DateTime.now().toIso8601String(),
      });

      Fluttertoast.showToast(
        msg: 'Hike completed! Stats updated.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error updating stats: $e',
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

  void _startTracking() {
    if (!isTracking) {
      setState(() {
        isTracking = true;
        trackingStartTime = DateTime.now();
      });

      // Create location settings with distance filter
      final locationSettings = gl.LocationSettings(
        accuracy: gl.LocationAccuracy.high,
        distanceFilter: 10, // Distance in meters
      );

      trackingStream = gl.Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((position) {
        setState(() {
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
        });
      });
    }
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
    if (!isTracking && trackingStartTime == null) return '0:00';
    final duration = DateTime.now().difference(hikeStartTime!);
    return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
  }
}
