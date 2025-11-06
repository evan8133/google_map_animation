import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map_animation/google_map_animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Example showing proper lifecycle management to prevent buffer overflow errors
/// when navigating between screens.
///
/// CRITICAL: Always call pause() when navigating away and resume() when returning
class ProperLifecycleExample extends StatefulWidget {
  const ProperLifecycleExample({super.key});

  @override
  State<ProperLifecycleExample> createState() => _ProperLifecycleExampleState();
}

class _ProperLifecycleExampleState extends State<ProperLifecycleExample>
    with TickerProviderStateMixin, RouteAware {
  GoogleMapController? mapController;
  MapAnimationController? mapAnimationController;
  Timer? _updateTimer;

  final LatLng _currentPosition = const LatLng(23.02246, 72.59891);

  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _marker = Marker(
      markerId: const MarkerId('vehicle'),
      position: _currentPosition,
    );

    // Start location updates
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      // Simulate location updates
      // In real app, this would come from location service or provider
      final newPosition = LatLng(
        _currentPosition.latitude + (0.0001 * (DateTime.now().second % 10)),
        _currentPosition.longitude + (0.0001 * (DateTime.now().second % 10)),
      );

      setState(() {
        _marker = _marker?.copyWith(positionParam: newPosition);
      });

      // Only update if controller exists and not paused
      if (_marker != null) {
        mapAnimationController?.updateMarkers({_marker!});
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    mapAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Lifecycle Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              // CRITICAL: Pause animations before navigating away
              mapAnimationController?.pause();

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );

              // CRITICAL: Resume animations when returning
              mapAnimationController?.resume();
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 16.0,
        ),
        onMapCreated: (controller) {
          mapController = controller;
          mapAnimationController = MapAnimationController(
            mapId: controller.mapId,
            vsync: this,
            markers: _marker != null ? {_marker!} : {},
            autoRotateMarkers: true,
            markersAnimationDuration: const Duration(milliseconds: 1500),
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}

/// Example using with Provider pattern (common use case)
///
/// If you're using Provider to manage map state globally, you need to handle
/// pause/resume in your provider's lifecycle methods.
class MapProviderExample extends ChangeNotifier {
  MapAnimationController? _mapAnimationController;
  Timer? _updateTimer;
  bool _isPaused = false;

  final Map<MarkerId, Marker> _markers = {};

  void initialize(MapAnimationController controller) {
    _mapAnimationController = controller;
    _startUpdates();
  }

  void _startUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_isPaused) {
        // Don't queue updates when paused
        return;
      }

      // Update markers...
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    // Your marker update logic here
    if (_markers.isNotEmpty && !_isPaused) {
      _mapAnimationController?.updateMarkers(_markers.values.toSet());
    }
  }

  /// Call this when navigating away from map screen
  void pauseAnimations() {
    _isPaused = true;
    _mapAnimationController?.pause();
    debugPrint('MapProvider: Animations paused');
  }

  /// Call this when returning to map screen
  void resumeAnimations() {
    _isPaused = false;
    _mapAnimationController?.resume();
    debugPrint('MapProvider: Animations resumed');
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _mapAnimationController?.dispose();
    super.dispose();
  }
}

/// Using with RouteAware for automatic pause/resume
/// This is the most robust solution as it handles navigation automatically
class AutoLifecycleMapScreen extends StatefulWidget {
  const AutoLifecycleMapScreen({super.key});

  @override
  State<AutoLifecycleMapScreen> createState() => _AutoLifecycleMapScreenState();
}

class _AutoLifecycleMapScreenState extends State<AutoLifecycleMapScreen>
    with TickerProviderStateMixin, RouteAware {
  MapAnimationController? mapAnimationController;
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    // Called when a new route is pushed on top of this route
    debugPrint('Map screen: Route pushed on top - PAUSING animations');
    mapAnimationController?.pause();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and this route shows up
    debugPrint('Map screen: Returned to view - RESUMING animations');
    mapAnimationController?.resume();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto-Lifecycle Map')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(23.02246, 72.59891),
          zoom: 16.0,
        ),
        onMapCreated: (controller) {
          mapAnimationController = MapAnimationController(
            mapId: controller.mapId,
            vsync: this,
            autoRotateMarkers: true,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    mapAnimationController?.dispose();
    super.dispose();
  }
}
