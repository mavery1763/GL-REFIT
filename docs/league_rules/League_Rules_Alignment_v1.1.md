League Rules Alignment with REFIT

Version 1.1
League Rules Year: 2025
Alignment Version: v1.1
Status: Final – Approved

Purpose

This document records the authoritative alignment between:

The Timken/Metallus Monday Night Golf League Rules

The REFIT system design and automation logic

Its purpose is to:

Preserve rule intent

Eliminate ambiguity in automation

Explicitly document how REFIT interprets, implements, and safeguards league rules

Provide a durable reference for future secretaries, officers, and developers

This document governs REFIT behavior. If conflicts arise, this document is the interpretive authority unless superseded by a captain-approved rule change.

Section 1 – Blind Draw, Maximum Scores & Hole Completion

Final (Agreed Alignment)

1.1 Hole Completion vs Maximum Score

League Rule Context

Maximum strokes per hole = 5 over par

If both players reach max:

If both hole out → hole is halved

If one holes out and the other picks up → holed-out player wins hole

REFIT Alignment

REFIT will explicitly capture hole completion state

Implementation

Match Report includes:

HoleCompleted_01 … HoleCompleted_18 (TRUE/FALSE)


Scoring logic:

If both players HoleCompleted = TRUE → normal comparison

If one TRUE and one FALSE → holed-out player wins hole

If both FALSE → hole halved

Principle

Scoring must be explicit, not inferred.

1.2 Blind Draw Scenarios

Two Blind Draw scenarios exist:

Scenario	Description
BlindDrawTeam	Scheduled “bye” week match
BlindDrawForfeit	Individual or team forfeit

REFIT Alignment

Blind Draw profiles are defined in Settings, not Match Report

Profiles define gross hole scores only

Settings Profiles

BlindDrawTeam:
  Score_01 … Score_18

BlindDrawForfeit:
  Score_01 … Score_18


Notes

Blind Draw handicap = 0

Par & Hcp come from course Settings

NetScore = Score

Points are computed dynamically vs opponent

1.3 Blind Draw Visibility

Agreement

Blind Draw hole scores MUST be visible in Match Report

Captains require full transparency to validate scoring

Implementation

Blind Draw hole scores auto-populate

Captains do not manually enter them

Layout mirrors live-player matches exactly

1.4 Blind Draw Rows in Data Model

Agreement

No persistent “Blind Draw player rows” are created in REFIT

Blind Draw is a scoring construct, not a rostered player

Analytics

Forfeit and Blind Draw impacts are derived from:

Match flags

BlindDraw profile used

Points outcomes

Section 2 – Handicaps & Handicap Establishment

Final (Agreed Alignment)

2.1 Handicap Stroke Allocation

League Rule

Handicap difference computed to 2 decimals

Difference rounded to whole strokes

Higher handicap player receives strokes

REFIT Alignment

REFIT applies absolute handicap, rounded to nearest integer

Strokes applied from hardest to easiest holes

Finding

Both methods always yield identical stroke allocation

No conflict exists

2.2 Established vs Unestablished Handicap

Definition

A handicap is unestablished until it can be calculated before the round

REFIT Roles

Master (Summary):

Determines establishedHcp

Supplies parameters for unestablished cases

Match Report:

Calculates handicap only for unestablished players

Uses prior score(s) + current round

Validation

If establishedHcp exists → Match Report must match Summary

Tolerance: ±0.01 strokes

Mismatch triggers warning, not override

2.3 Late Arrival & Handicap Status
Scenario	Outcome
Late arrival, established handicap	Join next hole, unplayed holes = 0 points
Late arrival, unestablished handicap	Automatic forfeit
2.4 Season Carry-Forward

Season begins with up to 10 most recent scores from prior season

Master handles carry-forward logic

Match Report never re-computes historical handicaps

Section 3 – Scoring, Points Allocation & Exclusions

Final (Agreed Alignment)

3.1 Exclusion Principle

Scores must be excluded from future handicap calculations if:

Any hole’s points were not at risk

Holes unplayed, forfeits, late arrivals, weather stoppage

Implementation

ExclScore populated explicitly

No inference based on hole counts

3.2 Full Team Forfeit

Rare Case

Entire team does not show

REFIT Handling

Opposing team plays BlindDrawForfeit

Points awarded normally

No-show team receives 0 points

Section 4 – Team Net, Team Points & Standings

Final (Agreed Alignment)

4.1 Team Net Calculation

Team Net = sum of completed individual nets

Can be based on 1–4 matches

4.2 MatchCompleted Scope

MatchCompleted applies to team match

Individual completion tracked separately

4.3 Team Net Null vs Zero
Scenario	Team Net
Full forfeit	NULL
Partial matches	Calculated from completed matches

Rationale

Prevents distortion of leaderboards

Team Net used only to determine points

Section 5 – Blind Draw Player Modeling & Settings Integration

Final (Agreed Alignment)

BlindDrawTeam ≠ BlindDrawForfeit

Profiles live in Settings

Hole scores visible to captains

No Blind Draw “player” rows

Scoring identical to live matches

Section 6 – Match Completion, Weather & Officer Decisions

Final (Agreed Alignment)

Individual and team completion tracked distinctly

Officer decisions implemented by adjusting Match Report

Adjusted reports re-processed by REFIT

Subsequent weeks recalculated automatically

Section 7 – Player Roster, Substitutes & Eligibility

Final (Agreed Alignment)

REFIT enforces structure, not eligibility policy

Captains and officers remain final authority

REFIT records what occurred

Section 8 – Corrections, Amendments & Reprocessing

Final (Agreed Alignment)

Corrections routed via revised Match Report

Revised files clearly flagged (metadata or filename)

REFIT supports full historical recalculation

Section 9 – Data Integrity, Validation & Warnings

Final (Agreed Alignment)

Errors block ingestion

Warnings notify but do not auto-correct

Secretary remains final arbiter

Section 10 – Season Transitions & Historical Data

Final (Agreed Alignment)

Prior season scores preserved

No destructive edits

Multi-season analytics supported

Section 11 – Governance, Rule Changes & Versioning

Final (Agreed Alignment)

11.1 Rule Authority

Captains retain authority at all times

REFIT must not prevent mid-season changes

11.2 Alignment Versioning

Each alignment document includes:

League Rules Year

Alignment Version

Filename format

League_Rules_Alignment_<RulesYear>_v<AlignmentVersion>.md


Example:

League_Rules_Alignment_2025_v1.1.md

11.3 Mid-Season Rule Changes

Mid-season changes are permitted

New alignment version created (v1.2, v1.3, etc.)

Prior versions retained for auditability

11.4 Repository Practice

Latest approved version lives in /docs/league_rules/

Prior versions archived in /docs/league_rules/archive/

11.5 Final Authority

This document defines REFIT behavior.
