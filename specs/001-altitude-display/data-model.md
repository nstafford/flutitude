# Data Model: Altitude Display

No persistence; these are in-memory values only.

## AltitudeReading
| Field | Type | Notes |
|-------|------|-------|
| meters | double | Raw altitude from the device; may be negative |
| accuracyMeters | double? | Vertical accuracy if reported |
| timestamp | DateTime | Time of the fix |

Derived: `feet = meters * 3.28084`; displayed as a rounded integer with "ft". Accuracy is also shown
in whole feet. `reducedAccuracy = accuracyMeters != null && accuracyMeters * 3.28084 > 50` (flag on
an available reading; the altitude is still shown).

## LocationStatus (sealed set of states)
| State | Meaning | Screen shows |
|-------|---------|--------------|
| waiting | Permission OK, no valid altitude yet or none for 30 s | "Waiting for GPS…" with progress indicator |
| available(reading) | Fresh altitude (with reducedAccuracy flag when applicable) | Altitude in feet, "± N ft", low-accuracy indicator if flagged |
| altitudeUnavailable | Position without a usable altitude | "Altitude unavailable" |
| permissionDenied(permanent) | User denied; `permanent` true if denied forever | Explanation; "Open Settings" button when permanent |
| servicesDisabled | Location services off | Prompt to enable them |

## Transitions
`waiting → available` on first valid altitude; `available → altitudeUnavailable` immediately when a
position lacks a valid altitude; `available → waiting` after 30 s with no position carrying a valid
altitude; any failure state → `waiting`/`available` automatically once the cause is resolved; any
state → `permissionDenied | servicesDisabled` when access changes (re-checked on app resume). Only
the latest status is shown. A reading is never shown once it is no longer current (spec FR-009).

## Validation
- Altitude is treated as unavailable if the value is not finite.
- Negative altitudes are valid.
