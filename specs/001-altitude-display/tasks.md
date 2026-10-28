---

description: "Task list for Altitude Display"
---

# Tasks: Altitude Display

**Input**: Design documents from `/specs/001-altitude-display/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/altitude-service.md, quickstart.md

**Tests**: Included. Constitution principle V requires unit tests for state handling and unit formatting, and widget tests for each UI state.

**Environment tags**: `[WIN]` = Windows / VS Code. `[MAC]` = MacInCloud / Xcode. Do everything possible on Windows; git push/pull is the only hand-off.

**Format**: `- [ ] T### [P?] [Story?] [ENV] Description with file path`

## Phase 1: Setup (Shared Infrastructure)

- [X] T001 [WIN] Install the Flutter SDK (stable) on Windows, add it to PATH, and run `flutter doctor`; Android/iOS toolchain warnings are acceptable
- [X] T002 [WIN] Scaffold the app at the repo root with `flutter create --platforms=ios --project-name flutitude .` (generates `pubspec.yaml`, `lib/`, `test/`, `ios/`); ensure `.gitignore` still ignores generated files
- [X] T003 [WIN] Add the `geolocator` dependency in `pubspec.yaml`, declare the `assets/splash.png` asset, and run `flutter pub get`
- [X] T004 [P] [WIN] Verify `analysis_options.yaml` includes `flutter_lints`
- [X] T005 [P] [WIN] Add a placeholder image at `assets/splash.png` (replace later with the owner-supplied image)
- [X] T006 [P] [WIN] In `ios/Runner/Info.plist` add `NSLocationWhenInUseUsageDescription` with a clear explanation, and restrict `UISupportedInterfaceOrientations` (iPhone) to portrait only; `NSLocationWhenInUseUsageDescription` is the only location key needed (no always/temporary-full-accuracy keys) (FR-007, FR-012)
- [X] T007 [WIN] Remove the generated counter demo from `lib/main.dart` and `test/widget_test.dart` so they can be replaced

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared types, unit conversion, and the service interface used by every story.

- [X] T008 [P] [WIN] Create `lib/units.dart` with meters-to-feet conversion (1 m = 3.28084 ft) and a formatter that rounds to whole feet with thousands separators and an "ft" label; negative values valid
- [X] T009 [P] [WIN] Create `lib/altitude_service.dart` with `AltitudeReading` (meters: double, accuracyMeters: double?, timestamp: DateTime), a sealed `LocationStatus` with states waiting, available(reading), altitudeUnavailable, permissionDenied(permanent: bool), servicesDisabled, where `AltitudeReading` exposes `reducedAccuracy` (accuracy worse than 50 ft); non-finite altitude is treated as unavailable
- [X] T010 [P] [WIN] Create a fake service in `test/fakes/fake_altitude_service.dart` that emits a controllable stream of `LocationStatus`
- [X] T011 [P] [WIN] Write unit tests in `test/units_test.dart`: conversion accuracy, rounding, thousands separators, negative altitude, zero

**Checkpoint**: Foundation ready; user stories can begin.

---

## Phase 3: User Story 1 - See current altitude in feet (Priority: P1) 🎯 MVP

**Goal**: Main screen shows live GPS altitude in feet with an optional "± N ft" accuracy line.

**Independent Test**: Run with the fake service in widget tests; on a device, the screen shows altitude in feet that updates as elevation changes.

### Tests for User Story 1

- [X] T012 [P] [US1] [WIN] Widget test in `test/altitude_screen_test.dart`: an available reading shows the whole-feet value with "ft"; accuracy shown as "± N ft" only when reported; a later reading updates the display (FR-005, FR-006, FR-011)

### Implementation for User Story 1

- [X] T013 [US1] [WIN] Implement `lib/altitude_screen.dart`: takes an `AltitudeService`, renders a `StreamBuilder<LocationStatus>`, and shows a large altitude with "ft" label plus accuracy line for the available state; starts the service stream in `initState` so the permission prompt appears over the main screen when it first loads (after the splash, FR-007), and disposes it in `dispose`
- [X] T014 [US1] [WIN] Implement `lib/geolocator_altitude_service.dart`: the only file importing `geolocator`; checks services and permission (requests while-in-use permission if undecided; the iOS prompt offers Precise Location on by default, and the app does not request temporary full accuracy), streams `Geolocator.getPositionStream`, maps positions to `LocationStatus.available` with `altitude` and `altitudeAccuracy`, and emits `waiting` until the first fix; no logging or storage of location values (FR-004, FR-010)
- [X] T015 [US1] [WIN] Update `lib/main.dart` to lock portrait (`SystemChrome.setPreferredOrientations`), create one `GeolocatorAltitudeService`, and show `AltitudeScreen` as home (temporary; replaced by the splash in T019)
- [ ] T016 [US1] [WIN] Run `flutter analyze` and `flutter test`; fix issues; commit and push

**Checkpoint**: User Story 1 works in tests; device validation happens in Phase 6.

---

## Phase 4: User Story 2 - Splash screen on launch (Priority: P2)

**Goal**: A splash image is shown for about 2 seconds, then the main screen appears automatically.

**Independent Test**: Widget test pumps the splash, sees the image, advances 2 seconds, and finds the altitude screen.

### Tests for User Story 2

- [X] T017 [P] [US2] [WIN] Widget test in `test/splash_screen_test.dart`: the splash shows the image immediately and replaces itself with the main screen after 2 seconds with no input (FR-001, FR-002)

### Implementation for User Story 2

- [X] T018 [US2] [WIN] Implement `lib/splash_screen.dart`: shows `assets/splash.png` centered, starts a 2-second timer, then `pushReplacement` to the altitude screen; cancels the timer on dispose; does not wait on the permission prompt
- [X] T019 [US2] [WIN] Change `lib/main.dart` home from `AltitudeScreen` to `SplashScreen`, passing the same service instance so the splash navigates to `AltitudeScreen(service: service)`
- [ ] T020 [US2] [WIN] Run `flutter analyze` and `flutter test`; commit and push

**Checkpoint**: Splash then main screen flow works in tests.

---

## Phase 5: User Story 3 - Understand location problems (Priority: P3)

**Goal**: Each failure state shows a clear message instead of a number.

**Independent Test**: Emit each non-available status from the fake service and confirm the matching message appears and no altitude number is shown.

### Tests for User Story 3

- [X] T021 [P] [US3] [WIN] Widget tests in `test/altitude_failure_states_test.dart`: one test per state (waiting, altitudeUnavailable, permissionDenied with and without the Open Settings button, servicesDisabled) asserting its message text and that no altitude value is displayed; a test that a reducedAccuracy reading still shows the altitude with the low-accuracy indicator; and a lifecycle test that resuming the app re-subscribes the service and recovers from a failure state (FR-008, FR-009, FR-013, FR-015, SC-004)
- [X] T022 [P] [US3] [WIN] Unit tests in `test/geolocator_state_test.dart` (or on a pure mapping function): no valid-altitude update for 30 seconds switches `available` to `waiting`; a position with non-finite altitude maps to `altitudeUnavailable` immediately; accuracy over 50 ft sets reducedAccuracy (FR-009, FR-013)

### Implementation for User Story 3

- [X] T023 [US3] [WIN] Extend `lib/altitude_screen.dart` to render distinct messages and a progress indicator for waiting, altitudeUnavailable, permissionDenied (explain; show an "Open Settings" button that calls the geolocator open-app-settings function when permanently denied), and servicesDisabled (ask to turn on Location Services); show a low-accuracy indicator on an available reading when flagged
- [X] T024 [US3] [WIN] Extend `lib/geolocator_altitude_service.dart`: emit `servicesDisabled`, `permissionDenied` (`permanent: true` when `Geolocator.checkPermission()` returns `LocationPermission.deniedForever`), and `altitudeUnavailable`; compute `reducedAccuracy` on readings (accuracy over 50 ft); add a 30-second staleness timer that resets only on a position with a valid altitude and emits `waiting` when it fires (FR-009, FR-013); request precise permission at launch (FR-007)
- [X] T025 [US3] [WIN] Re-check permission and services when the app returns to the foreground (`WidgetsBindingObserver` in `lib/altitude_screen.dart` re-subscribes the service)
- [ ] T026 [US3] [WIN] Run `flutter analyze` and `flutter test`; commit and push

**Checkpoint**: All three stories work in tests on Windows.

---

## Phase 6: Mac Build & Device Validation

**Purpose**: Steps only possible on macOS. Keep this session short.

- [ ] T027 [MAC] Install or confirm Flutter SDK, Xcode, and CocoaPods on MacInCloud; `git clone` the repo and `cd flutitude`
- [ ] T028 [MAC] Run `flutter pub get` then `cd ios && pod install`
- [ ] T029 [MAC] Open `ios/Runner.xcworkspace` in Xcode; set the signing Team and a unique bundle identifier; confirm deployment target is iOS 13+ and orientation is portrait only
- [ ] T030 [MAC] Run on the iOS Simulator with `flutter run`; use Features > Location to simulate a position; confirm splash, then main screen, and permission prompt text
- [ ] T031 [MAC] Run on a physical iPhone; confirm the permission prompt, altitude in feet updating outdoors, and the "± N ft" line
- [ ] T032 [MAC] On the iPhone, exercise failure states: deny permission (including permanently, then use Open Settings), turn Location Services off, and go indoors; confirm each shows its message and no stale number (SC-004, FR-009)
- [ ] T033 [MAC] Compare displayed altitude to a known-elevation reference outdoors (SC-003)
- [ ] T034 [MAC] Commit and push `Podfile.lock` and any Xcode project changes (not `Pods/`), then `git pull` on Windows

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T035 [WIN] Replace the placeholder `assets/splash.png` with the owner-supplied image and re-run `flutter test`
- [X] T036 [P] [WIN] Add a short `README.md` documenting the Windows develop and MacInCloud build workflow, linking to `specs/001-altitude-display/quickstart.md`
- [X] T037 [P] [WIN] Review `lib/` against constitution principles I to V (no extra features, no location logging: grep `lib/` for `print`/`debugPrint` of position values (FR-016), only `geolocator_altitude_service.dart` imports `geolocator`)
- [ ] T038 [WIN] Final `flutter analyze` and `flutter test`; commit and push

---

## Dependencies & Execution Order

- Phase 1 then Phase 2, which blocks all stories.
- US1 (Phase 3) is the MVP. US2 (Phase 4) depends only on Phase 2 plus `AltitudeScreen` from T013 for navigation. US3 (Phase 5) extends US1 files (`altitude_screen.dart`, `geolocator_altitude_service.dart`), so it follows US1.
- Phase 6 (Mac) requires all Windows work pushed (at least through US1) and can begin after Phase 3 for an early device check, then repeat for T032 after Phase 5.
- Phase 7 follows Phase 6.
- Within a story: tests first (confirm they fail), then implementation.

## Parallel Opportunities

- Phase 1: T004, T005, T006.
- Phase 2: T008, T009, T010, T011 (different files).
- Tests T012, T017, T021, T022 can be written in parallel with each other; T017 can run alongside US1 implementation.

## Implementation Strategy

- **MVP**: Phases 1 to 3, then a first Mac pass (T027 to T031) to see real altitude on a phone.
- **Incremental**: add the splash (US2), then failure states (US3), then the full device validation (T032, T033), then polish.
- Note: checklist `checklists/location-states.md` has open requirement questions (for example, definition of "update" for the 30-second rule); resolve or accept them before Phase 5.
