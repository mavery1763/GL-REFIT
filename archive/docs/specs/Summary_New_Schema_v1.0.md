# Summary_New Schema — v1.0

Project: Golf League REFIT
Document: Summary_New Schema
Version: v1.0
Status: Approved (Schema Lock)
Last Updated: 2025-12-XX

1. Purpose

Summary_New is the central consolidated view of league state in REFIT.

It serves as:

The authoritative human-readable league dashboard

A contracted data source for:

Handicap calculation engine

Match scoring engine

Weekly & season leaderboards

Reporting / exports

A stable abstraction layer over:

Raw ingestion tables

Staging transformations

Settings

Summary_New does not perform calculations.
It exposes results, eligibility flags, and state produced by other engines.

2. Primary Consumers

League Secretary

Team Captains

Handicap Engine

Match Scoring Engine

Reporting / Analytics

Future automation (PDFs, exports, dashboards)

3. Design Principles

One-stop shop for league state

Explicit fields (no inference by consumers)

Nulls represent “not applicable / did not occur”

No duplicated business logic

Season-safe (mid-season rule changes supported)

4. High-Level Structure

Summary_New is conceptually organized into seven sections.
Physical implementation may be one table or multiple related tables.

Section	Name
A	League & Season Metadata
B	Team-Level Season State
C	Player Roster & Status
D	Handicap State
E	Match Participation (Pre-Match)
F	Player Season-to-Date Statistics
G	Team Season-to-Date Statistics
5. Section A — League & Season Metadata

One row per season.

Field	Type	Description
LeagueName	Text	League name (supports historical renames)
SeasonYear	Number	League season year
MatchWeek	Number	Current match week
MatchDate	Date	Date of current match week
SeasonRoundsPlanned	Number	Planned number of match weeks
Eligibility_MinPctRounds	Number	Minimum % rounds required for eligibility
SeasonStatus	Text	Planned / Active / Completed
6. Section B — Team-Level Season State

One row per team.

Field	Type	Description
Team	Text	Team identifier
TeamName	Text	Optional descriptive name
Wins	Number	Matches won
Losses	Number	Matches lost
Ties	Number	Matches tied
PointsTotal	Number	Total team points
LowTeamNet	Number	Lowest team net score achieved
HighTeamPoints	Number	Highest team points in a match
CurrentlyInPlayoffs	TRUE/FALSE	If season ended now, team qualifies
7. Section C — Player Roster & Status

One row per player per season.

Field	Type	Description
Player	Text	Standardized player name
Team	Text / Null	Team assignment (null for subs)
ActiveStatus	Text	Active / Sub / Inactive
IsCaptain	TRUE/FALSE	Captain designation
Tee	Text	Normal / Senior / Forward
RosterStartDate	Date	Date player joined roster
RosterEndDate	Date / Null	Date player left roster
PlayerEmail	Text	Contact
PlayerPhone	Text	Contact
8. Section D — Handicap State

One row per player per week.

Field	Type	Description
Player	Text	Player name
EstablishedHcp	TRUE/FALSE	Handicap established before match
Handicap	Number / Null	Established handicap
HandicapCalcRule	Text / Null	e.g., “Low of score & 47”
HandicapSource	Text	Prior season / Current season
HdcpRoundsAvailable	Number	Rounds usable for handicap
SeasonRoundsPlayed	Number	Rounds played this season

Note:
For unestablished players, Handicap may be null and HandicapCalcRule populated.

9. Section E — Match Participation (Pre-Match)

One row per player per match.

Field	Type	Description
MatchWeek	Number	Match week
MatchDate	Date	Match date
Team	Text	Player’s team
Opponent	Text	Opposing team
Player	Text	Player
PositionPlayed	Number / Null	1–4 if played, null if DNP
Side	Text	Front / Back
Course	Text	Course identifier
BlindDrawType	Text / Null	Team / Forfeit / Null
MatchCompletedInd	TRUE/FALSE	Individual match completed
MatchCompletedTeam	TRUE/FALSE	Team match completed
ForfeitFlag	TRUE/FALSE	Forfeit occurred
10. Section F — Player Season-to-Date Statistics

One row per player.

Field	Type	Description
Player	Text	Player
RoundsPlayed	Number	Completed rounds
AvgGross	Number	Average gross
AvgNet	Number	Average net
TotalPoints	Number	Total points
AvgPoints	Number	Average points
LowGross	Number	Lowest gross
LowNet	Number	Lowest net
BirdiesTotal	Number	Season birdies
EaglesTotal	Number	Season eagles
DoubleEaglesTotal	Number	Season double eagles
11. Section G — Team Season-to-Date Statistics

One row per team.

Field	Type	Description
Team	Text	Team
MatchesPlayed	Number	Matches completed
TeamPointsTotal	Number	Total team points
AvgTeamNet	Number	Average team net
LowTeamNet	Number	Lowest team net
HighTeamPoints	Number	Highest team points
BirdiesTotal	Number	Team birdies
EaglesTotal	Number	Team eagles
DoubleEaglesTotal	Number	Team double eagles
12. Notes on Mid-Season Changes

Rules may change mid-season by captain vote

Summary_New supports:

Rule versioning

Retroactive recalculation

Rule year and version are tracked externally in:

League_Rules_Alignment_YYYY_vX.Y.md

13. Versioning

v1.0 — Initial approved schema

Backward-compatible additions allowed

Breaking changes require new major version

14. Status

✅ Schema locked
🚀 Ready for data-source wiring and engine integration