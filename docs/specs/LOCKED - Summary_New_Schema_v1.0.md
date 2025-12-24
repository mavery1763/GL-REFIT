# Summary_New — Canonical Schema

**Version:** v1.0  
**Status:** 🔒 LOCKED  
**Layer:** Summary_New  
**Scope:** Regular season only (playoffs explicitly out of scope)

---

## Purpose

Defines the canonical schema for the `Summary_New` layer.

This layer represents a **human-readable, engine-ready snapshot of league state** as of the most recently processed match data. It is the sole input layer for scoring, handicap, and reporting engines.

---

## Intended Audience

- REFIT project maintainer (league secretary / technical lead)
- Future contributors to REFIT
- Debugging, validation, and audit reference

---

## When to Read This Document

Read this document when:

- Wiring or modifying any `Summary_New__*` query
- Building engines that consume league state
- Validating schema compliance
- Debugging incorrect downstream outputs

---

## Design Rules (LOCKED)

The following rules apply to **all** `Summary_New` tables:

- Summary_New represents a **snapshot of league state** as of the latest successfully processed data.
- Summary_New tables **MUST NOT**:
  - perform business calculations
  - perform inference or decision logic
  - access files or folders
- Engines **MUST consume Summary_New**, not ingestion or staging layers.
- Schema stability takes precedence over early optimization.
- All tables must exactly match this schema before engine development proceeds.

---

## As-Of Semantics (LOCKED)

Only one table explicitly declares the snapshot moment.

- `Summary_New__Season` **MUST** include:
  - `AsOfMatchWeek`
  - `AsOfMatchDate`
- All other Summary_New tables:
  - implicitly represent state *as of* that snapshot
  - **MUST NOT** duplicate As-Of fields
- Per-match and per-week tables encode time intrinsically via:
  - `MatchWeek`
  - `MatchDate`

---

## Schema Overview

| Table | Purpose | Grain |
|------|--------|------|
| Summary_New__Season | Season-level context and parameters | 1 row per season |
| Summary_New__Teams | Team identity and competitive position | 1 row per team |
| Summary_New__Players | Current player roster state | 1 row per player |
| Summary_New__Handicaps | Current handicap status | 1 row per player |
| Summary_New__Matches | Match participation facts | 1 row per player per match |
| Summary_New__Player_Stats | Season-to-date player totals | 1 row per player |
| Summary_New__Weekly_Stats | Weekly player results | 1 row per player per week |

---

## Section A — Season Metadata

### Query: `Summary_New__Season`

**Grain:** 1 row per season

Defines global season context and eligibility parameters.

| Column | Type | Source | Notes |
|------|-----|------|--------|
| SeasonYear | number | pull from Static_Season_Config | e.g., 2025 |
| LeagueName | text | pull from Static_Season_Config | Human-readable |
| SeasonStatus | text | pull from Static_Season_Config | Planned \| Active \| Complete |
| AsOfMatchWeek | number | derive from Summary_New__Matches | Latest processed week |
| AsOfMatchDate | date | derive from Summary_New__Matches | Date of latest processed match |
| SeasonRoundsPlanned | number | pull from Static_Season_Config | May change mid-season |
| Eligibility_MinPctRounds | number | pull from Static_Season_Config | e.g., 0.5 |

---

## Section B — Team State

### Query: `Summary_New__Teams`

**Grain:** 1 row per team

Season-to-date team identity and competitive position.

| Column | Type | Source | Notes |
|------|-----|--------|--------|
| SeasonYear | number | pull from Static_Season_Config | e.g., 2025 |
| Team | text | pull from Team_Results_Staging | |
| TeamKey | text | derive from Team | |
| Captain | text | pull from Team_Master | Future |
| TeamPoints | number | aggregate from Team_Results_Staging | |
| TeamWins | number | aggregate from Team_Results_Staging | |
| TeamLosses | number | aggregate from Team_Results_Staging | |
| TeamTies | number |  aggregate from Team_Results_Staging | |
| LowTeamNet | number | derive from Team_Results_Staging | |
| HighTeamPoints | number | derive from Team_Results_Staging | |
| CurrentlyInPlayoffs | logical | derive from Team_Results_Staging | TRUE = top 4 teams (points and tiebreakers) |

---

## Section C — Player Roster State

### Query: `Summary_New__Players`

**Grain:** 1 row per player

Answers the question: **“Who is this player right now?”**

| Column | Type | Source | Notes |
|------|-----|--------|--------|
| SeasonYear | number | pull from Static_Season_Config | e.g., 2025 |
| Player | text | pull from Indiv_Results_Staging | |
| PlayerKey | text | derived from Player | |
| Team | text | pull from Indiv_Results_Staging |  |
| ActiveStatus | text | pull from Player_Master | Future |
| IsCaptain | logical | pull from Player_Master | Future |
| Tee | text | pull from Player_Master | Future |
| RosterStartDate | date | pull from Player_Master | Future |
| RosterEndDate | date | pull from Player_Master | Future |
| PlayerPhone | text | pull from Player_Master | Future |
| PlayerEmail | text | pull from Player_Master | Future |

**Interpretation:**  
“Right now” means *as of the snapshot defined in `Summary_New__Season`*.

---

## Section D — Handicap State

### Query: `Summary_New__Handicaps`

**Grain:** 1 row per player

Represents **current handicap status only**.

| Column | Type | Source | Notes |
|------|-----|--------|--------|
| SeasonYear | number | pull from Static_Season_Config | e.g., 2025 | 
| Player | text | pull from Player_Master | Future; all active players|
| PlayerKey | text | text | derived from Player | |
| EstablishedHcp | logical | pull from Handicap engine | Future |
| Handicap | number | pull from Handicap engine | Future |
| HandicapCalcBasis | text | pull from Handicap engine | Future |
| HandicapRounds | number | pull from Handicap engine | Future |
| SeasonRoundsPlayed | number | aggregate from Indiv_Results_Staging |  |

**Note:**  
Historical handicap timelines belong in Analytics, not Summary_New.

---

## Section E — Match Participation

### Query: `Summary_New__Matches`

**Grain:** 1 row per player per match

Match-level participation facts.

| Column | Type | Source | Notes |
|------|-----|--------|--------|
| SeasonYear | number | pull from Static_Season_Config | e.g., 2025 |
| MatchWeek | number | pull from Indiv_Results_Staging | |
| MatchDate | date | pull from Indiv_Results_Staging | |
| Team | text | pull from Indiv_Results_Staging | |
| Opponent | text | pull from Indiv_Results_Staging | |
| Player | text | pull from Indiv_Results_Staging | |
| PlayerKey | text | derived from Player | |
| PositionPlayed | number | pull from Indiv_Results_Staging | |
| Side | text | pull from Indiv_Results_Staging | |
| Course | text | pull from Indiv_Results_Staging | |
| MatchCompletedInd | logical | derive from Indiv_Results_Holes | |
| ForfeitFlag | logical | derive from Indiv_Results_Holes | |
| BlindDrawType | text | derive from Indiv_Results_Staging | |
| ReportingCaptainApproved | logical | pull from *Somewhere* | Future |
| OpposingCaptainApproved | logical | pull from *Somewhere* | Future |
| IsCorrection | logical | pull from *Somewhere* | Future |
| CorrectionReason | text | pull from *Somewhere* | Future |
| CorrectionEnteredBy | text | pull from *Somewhere* | Future |
| CorrectionDate | date | pull from *Somewhere* | Future |
| CaptainReapproved | logical | pull from *Somewhere* | Future
| ApprovalStatus | text | pull from *Somewhere* | Future |

---

## Section F — Player Season Totals

### Query: `Summary_New__Player_Stats`

**Grain:** 1 row per player

Season-to-date leaderboard metrics.

| Column | Type | Source | Notes |
|------|-----|--------|--------|
| SeasonYear | number | pull from Static_Season_Config | e.g., 2025 |
| Player | text | pull from Player_Master | Future; all Active players|
| PlayerKey | text | derived from Player | |
| RoundsPlayed | number | aggregate from Indiv_Results_Staging | |
| TotalPoints | number | aggregate from Indiv_Results_Staging | |
| AvgPoints | number | derive from Indiv_Results_Staging | |
| AvgGross | number | derive from Indiv_Results_Staging | |
| AvgNet | number | derive from Indiv_Results_Staging | |
| LowGross | number | derive from Indiv_Results_Staging | |
| LowNet | number | derive from Indiv_Results_Staging | |
| TotBirdies | number | aggregate from Indiv_Results_Staging | |
| TotEagles | number | aggregate from Indiv_Results_Staging | |
| TotDoubleEagles | number | aggregate from Indiv_Results_Staging | |

---

## Section G — Weekly Player Results

### Query: `Summary_New__Weekly_Stats`

**Grain:** 1 row per player per week

Weekly results for reporting and audits.

| Column | Type | Source | Notes |
|------|-----|--------|--------|
| SeasonYear | number | pull from Static_Season_Config | e.g., 2025 |
| MatchWeek | number | pull from Indiv_Results_Staging | |
| MatchDate | date | pull from Indiv_Results_Staging | |
| Player | text | pull from Indiv_Results_Staging | |
| PlayerKey | text | text | derived from Player | |
| GrossScore | number | pull from Indiv_Results_Staging | |
| NetScore | number | pull from Indiv_Results_Staging | |
| Points | number | pull from Indiv_Results_Staging | |
| Birdies | number | pull from Indiv_Results_Staging | |
| Eagles | number | pull from Indiv_Results_Staging | |
| DoubleEagles | number | pull from Indiv_Results_Staging | |
| ExclScore | logical | pull from Indiv_Results_Staging | |

---

## Explicitly Out of Scope

- Playoff logic and playoff summaries
- Historical per-hole timelines
- Trend analytics
- File-level provenance

---

## Change Control

This schema is locked as of **2025-12-21**.

Any changes require:

- Explicit agreement
- Version increment
- Documented rationale
