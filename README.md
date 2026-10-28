# Flutitude

A Flutter iOS app that shows your current GPS altitude in feet. A splash image appears first, then a single altitude screen.

## Workflow

- **Windows (VS Code):** write code, run `flutter analyze` and `flutter test`, commit and push.
- **MacInCloud (Xcode):** `git clone`/`git pull`, then `flutter pub get`, `cd ios && pod install`, set signing and bundle ID in `ios/Runner.xcworkspace`, and run on the simulator and a physical iPhone. Commit `Podfile.lock` from the Mac.

Full steps: [specs/001-altitude-display/quickstart.md](specs/001-altitude-display/quickstart.md).

Location data is never stored, logged, or sent anywhere.
