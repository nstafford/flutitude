<!--
Sync Impact Report
Version change: (unratified template) → 1.0.0
Modified principles: all placeholders replaced (initial adoption)
Added sections: Core Principles I–V, Platform & Technical Constraints, Development Workflow, Governance
Removed sections: none
Deferred TODOs: none
Note: .specify/scripts/bash/resolve-template.sh could not run (no bash on Windows host);
the existing on-disk scaffold (stock template) was used as the structure.
-->
# Flutitude Constitution

## Core Principles

### I. Simplicity First
Flutitude reads the phone's current GPS altitude and displays it. Every feature MUST serve that
purpose. Speculative features, extra screens, and abstractions without a present need MUST NOT
be added (YAGNI). Rationale: a single-purpose app stays small, reliable, and easy to verify.

### II. Accurate, Honest Altitude Data
Altitude MUST come from the device location service (GPS/CoreLocation via a Flutter plugin) and
MUST be shown with its unit (meters, with a feet option permitted). The UI MUST show clear states
for: permission not granted, location services disabled, no fix/loading, and error. Stale or
fabricated values MUST NOT be displayed as live data; reported accuracy SHOULD be surfaced when
available. Rationale: users rely on the number, so uncertainty must be visible.

### III. Privacy & Permission Minimalism
The app MUST request only "when in use" location permission, with a clear iOS usage-description
string in Info.plist. Location data MUST NOT be stored, logged to persistent storage, or
transmitted off-device. Rationale: altitude display needs no background or network access.

### IV. iOS-First, Cross-Platform-Safe
iOS is the target platform; the UI MUST follow iOS conventions and behave correctly on iOS
devices, including permission flows and reduced-accuracy location. Platform-specific code MUST be
isolated behind a small interface so the app logic stays platform-neutral. Rationale: iOS is the
release target, but clean boundaries keep the code testable.

### V. Testable Structure
Altitude retrieval MUST sit behind an abstraction so logic and UI can be tested with fakes. Unit
tests MUST cover state handling (permission, loading, value, error) and unit formatting; widget
tests SHOULD cover each UI state. `flutter analyze` and `flutter test` MUST pass before merge.
Rationale: GPS cannot be reproduced on demand in CI, so fakes are required.

## Platform & Technical Constraints

- Framework: Flutter (stable channel) with Dart null safety; dependencies kept minimal and
  limited to maintained packages (e.g., a location plugin).
- Development happens on Windows with VS Code; iOS builds, signing, and device/simulator
  verification require macOS/Xcode (or a cloud macOS CI service). Features MUST NOT be declared
  iOS-verified without running on an iOS simulator or device.
- Simulator GPS is simulated; altitude accuracy MUST be validated on a physical iPhone before
  release.
- Code MUST follow the `flutter_lints` ruleset.

## Development Workflow

- Work follows the Spec Kit flow: specify → plan → tasks → implement.
- Changes SHOULD be small and focused; each change MUST pass analysis and tests locally.
- Pull requests/reviews MUST check compliance with this constitution; any added complexity or
  dependency MUST be justified in the PR.
- Windows-compatible tooling (PowerShell, Flutter CLI) MUST be assumed for developer commands in
  docs and scripts.

## Governance

This constitution supersedes other project practices. Amendments require a documented change to
this file, a version bump, and an update of affected specs/plans where they conflict. Versioning
follows semantic versioning: MAJOR for incompatible principle removals or redefinitions, MINOR
for new or materially expanded principles/sections, PATCH for clarifications. Compliance is
reviewed at each plan (Constitution Check) and each pull request.

**Version**: 1.0.0 | **Ratified**: 2026-10-27 | **Last Amended**: 2026-10-27
