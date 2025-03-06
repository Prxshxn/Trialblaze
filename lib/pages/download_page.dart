import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class DownloadMapPage extends StatefulWidget {
  const DownloadMapPage({super.key});

  @override
  State<DownloadMapPage> createState() => _DownloadMapPageState();
}

class _DownloadMapPageState extends State<DownloadMapPage> {
  final StreamController<double> _stylePackProgress =
      StreamController.broadcast();
  final StreamController<double> _tileRegionLoadProgress =
      StreamController.broadcast();

  TileStore? _tileStore;
  OfflineManager? _offlineManager;
  final _tileRegionId = "my-tile-region";

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cleaning up resources: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing offline map data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
        acceptExpired: false);

    await _offlineManager?.loadStylePack(
        MapboxStyles.OUTDOORS, stylePackLoadOptions, (progress) {
      final percentage =
          progress.completedResourceCount / progress.requiredResourceCount;
      if (!_stylePackProgress.isClosed) {
        _stylePackProgress.sink.add(percentage);
      }
    });
  }

  Future<void> _downloadTileRegion() async {
    final tileRegionLoadOptions = TileRegionLoadOptions(geometry: {
      "type": "Polygon",
      "coordinates": [
        [
          [-122.5, 37.7],
          [-122.4, 37.7],
          [-122.4, 37.8],
          [-122.5, 37.8],
          [-122.5, 37.7]
        ]
      ]
    }, descriptorsOptions: [
      TilesetDescriptorOptions(
          styleURI: MapboxStyles.OUTDOORS, minZoom: 12, maxZoom: 16)
    ], acceptExpired: true, networkRestriction: NetworkRestriction.NONE);

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
    _tileStore?.setDiskQuota(500 * 1024 * 1024); // 500MB quota
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MapWidget(
              key: const ValueKey("mapWidget"),
              styleUri: MapboxStyles.OUTDOORS,
              cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(-122.45, 37.75)),
                  zoom: 12.0),
            ),
          ),
          SizedBox(
            height: 100,
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder(
                    stream: _stylePackProgress.stream,
                    initialData: 0.0,
                    builder: (context, snapshot) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Style pack: ${(snapshot.data ?? 0.0).toStringAsFixed(2)}"),
                          LinearProgressIndicator(value: snapshot.data ?? 0.0),
                        ],
                      );
                    },
                  ),
                  StreamBuilder(
                    stream: _tileRegionLoadProgress.stream,
                    initialData: 0.0,
                    builder: (context, snapshot) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Tile region: ${(snapshot.data ?? 0.0).toStringAsFixed(2)}"),
                          LinearProgressIndicator(value: snapshot.data ?? 0.0),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                await _downloadStylePack();
                await _downloadTileRegion();
                await OfflineSwitch.shared.setMapboxStackConnected(false);
              },
              child: const Text('Download Map'),
            ),
          ),
        ],
      ),
    );
  }
}
