# Feature Specification: Altitude Display

**Feature Branch**: `001-altitude-display`

**Created**: 2026-10-27

**Status**: Draft

**Input**: User description: "The app will have a splash screen displaying an image and will then go to a single main screen that will display altitude in feet. The app will get the data from the phone GPS."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See current altitude in feet (Priority: P1)

A user opens the app, sees a splash screen with an image, and is then taken to a single main screen
that shows their current altitude above sea level in feet, based on the phone's GPS.

**Why this priority**: This is the whole purpose of the app; it delivers value on its own.

**Independent Test**: Launch the app on a phone with location permission granted and a GPS fix;
confirm the main screen shows a numeric altitude labeled in feet that matches a known reference.

**Acceptance Scenarios**:

1. **Given** the app is installed and location permission is granted, **When** the user opens the
   app, **Then** the splash screen appears, then the main screen appears showing altitude in feet.
2. **Given** the main screen is showing altitude, **When** the user moves to a different elevation,
   **Then** the displayed altitude updates to reflect the new value without restarting the app.
3. **Given** the phone reports altitude in meters, **When** it is displayed, **Then** it is
   converted and shown in feet, labeled "ft".

---

### User Story 2 - Splash screen on launch (Priority: P2)

On every launch, the user sees a branded splash screen displaying an image before the main screen.

**Why this priority**: It is part of the requested experience but does not affect the core function.

**Independent Test**: Launch the app and confirm an image is shown, then the main screen appears
automatically with no user action.

**Acceptance Scenarios**:

1. **Given** the app is launched, **When** it starts, **Then** the splash image is displayed
   immediately.
2. **Given** the splash is showing, **When** the splash duration ends, **Then** the app moves to the
   main screen automatically.

---

### User Story 3 - Understand location problems (Priority: P3)

If the app cannot get altitude, the user sees a clear message explaining why and what to do.

**Why this priority**: Makes the app trustworthy when GPS is unavailable.

**Independent Test**: Deny location permission or turn off location services and confirm a clear
message appears instead of a number.

**Acceptance Scenarios**:

1. **Given** location permission is denied, **When** the main screen loads, **Then** a message
   explains that permission is required and how to grant it.
2. **Given** location services are turned off, **When** the main screen loads, **Then** a message
   tells the user to enable location services.
3. **Given** permission is granted but no GPS fix exists yet, **When** the main screen loads,
   **Then** a "waiting for GPS" state is shown rather than a number.

---

### Edge Cases

- The user is indoors or has a weak GPS signal: no stale or invented value is shown; a waiting or
  unavailable state is shown instead.
- Permission is granted with approximate (reduced accuracy) location only: the app informs the user
  that altitude may be inaccurate or unavailable.
- The device reports no altitude value even with a position fix: show an "altitude unavailable"
  message.
- Altitude is negative (below sea level): the negative value is displayed correctly.
- The app is backgrounded and resumed: the display refreshes to current data.
- Location permission is requested for the first time: the splash screen is not blocked by the
  permission prompt.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST show a splash screen with an image on every launch.
- **FR-002**: The app MUST automatically proceed from the splash screen to the main screen with no
  user action.
- **FR-003**: The app MUST have a single main screen that displays the current altitude.
- **FR-004**: The altitude MUST be obtained from the phone's GPS/location service.
- **FR-005**: The altitude MUST be displayed in feet, with the unit labeled.
- **FR-006**: The displayed altitude MUST update as the device's altitude changes while the screen
  is open.
- **FR-007**: The app MUST request location permission (while-in-use only) with a clear
  explanation of why it is needed.
- **FR-008**: The app MUST show distinct, understandable messages for: permission denied, location
  services disabled, waiting for GPS fix, and altitude unavailable.
- **FR-009**: The app MUST NOT display stale or fabricated altitude values as if they were live.
- **FR-010**: The app MUST NOT store or transmit location data.

### Key Entities

- **Altitude Reading**: the device's current height above sea level, with its measurement time and,
  when available, its accuracy; shown to the user in feet.
- **Location Status**: the current condition of location access (permission granted/denied,
  services on/off, fix acquired/waiting) that determines what the main screen shows.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: From tapping the app icon, a user sees an altitude value (with a GPS fix available)
  within 10 seconds.
- **SC-002**: The splash screen is visible for no longer than 3 seconds before the main screen
  appears.
- **SC-003**: Displayed altitude is within the accuracy reported by the phone's GPS when compared
  against a known-elevation reference point, in at least 90% of test readings outdoors.
- **SC-004**: 100% of the failure states (permission denied, services off, no fix, unavailable)
  show a message instead of a number or blank screen.
- **SC-005**: A first-time user can read their altitude without any instructions or additional
  taps beyond granting permission.

## Assumptions

- The initial release targets iPhones; the app is for personal use by a single user.
- Altitude means height above sea level as reported by the phone's location service, not
  barometric-corrected or terrain-database values.
- The splash image is supplied by the project owner; its content and design are out of scope here.
- The splash screen shows for a short fixed time (about 2 seconds).
- Only feet are supported; a meters toggle, history, maps, and settings are out of scope.
- Only foreground use is supported; no background tracking.
- The phone has GPS hardware; no internet connection is required.
