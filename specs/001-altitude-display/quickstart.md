# Quickstart: Validating Altitude Display

## Windows / VS Code (development)
Prerequisite: install the Flutter SDK and add it to PATH (not yet installed here); run
`flutter doctor`.

1. One-time scaffold (if not done): `flutter create --platforms=ios --project-name flutitude .`
2. `flutter pub get`
3. `flutter analyze` — expect no issues.
4. `flutter test` — expect all unit/widget tests to pass (units, splash, each location state).
5. Commit everything including `ios/` and `pubspec.lock`, then push.

## MacInCloud / Xcode (build and device validation)
Prerequisites: Flutter SDK, Xcode, CocoaPods, an Apple ID for signing, an iPhone.

1. `git clone <repo>` and `cd flutitude`
2. `flutter pub get`, then `cd ios && pod install && cd ..`
3. Open `ios/Runner.xcworkspace` in Xcode; set the signing Team and a unique bundle identifier.
4. Run on the iOS Simulator: `flutter run` (simulated GPS; set a location via Features > Location).
5. Run on a physical iPhone for real GPS validation.
6. Commit any `Podfile.lock` and Xcode project changes back to the repo.

## Expected outcomes (maps to spec)
- Windows can verify: analyze and tests pass. Only the Mac can verify: build, signing, simulator,
  and real-GPS behavior below.
- App stays in portrait; accuracy line "± N ft" appears when reported; no update for 30 s shows
  "Waiting for GPS".
- Splash image shows ~2 s, then the main screen (US2, FR-001/002).
- With permission and a fix, altitude appears in feet within 10 s and updates as you move (US1).
- Deny permission, disable Location Services, and go indoors: each shows its message, never a
  stale number (US3, FR-008/009).
- Outdoors on a device, altitude is within the reported accuracy of a known elevation (SC-003).
