# Summary_New — Canonical Data Summary Table

Data hub for GL-REFIT, fed by existing tables and calculation engines and
designed such that downstream consumers never access raw tables.
- Repository for all data feeds  
- Source for all data needed downstream in the process flow
- "One-stop-shop" for league state
- No calculattions or business logic here
- Authoritative human-readable league dashboard

## Section A - League & Season Metadata

### Purpose
- Contains metadata for the league and current season being played

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Season

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per season

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section B - Teams

### Purpose
- Contains team identity and status
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

## Section C - Players

### Purpose
- Player registry, including non-rostered subs

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Players

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per player, including non-rostered subs

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section D - Handicaps

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

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section E - Matches

### Purpose
- Contains match-level facts

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Matches

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per match played

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section F - Player Matches

### Purpose
- Contains data on player participation in matches that have been played

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Player_Matches

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per player, per match (8 x N matches)

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section G - Season-to-date stats

### Purpose
- Contains season-to-date stats for players, including non-rostered subs

### Source Tables
- TBD

### Query & Output Table Name
- Summary_New__Season_Stats

### Downstream Usage
- TBD 

### Info and Assumptions
- One row per match participant

### Version History
- vDraft — 2025-12-18
- Stub query until engines exist
- Confirmed compatibility with current REFIT workbook

## Section H - Weekly Stats

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