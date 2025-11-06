# Google Map Animation

A Flutter library for creating smooth, customizable polyline and marker animations directly on Google Maps. 
Bring your maps to life with beautiful animations that enhance user experience.


[![Pub Version](https://img.shields.io/pub/v/google_map_animation)](https://pub.dev/packages/google_map_animation)
[![Flutter](https://img.shields.io/badge/Flutter->=3.24.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart->=3.8.1-blue.svg)](https://dart.dev/)


## ⚠️ Important Note

This library focuses **exclusively** on animating polylines and markers on Google Maps. Google Maps configuration and setup is **out of scope** for this library. Before using this library, please ensure you have properly configured Google Maps in your Flutter project.

For Google Maps setup instructions, refer to the [official Google Maps Flutter documentation](https://pub.dev/packages/google_maps_flutter).


## GIF

<div align="center">
  <img src="https://raw.githubusercontent.com/manishrelani/google_map_animation/646f6dbcc19ff80d8e6edaf53ab61c257fd90ae6/assets/markers.gif" alt="Marker Animation" width="300" height= "600" /> &nbsp;&nbsp;&nbsp;&nbsp; <img src="https://raw.githubusercontent.com/manishrelani/google_map_animation/646f6dbcc19ff80d8e6edaf53ab61c257fd90ae6/assets/polyline.gif" alt="Polyline Animation" width="300" height= "600"/>

</div> 




## Features

✨ **Animated Polylines**: Create smooth polyline animations with delay

🎯 **Marker Animation**: Smooth marker transitions with customizable duration

⚡ **Performance**: Optimized for smooth animations

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  google_map_animation: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### ⚠️ Important: Marker Management

**DO NOT** set markers on both the `GoogleMap` widget **AND** the `MapAnimationController`. This will cause duplicate markers to appear on the map.

**❌ Wrong - Will cause duplicates:**
```dart
GoogleMap(
  markers: myMarkers, // ❌ Don't do this
  onMapCreated: (controller) {
    mapAnimationController = MapAnimationController(
      mapId: controller.mapId,
      vsync: this,
      markers: myMarkers, // ❌ Don't pass markers here too
    );
  },
)
```

**✅ Correct - Let MapAnimationController manage markers:**
```dart
GoogleMap(
  // Don't set markers parameter
  onMapCreated: (controller) {
    mapAnimationController = MapAnimationController(
      mapId: controller.mapId,
      vsync: this,
      markers: myMarkers, // ✅ Only set markers here
    );
  },
)
```

### Basic Setup

```dart
import 'package:google_map_animation/google_map_animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  GoogleMapController? mapController;
  MapAnimationController? mapAnimationController;

  @override
  void dispose() {
    mapAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        mapController = controller;
        mapAnimationController = MapAnimationController(
          mapId: controller.mapId,
          vsync: this,
        );
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(23.0181, 72.5897),
        zoom: 14.0,
      ),
      // Do NOT set markers: parameter here if using MapAnimationController
    );
  }
}
```

### Polyline Animations


#### Fade In Progressive Animation

Gradually increases opacity and then progressively draws the polyline:

```dart
final animatedPolyline = AnimatedPolyline(
  polyline: Polyline(
    polylineId: PolylineId('fade_route'),
    points: routeCoordinates,
    color: Colors.red,
    width: 5,
  ),
  polylineAnimator: FadeInProgressiveAnimator(
    duration: Duration(seconds: 5),
    curve: Curves.ease,
    repeat: true,
    delayStart: Duration(milliseconds: 500),
    delayEnd: Duration(milliseconds: 1000),
  ),
);

mapAnimationController?.updatePolylines({animatedPolyline});
```


### Marker Animation

Animate markers with smooth transitions:

```dart
// Add markers with animation
final markers = <Marker>{
  Marker(
    markerId: MarkerId('marker_1'),
    position: LatLng(23.0181, 72.5897),
    infoWindow: InfoWindow(title: 'Point 1'),
  ),
  Marker(
    markerId: MarkerId('marker_2'),
    position: LatLng(23.0220, 72.5950),
    infoWindow: InfoWindow(title: 'Point 2'),
  ),
};

mapAnimationController?.updateMarkers(markers);

// Clear all markers from the map
mapAnimationController?.clearMarkers();
```

#### Marker Management Methods

- **`updateMarkers(Set<Marker> markers)`**: Add or update markers with animation
- **`clearMarkers()`**: Remove all markers from the map at once



## Animation Properties

### PolylineAnimator Properties

All animators inherit from `PolylineAnimator` and support these properties:

- **`duration`**: Animation duration (default: varies by animator)
- **`curve`**: Animation curve (default: `Curves.linear`)
- **`repeat`**: Whether to repeat the animation (default: `false`)
- **`repeatCount`**: Number of times to repeat (null = infinite)
- **`reverse`**: Whether to reverse the animation (default: `false`)
- **`delayStart`**: Delay before starting the animation
- **`delayEnd`**: Delay after ending the animation

### MapAnimationController Properties

The `MapAnimationController` is the main controller for managing polyline and marker animations. Here are its key properties and methods:

#### Constructor Parameters

- **`mapId`**: Unique identifier for the map (required)
- **`vsync`**: TickerProvider for animation synchronization (required)
- **`markers`**: Initial set of markers (optional, default: empty set)
- **`polylines`**: Initial set of animated polylines (optional, default: empty set)
- **`markersAnimationDuration`**: Duration for marker transitions (default: 2000ms)
- **`markerListener`**: Callback for marker updates (optional)
- **`autoRotateMarkers`**: Enable/disable automatic marker rotation based on movement direction (default: `true`)

### Marker Rotation Control

By default, markers automatically rotate to face the direction of movement during animation. You can disable this behavior and control rotation manually:

```dart
mapAnimationController = MapAnimationController(
  mapId: controller.mapId,
  vsync: this,
  autoRotateMarkers: false, // Disable automatic rotation
);

// Now you can control marker rotation manually
final marker = Marker(
  markerId: MarkerId('marker_1'),
  position: LatLng(23.0181, 72.5897),
  rotation: 45.0, // Custom rotation in degrees
);
```

When `autoRotateMarkers` is set to `false`:
- Markers will maintain their specified rotation value
- You have full control over marker rotation
- Useful for icons that shouldn't rotate or have custom rotation logic

### Available Animators

| Animator | Description | Use Case |
|----------|-------------|----------|
| `SnackAnimator` | Progressive drawing and erasing | Route tracing, snake-like effects |
| `FadeInProgressiveAnimator` | Opacity fade + progressive drawing | Smooth route appearance |
| `ColorTransitionAnimation` | Color transitions between multiple colors | Dynamic route highlighting |



## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Made with ❤️ by [Manish Relani](www.linkedin.com/in/manish-relani) for the Flutter community

If this library helped you, please give it a ⭐ on [GitHub](https://github.com/manishrelani/google_map_animation) 

<img src="https://visitor-badge.laobi.icu/badge?page_id=manishrelani.google_map_animation" style="display: none;" alt="Visitor Count" />