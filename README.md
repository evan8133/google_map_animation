# Google Map Animation

A Flutter library for creating smooth, customizable polyline and marker animations directly on Google Maps. 
Bring your maps to life with beautiful animations that enhance user experience.


[![Pub Version](https://img.shields.io/pub/v/google_map_animation)](https://pub.dev/packages/google_map_animation)
[![Flutter](https://img.shields.io/badge/Flutter->=3.24.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart->=3.8.1-blue.svg)](https://dart.dev/)


## ⚠️ Important Notes

### Google Maps Setup
This library focuses **exclusively** on animating polylines and markers on Google Maps. Google Maps configuration and setup is **out of scope** for this library. Before using this library, please ensure you have properly configured Google Maps in your Flutter project.

For Google Maps setup instructions, refer to the [official Google Maps Flutter documentation](https://pub.dev/packages/google_maps_flutter).

### 🚨 Critical: Lifecycle Management (Prevent Buffer Overflow)

**You MUST call `pause()` when navigating away from the map screen and `resume()` when returning!**

Without this, you'll get errors like:
```
W/ImageReader_JNI: Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
```

**Why this happens:** The animation continues running even when the map widget is not visible, causing Android's ImageReader to overflow its buffer.

**Solution - Choose one:**

**Option 1: Manual Control (Simple)**
```dart
// Before navigating away
mapAnimationController?.pause();

// When returning
mapAnimationController?.resume();
```

**Option 2: Automatic with Provider**
```dart
class MapProvider extends ChangeNotifier {
  void onNavigateAway() {
    mapAnimationController?.pause();
  }
  
  void onReturn() {
    mapAnimationController?.resume();
  }
}
```

**Option 3: RouteAware (Most Robust)**
See `example/lib/lifecycle_example.dart` for complete implementation.

**In Provider pattern:** Call `pause()` in your provider when the map screen is not active, and `resume()` when it becomes active again.


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



## Best Practices

### Performance Tips

1. **Update Frequency**: Don't update markers too frequently
   ```dart
   // ✅ Good: 1-2 seconds
   Timer.periodic(Duration(seconds: 2), (_) { ... });
   
   // ❌ Bad: Too frequent
   Timer.periodic(Duration(milliseconds: 100), (_) { ... });
   ```

2. **Custom Markers**: Pre-create and reuse `BitmapDescriptor` icons
   ```dart
   // ✅ Good: Create once, reuse
   final icon = await BitmapDescriptor.fromAssetImage(...);
   
   // ❌ Bad: Creating every time
   marker.copyWith(icon: await BitmapDescriptor.fromAssetImage(...));
   ```

3. **Marker Count**: Limit animated markers to 50-100 for best performance

4. **Animation Duration**: Match duration to update frequency
   ```dart
   // If updating every 2 seconds, use ~1500ms animation
   markersAnimationDuration: Duration(milliseconds: 1500)
   ```

### Common Issues and Solutions

#### Issue: "Unable to acquire a buffer item" Error
**Solution:** Always call `pause()` when navigating away and `resume()` when returning. See lifecycle example.

#### Issue: Markers flickering
**Solution:** 
- Reduce update frequency
- Pre-create custom marker icons
- Use appropriate animation duration

#### Issue: Markers "catch up" after returning to screen
**Solution:** This is now handled automatically with `resume()`, which clears queued animations.

#### Issue: Using with Provider/Bloc
**Solution:** Call `pause()` when provider indicates map is not visible, `resume()` when visible:
```dart
class MapProvider extends ChangeNotifier {
  bool _isMapVisible = true;
  
  set isMapVisible(bool value) {
    _isMapVisible = value;
    if (value) {
      mapAnimationController?.resume();
    } else {
      mapAnimationController?.pause();
    }
  }
}
```

## Examples

See the `example` folder for complete implementations:
- `main.dart` - Basic usage
- `lifecycle_example.dart` - Proper lifecycle management with pause/resume
- `manual_rotation_example.dart` - Custom marker rotation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Made with ❤️ by [Manish Relani](www.linkedin.com/in/manish-relani) for the Flutter community

If this library helped you, please give it a ⭐ on [GitHub](https://github.com/manishrelani/google_map_animation) 

<img src="https://visitor-badge.laobi.icu/badge?page_id=manishrelani.google_map_animation" style="display: none;" alt="Visitor Count" />