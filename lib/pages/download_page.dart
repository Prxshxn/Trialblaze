import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast

class DownloadMapPage extends StatefulWidget {
  final String trailId;
  const DownloadMapPage({super.key, required this.trailId});

  @override
  State<DownloadMapPage> createState() => _DownloadMapPageState();
}

class _DownloadMapPageState extends State<DownloadMapPage> {
  MapboxMap? mapboxMapController;
  final StreamController<double> _stylePackProgress =
      StreamController.broadcast();
  final StreamController<double> _tileRegionLoadProgress =
      StreamController.broadcast();
  TileStore? _tileStore;
  OfflineManager? _offlineManager;
  final String _tileRegionId = "my-tile-region";
  List<Map<String, dynamic>> trailCoordinates = [];
  String trailName = '';
  String trailDescription = '';
  bool _isMapDownloaded = false;

  @override
  void initState() {
    super.initState();
    _initOfflineMap();
  }

  @override
  void dispose() async {
    super.dispose();
    try {
      await OfflineSwitch.shared.setMapboxStackConnected(true);
      await _removeTileRegionAndStylePack();
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error cleaning up resources: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _removeTileRegionAndStylePack() async {
    try {
      await _tileStore?.removeRegion(_tileRegionId);
      _tileStore?.setDiskQuota(0);
      await _offlineManager?.removeStylePack(MapboxStyles.OUTDOORS);
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error removing offline map data: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      rethrow;
    }
  }

  Future<void> _downloadStylePack() async {
    final stylePackLoadOptions = StylePackLoadOptions(
      glyphsRasterizationMode:
          GlyphsRasterizationMode.IDEOGRAPHS_RASTERIZED_LOCALLY,
      metadata: {"tag": "test"},
      acceptExpired: false,
    );

    await _offlineManager?.loadStylePack(
      MapboxStyles.OUTDOORS,
      stylePackLoadOptions,
      (progress) {
        final percentage =
            progress.completedResourceCount / progress.requiredResourceCount;
        if (!_stylePackProgress.isClosed) {
          _stylePackProgress.sink.add(percentage);
        }
      },
    );
  }

  Future<void> _downloadTileRegion() async {
    if (trailCoordinates.isEmpty) {
      Fluttertoast.showToast(
        msg: 'No trail coordinates available.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      throw Exception("No trail coordinates available.");
    }

    double minLat = trailCoordinates[0]['latitude'];
    double maxLat = trailCoordinates[0]['latitude'];
    double minLng = trailCoordinates[0]['longitude'];
    double maxLng = trailCoordinates[0]['longitude'];

    for (var coord in trailCoordinates) {
      minLat = math.min(minLat, coord['latitude']);
      maxLat = math.max(maxLat, coord['latitude']);
      minLng = math.min(minLng, coord['longitude']);
      maxLng = math.max(maxLng, coord['longitude']);
    }

    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;

    final geometry = {
      "type": "Polygon",
      "coordinates": [
        [
          [minLng - lngPadding, minLat - latPadding],
          [maxLng + lngPadding, minLat - latPadding],
          [maxLng + lngPadding, maxLat + latPadding],
          [minLng - lngPadding, maxLat + latPadding],
          [minLng - lngPadding, minLat - latPadding],
        ]
      ]
    };

    final tileRegionLoadOptions = TileRegionLoadOptions(
      geometry: geometry,
      descriptorsOptions: [
        TilesetDescriptorOptions(
            styleURI: MapboxStyles.OUTDOORS, minZoom: 12, maxZoom: 16)
      ],
      acceptExpired: true,
      networkRestriction: NetworkRestriction.NONE,
    );

    await _tileStore?.loadTileRegion(_tileRegionId, tileRegionLoadOptions,
        (progress) {
      final percentage =
          progress.completedResourceCount / progress.requiredResourceCount;
      if (!_tileRegionLoadProgress.isClosed) {
        _tileRegionLoadProgress.sink.add(percentage);
      }
    });
  }

  Future<void> _initOfflineMap() async {
    _offlineManager = await OfflineManager.create();
    _tileStore = await TileStore.createDefault();
    _tileStore?.setDiskQuota(500 * 1024 * 1024);
    await _fetchTrailCoordinates();
  }

  Future<void> _fetchTrailCoordinates() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('trails')
          .select('name, description, coordinates(latitude, longitude)')
          .eq('id', widget.trailId)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          trailName = response['name'];
          trailDescription = response['description'];
          trailCoordinates =
              List<Map<String, dynamic>>.from(response['coordinates']);
        });

        // Calculate center point
        double avgLat = 0.0, avgLng = 0.0;
        for (var coord in trailCoordinates) {
          avgLat += coord['latitude'];
          avgLng += coord['longitude'];
        }
        avgLat /= trailCoordinates.length;
        avgLng /= trailCoordinates.length;

        // Update map camera if controller is available
        if (mapboxMapController != null) {
          mapboxMapController?.flyTo(
            CameraOptions(
              center: Point(coordinates: Position(avgLng, avgLat)),
              zoom: 12.0,
            ),
            MapAnimationOptions(duration: 1000),
          );
        }

        // Set camera to the first coordinate
        if (trailCoordinates.isNotEmpty) {
          final firstCoord = trailCoordinates.first;
          mapboxMapController?.flyTo(
            CameraOptions(
              center: Point(
                  coordinates: Position(
                      firstCoord['longitude'], firstCoord['latitude'])),
              zoom: 12.0,
            ),
            MapAnimationOptions(duration: 1000),
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error fetching trail coordinates: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _saveTrailDetailsToFile() async {
    try {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/trail_${widget.trailId}.txt');

      String trailData = 'Trail Name: $trailName\n'
          'Description: $trailDescription\n'
          'Coordinates:\n';

      for (var coord in trailCoordinates) {
        trailData += '${coord['latitude']}, ${coord['longitude']}\n';
      }

      await file.writeAsString(trailData);
      Fluttertoast.showToast(
        msg: 'Trail details saved to ${file.path}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error saving trail details: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
            const Text('Download Map', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: MapWidget(
              key: const ValueKey("mapWidget"),
              styleUri: MapboxStyles.OUTDOORS,
              cameraOptions: CameraOptions(
                center: trailCoordinates.isNotEmpty
                    ? Point(
                        coordinates: Position(
                            trailCoordinates.first['longitude'],
                            trailCoordinates.first['latitude']))
                    : Point(coordinates: Position(-122.45, 37.75)),
                zoom: 12.0,
              ),
              onMapCreated: (MapboxMap mapboxMap) async {
                setState(() {
                  mapboxMapController = mapboxMap;
                });

                try {
                  if (trailCoordinates.isNotEmpty) {
                    final firstCoord = trailCoordinates.first;
                    await mapboxMap.flyTo(
                      CameraOptions(
                        center: Point(
                            coordinates: Position(firstCoord['longitude'],
                                firstCoord['latitude'])),
                        zoom: 12.0,
                      ),
                      MapAnimationOptions(duration: 1000),
                    );
                  }
                } catch (e) {
                  await OfflineSwitch.shared.setMapboxStackConnected(true);
                  if (trailCoordinates.isNotEmpty) {
                    final firstCoord = trailCoordinates.first;
                    await mapboxMap.flyTo(
                      CameraOptions(
                        center: Point(
                            coordinates: Position(firstCoord['longitude'],
                                firstCoord['latitude'])),
                        zoom: 12.0,
                      ),
                      MapAnimationOptions(duration: 1000),
                    );
                  }
                }
              },
            ),
          ),
          StreamBuilder(
            stream: _stylePackProgress.stream,
            initialData: 0.0,
            builder: (context, snapshot) {
              return LinearProgressIndicator(
                value: snapshot.data ?? 0.0,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await _downloadStylePack();
                  await _downloadTileRegion();
                  await _saveTrailDetailsToFile();
                  await OfflineSwitch.shared.setMapboxStackConnected(false);
                  setState(() {
                    _isMapDownloaded = true;
                  });
                  Fluttertoast.showToast(
                    msg: 'Map downloaded successfully!',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: 'Error downloading map: ${e.toString()}',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Download Map',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
