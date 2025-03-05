import 'package:flutter/material.dart';

class DownloadMapPage extends StatefulWidget {
  const DownloadMapPage({super.key});

  @override
  State<DownloadMapPage> createState() => _DownloadMapPageState();
}

class _DownloadMapPageState extends State<DownloadMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Map Page'),
      ),
      body: const Center(
        child: Text('Hello, this is a stateful widget!'),
      ),
    );
  }
}
