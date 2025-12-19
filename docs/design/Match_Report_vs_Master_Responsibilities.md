# Match Report vs Master Responsibilities
**GL-REFIT Design Alignment Document**

**Version:** v1.0 (Design-locked, pre-implementation)  
**Status:** Approved  
**Last Updated:** 2025-12-XX  

---

## 1. Purpose

This document defines the **clear separation of responsibilities** between:

- The **Match Report workbook** (captain-facing, data entry & validation)
- The **Master workbook** (secretary-facing, authoritative calculation & aggregation)

Its goals are to:

- Preserve captain usability and trust
- Centralize authority and consistency
- Avoid duplicate or conflicting logic
- Explicitly document **what is preserved, what is authoritative, and what is non-enforced**

This document is normative for REFIT design and implementation.

---

## 2. High-Level Architecture Overview

### Legacy (Today)

| Component      | Responsibilities |
|----------------|------------------|
| Match Report   | Data entry, scoring logic, validation |
| Master         | Aggregation, reporting |

### REFIT (Target)

| Component      | Responsibilities |
|----------------|------------------|
| Match Report   | Data entry, validation, *replicated display-only calculations* |
| Master         | **Authoritative handicap & scoring engines**, aggregation, reporting |

> **Key Principle:**  
> The Master is the *only authoritative source* of scoring and handicap results.

---

## 3. Match Report Responsibilities (Captain-Facing)

The Match Report exists to support **accurate, timely data entry** and **immediate human validation** by captains.

### 3.1 Data Entry (Required)

The Match Report is responsible for collecting:

- Player identity
- Team identity
- Position played
- Hole-by-hole gross scores
- Forfeit / no-show indicators
- Match completion indicators
- Blind Draw scenarios (Team / Forfeit)

These values populate:

- `Upload_Indiv_Raw`
- `Upload_Team_Raw`

No derived results from the Match Report are authoritative.

---

### 3.2 Replicated Calculations (Display-Only, Non-Authoritative)

To preserve legacy usability, the Match Report **may include replicated calculation logic** for:

- Match scoring (points per hole, match points, team totals)
- Handicap usage when dependent on the current round

These calculations exist **solely** to:

- Give captains immediate feedback
- Allow error detection while players are still present
- Preserve the familiar workflow

> **Critical Rule:**  
> These calculations are **not authoritative** and are **never ingested** by REFIT engines.

---

### 3.3 Validation (Human-Facing)

The Match Report should surface:

- Missing scores
- Invalid entries
- Logical inconsistencies (e.g., scores vs completion flags)

Validation exists to **inform captains**, not to block processing.

---

## 4. Master Responsibilities (Secretary-Facing)

The Master workbook is the **single source of truth**.

### 4.1 Authoritative Engines

The Master exclusively owns:

- Handicap calculation engine
- Match scoring engine
- Team scoring engine
- Standings and leaderboard logic

All season results are derived **only** from REFIT ingestion tables and engines.

---

### 4.2 Data Ingestion

The Master ingests:

- `Upload_Indiv_Raw`
- `Upload_Team_Raw`

And transforms them through:

- Staging tables
- Results tables
- Summary_New canonical tables

---

### 4.3 Aggregation & Reporting

The Master produces:

- Weekly results
- Season standings
- Leaderboards
- Official historical records

Once processed, results are authoritative.

---

## 5. Approval & Correction Provenance  
*(Preserved, Non-Enforced)*

REFIT preserves legacy **human governance workflows** without enforcing them programmatically.

### 5.1 Captain Review & Approval (Preserved)

Historically:

- One captain submits the Match Report
- The opposing captain reviews and approves
- Corrections are sometimes required before final acceptance

REFIT **does not enforce** this workflow, but **preserves the ability to document it**.

---

### 5.2 Recommended Provenance Fields (Optional)

REFIT may include **non-enforced metadata fields** such as:

- `Captain1Approved` (TRUE/FALSE)
- `Captain2Approved` (TRUE/FALSE)
- `SecretaryEntered` (TRUE/FALSE)
- `CorrectionFlag` (TRUE/FALSE)
- `CorrectionReason` (text)
- `CorrectionDate`

These fields:

- Provide transparency
- Preserve institutional memory
- Support audits and disputes
- Do **not** alter scoring logic

---

### 5.3 Correction Workflow (Preserved)

When corrections occur:

1. Secretary updates the Match Report
2. Updated report is routed to captains
3. Approval is obtained offline and documented by the captains in the updated
   Match Report.
4. Updated Match Report is routed back to the secretary
5. Corrected report replaces the original input
6. REFIT recalculates all downstream results

> REFIT does **not** distinguish corrections algorithmically — it simply recalculates.

---

## 6. Explicit Non-Goals

REFIT intentionally does **not**:

- Enforce captain approvals
- Block processing based on approval status
- Replace human governance
- Require real-time connectivity

These are governance decisions, not system responsibilities.

---

## 7. Future Possibilities (Out of Scope)

Potential future enhancements include:

- Web-based reporting
- Real-time scoring dashboards
- Integrated approval workflows
- Role-based access control

These are **explicitly out of scope** for REFIT v1.x.

---

## 8. Design Principles Reinforced

- One authoritative engine
- Human-centric validation
- Transparency over enforcement
- Stability over automation
- Refactorability over premature optimization

---

## 9. Status

This document is **design-locked** and authoritative for REFIT implementation.

Any deviation requires explicit revision of this document.

---
