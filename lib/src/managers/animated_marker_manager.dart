import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../controllers/marker_controller.dart';

class AnimatedMarkersManager {
  AnimatedMarkersManager({
    required TickerProvider vsync,
    required Duration duration,
    required this.onUpdateMarkers,
    required this.onRemoveMarkers,
    this.autoRotate = true,
  }) : _duration = duration {
    // 16.67 ms per frame for 60 FPS (1000 ms / 60 FPS) ~= 16.67 ms
    totalFrames = (duration.inMilliseconds / 16.67).round();

    _animationController = AnimationController(vsync: vsync, duration: duration)
      ..addStatusListener(_statusListener)
      ..addListener(listener);
  }

  late final int totalFrames;
  late final AnimationController _animationController;
  final Duration _duration;

  final ValueChanged<Set<Marker>> onUpdateMarkers;
  final ValueChanged<Set<MarkerId>> onRemoveMarkers;
  final bool autoRotate;

  final Map<MarkerId, MarkerController> _controllers = {};

  final Set<MarkerId> _markersToBeRemoved = {};

  int _lastFrameIndex = -1;
  int _updateThrottle = 0;

  // Track animation start time for lifecycle management
  int? _animationStartTime;

  // Maximum queue size to prevent excessive catch-up animations
  static const int _maxQueueSize = 3;

  bool get isAnimating => _animationController.isAnimating;

  void push(Set<Marker> markers) {
    for (var marker in markers) {
      final controller = _controllers[marker.markerId] ??= MarkerController(
        marker: marker,
        animationController: _animationController,
        autoRotate: autoRotate,
      );

      // Limit queue size to prevent excessive catch-up animations
      // If queue is full, clear old items and add only the latest
      if (controller.queueSize >= _maxQueueSize) {
        controller.clearQueue();
      }

      controller.pushToQueue(marker);
    }
    if (!isAnimating) {
      _animateMarkers();
    }
  }

  void _animateMarkers() {
    bool animationRequired = false;
    for (var controller in _controllers.values) {
      if (!animationRequired && controller.hasMarker) {
        animationRequired = true;
      }
      controller.setupNextMarker();
    }

    if (animationRequired) {
      _lastFrameIndex = -1;
      _updateThrottle = 0;
      _animationStartTime = DateTime.now().millisecondsSinceEpoch;

      _animationController.reset();
      _animationController.forward();
    }
  }

  void removeMarker(MarkerId markerId) {
    if (!isAnimating) {
      _controllers.remove(markerId);
      onRemoveMarkers({markerId});
    } else {
      _markersToBeRemoved.add(markerId);
    }
  }

  /// Clear all animation queues for all markers
  /// Useful when resuming from background to prevent catch-up animations
  void clearAllQueues() {
    for (var controller in _controllers.values) {
      controller.clearQueue();
    }
  }

  /// Pause all animations - stops the animation controller
  /// Critical: Call this when the map widget is not visible to prevent buffer overflow
  void pause() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  /// Resume animations - restarts the animation controller if there are pending markers
  void resume() {
    // Don't resume if already animating or no pending markers
    if (_animationController.isAnimating) return;

    final hasPendingMarkers = _controllers.values.any((m) => m.hasMarker);
    if (hasPendingMarkers) {
      _animateMarkers();
    }
  }

  void _clearMarkersToBeRemoved() {
    if (_markersToBeRemoved.isNotEmpty) {
      for (var markerId in _markersToBeRemoved) {
        _controllers.remove(markerId);
      }

      onRemoveMarkers(_markersToBeRemoved.toSet());
      _markersToBeRemoved.clear();
    }
  }

  void _statusListener(AnimationStatus status) {
    if (status case (AnimationStatus.completed || AnimationStatus.dismissed)) {
      _clearMarkersToBeRemoved();

      final isMarkerinQueue = _controllers.values.any((m) => m.hasMarker);

      if (isMarkerinQueue) _animateMarkers();
    }
  }

  void listener() {
    final t = _animationController.value;
    final frameIndex = (t * totalFrames).floor();

    if (frameIndex == _lastFrameIndex) return; // Skip duplicate frames
    _lastFrameIndex = frameIndex;

    // Throttle updates - only update every N frames (reduces flickering)
    _updateThrottle++;
    if (_updateThrottle % 2 != 0 && t < 1.0)
      return; // Update every other frame, except at end

    final Set<Marker> markerPosition = {};

    for (var controller in _controllers.values) {
      markerPosition.add(controller.animate(_animationController.value));
    }
    onUpdateMarkers(markerPosition);
  }

  void dispose() {
    _animationController.removeStatusListener(_statusListener);
    _animationController.removeListener(listener);
    _animationController.dispose();
    _controllers.clear();
    _markersToBeRemoved.clear();
  }
}
