import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:geolocator/geolocator.dart' as gl;
import 'package:createtrial/pages/trail_details.dart';

class AnnotatePage extends StatefulWidget {
  const AnnotatePage({super.key});

  @override
  State<AnnotatePage> createState() => _AnnotatePage();
}

class _AnnotatePage extends State<AnnotatePage> {
  mp.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  StreamSubscription? trackingStream;
  gl.Position? currentPosition;
  double currentZoom = 15.0;
  bool isTracking = false;
  bool isPaused = false;
  List<gl.Position> trackedPositions = [];
  double totalDistanceInMeters = 0.0;
  Duration totalDuration = Duration.zero;
  DateTime? trackingStartTime;

  @override
  void initState() {
    super.initState();
    _setupPositionTracking();
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
            child: Hero(
              tag: 'toggleTracking',
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: isTracking
                    ? (isPaused ? Colors.orange : Colors.red)
                    : Colors.green,
                onPressed: _toggleTracking,
                child: Icon(isTracking
                    ? (isPaused ? Icons.play_arrow : Icons.pause)
                    : Icons.play_arrow),
              ),
            ),
          ),
          Positioned(
            bottom: 320,
            right: 20,
            child: Hero(
              tag: 'saveButton',
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.blue,
                onPressed: _saveTrail,
                child: const Icon(Icons.save),
              ),
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
  }

  void _updatePolyline() async {
    final polylineAnnotationManager = await mapboxMapController?.annotations
        .createPolylineAnnotationManager();

    List<mp.Position> polylineCoordinates = trackedPositions
        .map((position) => mp.Position(position.longitude, position.latitude))
        .toList();

    mp.PolylineAnnotationOptions polylineAnnotationOptions =
        mp.PolylineAnnotationOptions(
      geometry: mp.LineString(
        coordinates: polylineCoordinates,
      ),
      lineColor: Colors.blue.value,
      lineWidth: 5.0,
    );

    // Clear existing polyline annotations
    polylineAnnotationManager?.deleteAll();

    // Add the updated polyline annotation to the map
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
      distanceFilter: 10,
    );

    userPositionStream?.cancel();
    userPositionStream =
        gl.Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((gl.Position? position) {
      if (position != null) {
        setState(() {
          currentPosition = position;
        });
        mapboxMapController?.flyTo(
          mp.CameraOptions(
            zoom: currentZoom,
            center: mp.Point(
              coordinates: mp.Position(position.longitude, position.latitude),
            ),
          ),
          mp.MapAnimationOptions(duration: 1000),
        );
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

  void _toggleTracking() {
    if (!isTracking) {
      // Start tracking if not already tracking
      _startTracking();
    } else if (isTracking && !isPaused) {
      // Pause tracking if tracking is active and not paused
      _pauseTracking();
    } else if (isTracking && isPaused) {
      // Resume tracking if tracking is active and paused
      _startTracking();
    }
  }

  void _startTracking() {
    if (!isTracking) {
      setState(() {
        isTracking = true;
        isPaused = false;
        trackingStartTime = DateTime.now();
      });
      trackingStream = gl.Geolocator.getPositionStream().listen((position) {
        setState(() {
          if (trackedPositions.isNotEmpty) {
            // Calculate distance from last point
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
        _updatePolyline();
      });
    } else if (isPaused) {
      setState(() {
        isPaused = false;
        trackingStartTime = DateTime.now();
      });
      trackingStream?.resume();
    }
  }

  void _pauseTracking() {
    if (isTracking) {
      setState(() {
        isPaused = true;
        totalDuration += DateTime.now().difference(trackingStartTime!);
        trackingStartTime = null;
      });
      trackingStream?.pause();
    }
  }

  Future<void> _saveTrail() async {
    if (trackedPositions.isEmpty) {
      print('No coordinates to save');
      return;
    }

    // Navigate to TrailDetails page and pass the tracked data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrailDetails(
          trackedPositions: trackedPositions,
          totalDistanceInMeters: totalDistanceInMeters,
          totalDuration: isPaused
              ? totalDuration
              : totalDuration +
                  DateTime.now()
                      .difference(trackingStartTime ?? DateTime.now()),
          onTrailSaved: () {
            // Reset tracking state
            setState(() {
              isTracking = false;
              isPaused = false;
              trackedPositions.clear();
              totalDistanceInMeters = 0.0;
              totalDuration = Duration.zero;
              trackingStartTime = null;
            });
            trackingStream?.cancel();
            trackingStream = null;
          },
        ),
      ),
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
    final duration = isPaused
        ? totalDuration
        : totalDuration + DateTime.now().difference(trackingStartTime!);
    return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
  }
}
