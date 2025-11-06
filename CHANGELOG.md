# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2025-11-06

### Added
- Added `pause()` method to stop animations when navigating away from map screen
- Added `resume()` method to restart animations when returning to map screen
- Added `setMarkersImmediate()` method for immediate position updates without animation
- Added lifecycle awareness using `WidgetsBindingObserver`
- Added automatic queue management with max size limit (3 items)
- Added marker caching to reduce object allocation
- Added frame throttling (updates every 2nd frame) to reduce flickering

### Fixed
- **CRITICAL**: Fixed buffer overflow error (`ImageReader_JNI: Unable to acquire a buffer item`) when navigating away from map
- **CRITICAL**: Fixed marker duplication bug when calling `resume()` or returning from background
- Fixed animation catch-up issue when returning to screen after being away
- Fixed marker flickering, especially with custom marker icons
- Fixed excessive platform channel calls through debouncing
- Fixed memory leaks with proper disposal handling

### Changed
- Improved performance by 50% reduction in platform calls
- Improved animation smoothness with consistent 30 FPS
- Enhanced queue management to prevent excessive catch-up animations
- Position changes are now detected to skip unnecessary animations

### Important
- **YOU MUST** call `pause()` before navigating away and `resume()` when returning to prevent buffer overflow
- See `example/lib/lifecycle_example.dart` for proper implementation patterns
- See README.md for best practices and common issues

## [0.1.0] - 2025-11-06

### Added
- Added `autoRotateMarkers` parameter to `MapAnimationController` to control automatic marker rotation
- Markers can now maintain their own rotation values when `autoRotateMarkers` is set to `false`
- Better control over marker rotation behavior during animation
- Added `clearMarkers()` method to remove all markers from the map at once

### Changed
- Updated `google_maps_flutter_platform_interface` to `^2.14.0` (from `^2.12.1`)
- Updated `flutter_lints` to `^6.0.0` (from `^5.0.0`)
- Improved marker animation system to support custom rotation handling

### Fixed
- Fixed duplicate marker issue when markers are set on both GoogleMap widget and MapAnimationController
- Added clear documentation warning users not to set markers in both places
- Improved initialization comments to clarify proper marker management

### Breaking Changes
- None. The default behavior remains the same (`autoRotateMarkers: true`)

## [0.0.1] - 2025-07-07

### Added
- Initial release of Google Map Animation library
- Support for animated polylines on Google Maps
- Support for animated markers on Google Maps
- Smooth transitions and customizable animation effects




