# Contract: AltitudeService (UI ↔ location boundary)

The only interface between the screens and the platform location plugin.

```text
abstract AltitudeService
  Stream<LocationStatus> watch()   // emits the current status immediately, then on every change
  void dispose()
```

## Behavior
- `watch()` first checks services and permission, requesting precise while-in-use permission at launch if undecided.
- Emits `servicesDisabled` or `permissionDenied(permanent)` instead of throwing.
- Emits `waiting` until the first valid altitude, then `available(reading)` per update.
- Emits `altitudeUnavailable` immediately when an update has no finite altitude.
- Marks a reading `reducedAccuracy` when vertical accuracy is worse than 50 ft; altitude still shown.
- Re-checks access when the app returns to the foreground and recovers automatically.
- Never caches or replays an old reading as current; emits `waiting` if no valid-altitude update
  arrives for 30 s. Never persists, logs, or sends location values anywhere.
- App is locked to portrait orientation.

## UI contract (main screen)
| Status | Required content |
|--------|------------------|
| available | Altitude as a whole number of feet with "ft" label, plus "± N ft" accuracy line when reported, plus low-accuracy indicator when flagged |
| waiting | "Waiting for GPS…" with progress indicator |
| altitudeUnavailable | "Altitude unavailable" message |
| permissionDenied | Explanation; "Open Settings" button when permanently denied |
| servicesDisabled | Instruction to turn on Location Services |

Splash: shows `assets/splash.png` for ~2 s, then replaces itself with the main screen.
