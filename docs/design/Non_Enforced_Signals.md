# Non-Enforced Signals (NES)

**Version:** v1.0
**Status:** LOCKED
**Last updated:** 2026-01-24
**Tag:** v1.0-pre-engine-audit

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

## Version History

v1.0 - 2026-01-24
- Promoted following successful pass of v1.0 Pre-engine audit.
