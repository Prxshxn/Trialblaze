import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:geolocator/geolocator.dart' as gl;

class LocationMarkerPage extends StatefulWidget {
  const LocationMarkerPage({super.key});

  @override
  State<LocationMarkerPage> createState() => _LocationMarkerPage();
}

class _LocationMarkerPage extends State<LocationMarkerPage> {
  mp.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  StreamSubscription? trackingStream;
  gl.Position? currentPosition;
  double currentZoom = 15.0;
  bool isTracking = false;
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
              bottom: 260,
              right: 20,
              child: Hero(
                tag: 'startTracking',
                child: FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.green,
                  onPressed: _startTracking,
                  child: const Icon(Icons.play_arrow),
                ),
              )),
          Positioned(
              bottom: 320,
              right: 20,
              child: Hero(
                tag: 'stopTracking',
                child: FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.red,
                  onPressed: _stopTracking,
                  child: const Icon(Icons.stop),
                ),
              )),
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

  void _startTracking() {
    if (!isTracking) {
      setState(() {
        isTracking = true;
        trackedPositions.clear();
      });
      trackingStream = gl.Geolocator.getPositionStream().listen((position) {
        setState(() {
          trackedPositions.add(position);
        });
        print('Logged Position: ${position.latitude}, ${position.longitude}');
      });
    }
  }

  void _stopTracking() async {
    if (isTracking) {
      setState(() {
        isTracking = false;
      });
      trackingStream?.cancel();
      trackingStream = null;
      await _saveToFile();
    }
  }

  Future<void> _saveToFile() async {
    final directory =
        await getExternalStorageDirectory(); // Use external storage
    final file = File('${directory?.path}/tracked_coordinates.txt');
    String data =
        trackedPositions.map((p) => '${p.latitude}, ${p.longitude}').join('\n');
    await file.writeAsString(data);
    print('File saved at: ${file.path}');
  }

  Future<Uint8List> loadMarkerImage() async {
    var byteData = await rootBundle.load(
      "assets/icons/location_mark.png",
    );
    return byteData.buffer.asUint8List();
  }
}
