# Non-Enforced Signals (NES)

## Purpose
Capture human workflow provenance without enforcing rules or blocking ingestion.

## Design Principles
- Recorded, not validated
- Informational only
- No downstream logic dependency
- May be null or incomplete

## Current Signals

### Match Report Level
- ReportingCaptainApproved (boolean, optional)
- OpposingCaptainApproved (boolean, optional)
- ReportCreatedBySecretary (boolean)
- CorrectionApplied (boolean)
- CorrectionReviewedByCaptains (boolean, optional)

### Master Level
- CorrectionSource (enum: Captain | Secretary)
- CorrectionReason (text, optional)
- CorrectionTimestamp (datetime)

## Notes
- Presence of these fields does not affect scoring, handicaps, or standings.
- Enforcement, if ever introduced, must be explicit and opt-in.
