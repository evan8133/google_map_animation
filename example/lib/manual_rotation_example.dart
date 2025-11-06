import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map_animation/google_map_animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Example demonstrating manual marker rotation control
/// This shows how to disable automatic rotation and control it yourself
class ManualRotationExample extends StatefulWidget {
  const ManualRotationExample({super.key});

  @override
  State<ManualRotationExample> createState() => _ManualRotationExampleState();
}

class _ManualRotationExampleState extends State<ManualRotationExample>
    with TickerProviderStateMixin {
  GoogleMapController? mapController;
  MapAnimationController? mapAnimationController;

  Timer? _timer;
  double _currentRotation = 0.0;

  final List<LatLng> _route = [
    const LatLng(23.02246, 72.59891),
    const LatLng(23.02346, 72.59991),
    const LatLng(23.02446, 72.60091),
    const LatLng(23.02546, 72.60191),
  ];

  int _currentIndex = 0;

  final Map<MarkerId, Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    // Initialize marker
    _markers[const MarkerId('manual')] = Marker(
      markerId: const MarkerId('manual'),
      position: _route[0],
      rotation: _currentRotation,
    );

    // Update marker position and rotation manually
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _currentIndex = (_currentIndex + 1) % _route.length;

      // Increment rotation manually (e.g., rotate 45 degrees each time)
      _currentRotation = (_currentRotation + 45) % 360;

      _markers.update(
        const MarkerId('manual'),
        (marker) => marker.copyWith(
          positionParam: _route[_currentIndex],
          rotationParam: _currentRotation, // Manual rotation control
        ),
      );

      mapAnimationController?.updateMarkers(_markers.values.toSet());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    mapAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Rotation Example'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manual Rotation Control',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'autoRotateMarkers: false\nCurrent rotation: ${_currentRotation.toStringAsFixed(0)}°',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The marker rotates 45° each time it moves, regardless of movement direction.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _route[0],
                zoom: 16.0,
              ),
              onMapCreated: (controller) {
                mapController = controller;
                mapAnimationController = MapAnimationController(
                  mapId: controller.mapId,
                  vsync: this,
                  markers: _markers.values.toSet(),
                  autoRotateMarkers: false, // Disable automatic rotation
                );
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: _route,
                  color: Colors.deepPurple,
                  width: 3,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
