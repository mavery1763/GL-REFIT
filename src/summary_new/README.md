# Summary_New — Canonical Data Summary Table

Data hub for GL-REFIT, fed by existing tables and calculation engines and
designed such that downstream consumers never access raw tables.
- Summary_New is a snapshot of league state as-of the latest processed data
- Source for all data needed downstream in the process flow
- "One-stop-shop" for league state
- No calculattions or business logic here
- Authoritative human-readable league dashboard

## Section A - Season Metadata

### Purpose
- Defines global season context and eligibility parameters.

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Season

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per season
- As-Of Semantics (Locked)
    Only Summary_New__Season explicitly declares the AsOfMatchWeek and
    AsOfMatchDate fields.

    All other Summary_New tables implicitly represent state as of the
    snapshot declared in Summary_New__Season and MUST NOT duplicate
    those fields.

    Per-match and per-week tables encode time intrinsically via
    MatchWeek / MatchDate.


### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.1 — 2025-12-19
- Alignment of parameters with league need
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.2 — 2025-12-21
- Completed wiring to populate with data from workbook tables and queries
- Confirmed compatibility with current REFIT workbook

## Section B - Team State

### Purpose
- Season-to-date team identity and competitive position.
- 
### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Teams

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per team

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.1 — 2025-12-19
- Alignment of parameters with league need
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.2 — 2025-12-21
- Removed AsOfMatchDate and AsOfMatchWeek
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section C - Player Roster State

### Purpose
- Answer: “Who is this player right now?”

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Players

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per player, including non-rostered subs
- “Right now” = as-of the latest successfully processed match week.

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.1 — 2025-12-19
- Alignment of parameters with league need
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.2 — 2025-12-21
- Removed AsOfMatchDate and AsOfMatchWeek
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section D - Handicap State

### Purpose
- Contains current handicap state

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Handicaps

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per player, including non-rostered subs
- Does not contain historical progression
- Historical handicap timelines belong in Analytics

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.1 — 2025-12-19
- Alignment of parameters with league need
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.2 — 2025-12-21
- Removed AsOfMatchDate and AsOfMatchWeek
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section E - Match Participation (Pre/Post Match)

### Purpose
- Answer who played, where, and how they were positioned.

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Matches

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per player per match played

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.1 — 2025-12-19
- Alignment of parameters with league need
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section F - Player Matches

### Purpose
- Season leaderboard metrics

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Player_Stats

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per player

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.1 — 2025-12-19
- Purpose was ... Contains player participation data in played matches
- Query & Output Table were Summary_New__Player_Matches
- Grain was 1 row / player / match (8 x N played matches)
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.2 — 2025-12-21
- Removed AsOfMatchDate and AsOfMatchWeek
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook
- 
## Section G - Weekly Player Results

### Purpose
- Weekly outputs for reports, audits, and recalculation verification

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Weekly_Stats

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per player

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.1 — 2025-12-19
- Section name was Season-to-date Stats
- Purpose was to contain players' season-to-date stats
- Query & Output Table names were Summary_New__Season_Stats
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section H - Weekly Stats (ELIMINATED in vDraft.1 revision)

### Purpose
- Contains weekly stats for match participants

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Weekly_Stats

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per N players x weeks

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

- vDraft.1 — 2025-12-19
- Section H was eliminated in this schema revision
- Reason: Redundant with Summary_New__Teams and Summary_New__Matches
- Replacement: Use Summary_New__Teams for season totals
- Status: Deprecated (do not implement)
