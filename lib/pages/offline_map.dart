import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:geolocator/geolocator.dart' as gl;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class OfflineNavigationPage extends StatefulWidget {
  final String trailId; // Trail ID to identify the saved file
  const OfflineNavigationPage({super.key, required this.trailId});

  @override
  State<OfflineNavigationPage> createState() => _OfflineNavigationPageState();
}

class _OfflineNavigationPageState extends State<OfflineNavigationPage> {
  mp.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  gl.Position? currentPosition;
  double currentZoom = 15.0;
  List<Map<String, double>> trailCoordinates = []; // Store trail coordinates

  @override
  void initState() {
    super.initState();
    _setupPositionTracking();
    _loadTrailCoordinatesFromFile().then((coordinates) {
      setState(() {
        trailCoordinates = coordinates;
      });
    });
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
        ],
      ),
    );
  }

  // Load trail coordinates from the saved file
  Future<List<Map<String, double>>> _loadTrailCoordinatesFromFile() async {
    List<Map<String, double>> coordinates = [];
    try {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/trail_${widget.trailId}.txt');

      if (await file.exists()) {
        final content = await file.readAsString();
        final lines = content.split('\n');

        // Flag to indicate when we start parsing coordinates
        bool isParsingCoordinates = false;

        // Parse coordinates from the file
        for (var line in lines) {
          // Skip empty lines
          if (line.trim().isEmpty) continue;

          // Check if we've reached the "Coordinates:" line
          if (line.startsWith('Coordinates:')) {
            isParsingCoordinates = true;
            continue; // Skip the "Coordinates:" line itself
          }

          // If we're parsing coordinates, process the line
          if (isParsingCoordinates) {
            final parts = line.split(',');
            if (parts.length == 2) {
              final latitude = double.tryParse(parts[0].trim());
              final longitude = double.tryParse(parts[1].trim());
              if (latitude != null && longitude != null) {
                coordinates.add({
                  'latitude': latitude,
                  'longitude': longitude,
                });
              }
            }
          }
        }

        // Update the map with the loaded coordinates
        if (coordinates.isNotEmpty && mapboxMapController != null) {
          _updateMapWithCoordinates(coordinates);
        }
      }
    } catch (e) {
      // Handle errors silently
    }

    return coordinates;
  }

  // Update the map with the loaded coordinates
  void _updateMapWithCoordinates(List<Map<String, double>> coordinates) {
    // Convert coordinates to a list of `mp.Position`
    List<mp.Position> polylineCoordinates = coordinates.map((coord) {
      return mp.Position(coord['longitude']!, coord['latitude']!);
    }).toList();

    // Create a polyline annotation manager
    mapboxMapController?.annotations
        .createPolylineAnnotationManager()
        .then((manager) {
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
      manager.create(polylineAnnotationOptions);
    });

    // Set camera to the first coordinate
    if (coordinates.isNotEmpty) {
      final firstCoord = coordinates.first;
      mapboxMapController?.flyTo(
        mp.CameraOptions(
          center: mp.Point(
            coordinates:
                mp.Position(firstCoord['longitude']!, firstCoord['latitude']!),
          ),
          zoom: currentZoom,
        ),
        mp.MapAnimationOptions(duration: 1000),
      );
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

    // If coordinates are already loaded, update the map
    if (trailCoordinates.isNotEmpty) {
      _updateMapWithCoordinates(trailCoordinates);

      // Set camera to the first coordinate
      final firstCoord = trailCoordinates.first;
      mapboxMapController?.flyTo(
        mp.CameraOptions(
          center: mp.Point(
            coordinates:
                mp.Position(firstCoord['longitude']!, firstCoord['latitude']!),
          ),
          zoom: currentZoom,
        ),
        mp.MapAnimationOptions(duration: 1000),
      );
    }
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
