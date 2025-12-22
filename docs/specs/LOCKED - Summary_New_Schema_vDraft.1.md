Summary_New — Canonical Schema

Version: vDraft.1
Status: Draft (LOCKED as of 12/21/2025)
Scope: Regular season only (playoffs out of scope)
Layer: Summary_New
Design Role:

Human-readable, engine-ready, season-state snapshot layer
No file I/O, no business calculations, no inference

Design Principles (Reconfirmed)

Summary_New is a snapshot of league state as-of the latest processed data

Every table that represents “current state” includes an AsOfMatchWeek and 
AsOfMatchDate

Engines consume Summary_New, not ingestion or staging

Stubs must exactly match this schema before engines are built

Schema stability > early optimization

Section A — Season Metadata

Query: Summary_New__Season
Grain: 1 row per season

Purpose:
Defines global season context and eligibility parameters.

Column	Type	Notes
SeasonYear	number	e.g., 2026
LeagueName	text	Human-readable
SeasonStatus	text	Planned | Active | Complete
AsOfMatchWeek	number	Latest processed week
AsOfMatchDate	date	Date of latest processed match
SeasonRoundsPlanned	number	May change mid-season
Eligibility_MinPctRounds	number	e.g., 0.5
Section B — Team State

Query: Summary_New__Teams
Grain: 1 row per team

Purpose:
Season-to-date team identity and competitive position.

Column	Type
SeasonYear	number
Team	text
TeamKey	text
Captain	text
AsOfMatchWeek	number
AsOfMatchDate	date
TeamPoints	number
TeamWins	number
TeamLosses	number
TeamTies	number
LowTeamNet	number
HighTeamPoints	number
CurrentlyInPlayoffs	logical
Section C — Player Roster State

Query: Summary_New__Players
Grain: 1 row per player

Purpose:
Answer: “Who is this player right now?”

Column	Type
SeasonYear	number
Player	text
PlayerKey	text
Team	text
ActiveStatus	text
IsCaptain	logical
Tee	text
RosterStartDate	date
RosterEndDate	date
PlayerPhone	text
PlayerEmail	text
AsOfMatchWeek	number
AsOfMatchDate	date

Interpretation:
“Right now” = as-of the latest successfully processed match week.

Section D — Handicap State

Query: Summary_New__Handicaps
Grain: 1 row per player

Purpose:
Current handicap status, not historical progression.

Column	Type
SeasonYear	number
Player	text
PlayerKey	text
EstablishedHcp	logical
Handicap	number
HandicapCalcBasis	text
HandicapRounds	number
SeasonRoundsPlayed	number
AsOfMatchWeek	number
AsOfMatchDate	date

Historical handicap timelines belong in Analytics later, not here.

Section E — Match Participation (Pre/Post Match)

Query: Summary_New__Matches
Grain: 1 row per player per match

Purpose:
Who played, where, and how they were positioned.

Column	Type
SeasonYear	number
MatchWeek	number
MatchDate	date
Team	text
Opponent	text
Player	text
PlayerKey	text
PositionPlayed	number
Side	text
Course	text
MatchCompletedInd	logical
ForfeitFlag	logical
BlindDrawType	text
ReportingCaptainApproved    logical
OpposingCaptainApproved    logical
IsCorrection     logical
CorrectionReason     text
CorrectionEnteredBy     text
CorrectionDate      date
CaptainReapproved     logical
ApprovalStatus     text
Section F — Player Season Totals

Query: Summary_New__Player_Stats
Grain: 1 row per player

Purpose:
Season leaderboard metrics.

Column	Type
SeasonYear	number
Player	text
PlayerKey	text
AsOfMatchWeek	number
AsOfMatchDate	date
RoundsPlayed	number
TotalPoints	number
AvgPoints	number
AvgGross   number
AvgNet    number
LowGross	number
LowNet	number
TotBirdies	number
TotEagles	number
TotDoubleEagles	number
Section G — Weekly Player Results

Query: Summary_New__Weekly_Stats
Grain: 1 row per player per week

Purpose:
Weekly outputs for reports, audits, and recalculation verification.

Column	Type
SeasonYear	number
MatchWeek	number
MatchDate	date
Player	text
PlayerKey	text
GrossScore	number
NetScore	number
Points	number
Birdies	number
Eagles	number
DoubleEagles	number
ExclScore	logical

Explicitly Out of Scope (Confirmed)

Playoff logic and playoff summaries

Historical per-hole timelines

Trend analytics

File-level provenance

### Removed Tables (as of vDraft.1)

The following table was intentionally removed during schema consolidation:

- Summary_New__Team_Stats
  - Reason: Redundant with Summary_New__Teams and Summary_New__Matches
  - Replacement: Use Summary_New__Teams for season totals
  - Status: Deprecated (do not implement)
