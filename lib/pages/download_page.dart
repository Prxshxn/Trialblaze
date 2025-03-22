import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

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
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initOfflineMap();
  }

  @override
  void dispose() {
    _stylePackProgress.close();
    _tileRegionLoadProgress.close();

    // Fix the error by not calling removeRegion in dispose
    // Instead just reconnect the mapbox stack
    try {
      // Don't use await here to prevent blocking during navigation
      OfflineSwitch.shared.setMapboxStackConnected(true);
    } catch (e) {
      // Just log the error, don't show toast during navigation
      print("Error reconnecting mapbox stack: $e");
    }

    super.dispose();
  }

  // This method is modified to not rethrow exceptions
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
      // Don't rethrow the exception - this is the critical fix
      print("Error in _removeTileRegionAndStylePack: $e");
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

  Future<void> _startDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      await _downloadStylePack();
      await _downloadTileRegion();
      await _saveTrailDetailsToFile();
      await OfflineSwitch.shared.setMapboxStackConnected(false);
      setState(() {
        _isMapDownloaded = true;
        _isDownloading = false;
      });
      Fluttertoast.showToast(
        msg: 'Map downloaded successfully!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      Fluttertoast.showToast(
        msg: 'Error downloading map: ${e.toString()}',
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
        title: Text(
          trailName.isNotEmpty ? trailName : 'Download Map',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Map takes full screen
          MapWidget(
            key: const ValueKey("mapWidget"),
            styleUri: MapboxStyles.OUTDOORS,
            cameraOptions: CameraOptions(
              center: trailCoordinates.isNotEmpty
                  ? Point(
                      coordinates: Position(trailCoordinates.first['longitude'],
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
                          coordinates: Position(
                              firstCoord['longitude'], firstCoord['latitude'])),
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
                          coordinates: Position(
                              firstCoord['longitude'], firstCoord['latitude'])),
                      zoom: 12.0,
                    ),
                    MapAnimationOptions(duration: 1000),
                  );
                }
              }
            },
          ),

          // Bottom sheet with progress and download button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress indicator
                      if (_isDownloading) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Text(
                                'Downloading map',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              StreamBuilder<double>(
                                stream: _stylePackProgress.stream,
                                initialData: 0.0,
                                builder: (context, snapshot) {
                                  final progress = snapshot.data ?? 0.0;
                                  return Text(
                                    '${(progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: StreamBuilder<double>(
                            stream: _stylePackProgress.stream,
                            initialData: 0.0,
                            builder: (context, snapshot) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: snapshot.data ?? 0.0,
                                  backgroundColor: Colors.grey[850],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.green),
                                  minHeight: 4,
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      // Download button or status
                      _isMapDownloaded
                          ? Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Map available offline',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : ElevatedButton.icon(
                              onPressed: _isDownloading ? null : _startDownload,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                disabledBackgroundColor:
                                    Colors.green.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: _isDownloading
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      padding: const EdgeInsets.all(4),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.download,
                                      color: Colors.white),
                              label: Text(
                                _isDownloading
                                    ? 'DOWNLOADING...'
                                    : 'DOWNLOAD MAP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
