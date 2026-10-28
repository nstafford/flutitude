# Research: Altitude Display

## Decision 1: Location package
- **Decision**: `geolocator`.
- **Rationale**: Maintained, supports iOS CoreLocation, exposes a position stream, permission
  checks/requests, and location-service status in one package. `Position.altitude` is in meters and
  `Position.altitudeAccuracy` is available, which supports the "accuracy" and "unavailable" states.
- **Alternatives**: `location` (similar, less active); `permission_handler` + a separate location
  plugin (two dependencies, violates simplicity).

## Decision 2: Splash screen
- **Decision**: A Flutter `SplashScreen` widget showing an asset image, auto-navigating after 2 s,
  plus the default iOS launch screen (storyboard) left in place for the instant before Flutter loads.
- **Rationale**: The spec requires a displayed image for a fixed time; a native-only launch screen
  cannot be timed. Keeping the default storyboard avoids extra native tooling.
- **Alternatives**: `flutter_native_splash` (extra dependency and Mac-side regeneration; not needed).

## Decision 3: State management
- **Decision**: Plain `StreamBuilder` over a stream of `LocationStatus` values from the service.
- **Rationale**: One screen, one data source; no package needed.
- **Alternatives**: Provider/Riverpod/Bloc (over-engineered here).

## Decision 4: Units
- **Decision**: Convert meters to feet with 1 m = 3.28084 ft; display rounded to whole feet with
  thousands separators and an "ft" label.
- **Rationale**: Matches the spec; whole feet is appropriate for phone GPS accuracy.

## Decision 5: iOS permission and accuracy
- **Decision**: Request when-in-use permission; add `NSLocationWhenInUseUsageDescription` in
  `Info.plist`. Reduced accuracy is defined by reported vertical accuracy worse than ±50 ft (spec FR-013), shown as a flag.
- **Rationale**: Constitution III; spec edge case for approximate location.

## Decision 6: Windows development / Mac build workflow
- **Decision**: Develop and run unit/widget tests on Windows. Generate the `ios/` folder on Windows
  with `flutter create --platforms=ios .` and commit it. On MacInCloud: clone, run
  `flutter pub get`, `cd ios && pod install`, then build/run from Xcode or `flutter run`.
- **Rationale**: Flutter can scaffold the iOS folder on Windows; only CocoaPods, signing, and
  device builds require macOS. `Pods/`, `Podfile.lock` handling: `Pods/` is ignored; `Podfile.lock`
  is committed once generated on the Mac for reproducible builds.
- **Notes**: Flutter is not currently installed on this Windows machine (`flutter` not found);
  installing the Flutter SDK is a prerequisite. Windows has no iOS simulator, so on-device
  validation of real GPS altitude happens on a physical iPhone via the Mac.
