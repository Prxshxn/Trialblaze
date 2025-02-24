import 'dart:async';
//import 'dart:io';
import 'package:flutter/services.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:geolocator/geolocator.dart' as gl;
import 'package:supabase_flutter/supabase_flutter.dart';

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
                backgroundColor: isTracking ? Colors.red : Colors.green,
                onPressed: _toggleTracking,
                child: Icon(isTracking ? Icons.pause : Icons.play_arrow),
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

    final pointAnnotationManager =
        await mapboxMapController?.annotations.createPointAnnotationManager();
    final Uint8List imageData = await loadMarkerImage();
    mp.PointAnnotationOptions pointAnnotationOptions =
        mp.PointAnnotationOptions(
      image: imageData,
      iconSize: 0.3,
      geometry: mp.Point(
        coordinates: mp.Position(
          79.909475,
          7.102291,
        ),
      ),
    );

    pointAnnotationManager?.create(pointAnnotationOptions);

    final polylineAnnotationManager = await mapboxMapController?.annotations
        .createPolylineAnnotationManager();

    List<mp.Position> polylineCoordinates = [
      mp.Position(79.909475, 7.102291),
      mp.Position(79.910475, 7.102291),
      mp.Position(79.911475, 7.102291),
    ];

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
    if (isTracking) {
      _pauseTracking();
    } else {
      _startTracking();
    }
  }

  void _startTracking() {
    if (!isTracking) {
      setState(() {
        isTracking = true;
        isPaused = false;
      });
      trackingStream = gl.Geolocator.getPositionStream().listen((position) {
        setState(() {
          trackedPositions.add(position);
        });
        _updatePolyline();
        print('Logged Position: ${position.latitude}, ${position.longitude}');
      });
    } else if (isPaused) {
      setState(() {
        isPaused = false;
      });
      trackingStream?.resume();
    }
  }

  void _pauseTracking() {
    if (isTracking) {
      setState(() {
        isPaused = true;
      });
      trackingStream?.pause();
    }
  }

  Future<void> _saveTrail() async {
    if (trackedPositions.isEmpty) {
      print('No coordinates to save');
      return;
    }

    final trailId = await saveTrail('My Trail', 'Description of my trail');
    if (trailId != null) {
      await _saveToSupabase(trailId);
      print('Trail and coordinates saved to Supabase');
    }

    if (isTracking) {
      setState(() {
        isTracking = false;
        isPaused = false;
        trackedPositions.clear();
      });
      trackingStream?.cancel();
      trackingStream = null;
    }
  }

  Future<String?> saveTrail(String name, String description) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('trails')
          .insert({'name': name, 'description': description})
          .select('id')
          .single();
      return response['id'] as String?;
    } catch (e) {
      print('Error saving trail: $e');
      return null;
    }
  }

  Future<void> _saveToSupabase(String trailId) async {
    final supabase = Supabase.instance.client;

    try {
      for (var position in trackedPositions) {
        await supabase.from('coordinates').insert({
          'trail_id': trailId,
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }
      print('All coordinates saved to Supabase for trail $trailId');
    } catch (e) {
      print('Error saving coordinates: $e');
    }
  }

  Future<Uint8List> loadMarkerImage() async {
    var byteData = await rootBundle.load(
      "assets/icons/location_mark.png",
    );
    return byteData.buffer.asUint8List();
  }
}
