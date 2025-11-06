# Changelog

All notable changes to this project will be documented in this file.

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




