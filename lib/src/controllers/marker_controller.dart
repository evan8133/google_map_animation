import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../tween/bearing_tween.dart';
import '../tween/location_tween.dart';

class MarkerController {
  final AnimationController _animationController;
  final bool autoRotate;

  late final LocationTween _locationTween;
  late final BearingTween _bearingTween;

  Marker _currentMarker;
  Marker get currentMarker => _currentMarker;

  final Queue<Marker> _queue = Queue<Marker>();

  bool get hasMarker => _queue.isNotEmpty;
  int get queueSize => _queue.length;

  MarkerController({
    required Marker marker,
    required AnimationController animationController,
    this.autoRotate = true,
  }) : _currentMarker = marker,
       _animationController = animationController {
    _locationTween = LocationTween(
      begin: marker.position,
      end: marker.position,
    );

    _bearingTween = BearingTween(
      begin: marker.rotation,
      end: marker.rotation,
    );

    _locationTween.animate(_animationController);
    _bearingTween.animate(_animationController);
  }

  void pushToQueue(Marker m) {
    // Skip if marker hasn't actually moved (prevents unnecessary animations)
    if (_currentMarker.position == m.position &&
        _currentMarker.rotation == m.rotation) {
      return;
    }

    _queue.addLast(m);
  }

  /// Clear all queued markers except the last one
  /// This prevents excessive catch-up animations when returning to the screen
  void clearQueue() {
    if (_queue.isEmpty) return;
    final lastMarker = _queue.last;
    _queue.clear();
    _queue.addLast(lastMarker);
  }

  void setupNextMarker() {
    if (_queue.isEmpty) return;
    final nextMarker = _queue.removeFirst();
    _setupTo(nextMarker);
    // Reset cache when setting up new animation
    resetCache();
  }

  void _setupTo(Marker m) {
    _currentMarker = m;
    _locationTween.swap(m.position);
    if (autoRotate) {
      _bearingTween.swap(_locationTween.bearing);
    } else {
      _bearingTween.swap(m.rotation);
    }
  }

  // Cache the last animated marker to reduce object creation
  Marker? _lastAnimatedMarker;
  double _lastT = -1.0;

  Marker animate(double t) {
    // Return cached marker if t hasn't changed significantly (reduces flickering)
    if (_lastT == t && _lastAnimatedMarker != null) {
      return _lastAnimatedMarker!;
    }

    _lastT = t;
    _lastAnimatedMarker = _currentMarker.copyWith(
      positionParam: _locationTween.lerp(t),
      rotationParam: _bearingTween.lerp(t),
    );

    return _lastAnimatedMarker!;
  }

  /// Reset animation cache
  void resetCache() {
    _lastAnimatedMarker = null;
    _lastT = -1.0;
  }
}
