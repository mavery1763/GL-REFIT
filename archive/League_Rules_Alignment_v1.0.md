League_Rules_Alignment.md

REFIT System Alignment Against 2025 League Rules
(Generated from 2025 League Rules — Word document dated Oct 11, 2024)

1. Purpose of This Document

This document compares the official 2025 League Rules against the current REFIT architecture, identifying:

✔ Items where REFIT fully aligns with the rules

⚠ Areas requiring adjustments or decisions

🔧 Areas where REFIT must eventually incorporate rule logic but is not yet implemented

📝 Clarifications needed for Match Report templates or Staging logic

This is a design-alignment document only — not a rule rewrite.

Source: Timken/Metallus Monday Night Golf League–Rules & Regulations (Revised Oct 11, 2024) 

4c5cadad-b5bf-4aa6-8e5a-4954c12…

.

2. High-Level Alignment Summary

REFIT aligns well with the following rule domains:

Rule Area	REFIT Alignment
Weekly reporting deadlines	REFIT supports automated ingestion but does not enforce timing — acceptable.
Match structure (4 players per team)	Raw → Staging → Analytics model assumes eight player rows per match.
Handicap fundamentals (96%, max 20, 36-par basis)	Handicap Engine planned; alignment good.
Blind Draw definition	Fully consistent: REFIT treats BD as 0-hdcp synthetic players with rule-defined hole patterns.
Late golfer rules (0 points for unplayed holes)	REFIT can encode this via ExclScore and hole-level scoring.
Inclement weather logic	REFIT’s ExclScore design supports this; however, some refinements are needed.
Team scoring (4 points low team net)	Team_Results_Staging matches this structure.

Areas requiring work:

Rule Area	Status
Scoring: per-hole points (Win=2, Tie=1, Max=20)	Needs full formula implementation in Match Report template.
Max strokes per hole (5 over par)	Not yet enforced; must be implemented in Match Report logic.
Tee-based handicap recalculation rules	Requires additional fields (Tee, TeeChangeFlag) in Upload_Ind.
Forward tee eligibility & season-long consistency	Requires Settings + Player Profile data.
Late arrival / forfeits logic	Match Report spec supports it, but calculations need encoding.
Team roster & eligibility	Outside REFIT scope — maintained manually, acceptable.

At a systems level, REFIT is fully compatible with 2025 rules, but implementation of scoring and tee-logic must be added in next phases.

3. Detailed Alignment by Rule Section
A. Organization

No REFIT changes required.

REFIT does not manage:

team creation

flight structure

captain meetings

These are administrative processes outside REFIT.

B. Officers

REFIT is neutral to league governance.
No changes required.

C. Election of Officers

No relevance to REFIT.

D. Eligibility

REFIT does not enforce player eligibility and does not need to.

Captains and Secretary manage eligibility manually.

E. Greens Fees & League Dues

Out of scope for REFIT.

F. Team Format

Alignment: Yes

REFIT assumes 4 regular golfers per team (with optional sub)

Upload_Ind supports subs and Blind Draw entries

REFIT does not enforce "sub usage capability" — this is correct

No changes needed.

G. Season Structure
✔ REFIT Alignment

Matches are 9 holes → fully supported

Weekly structure does not affect REFIT

REFIT does not assess flight or playoff structure → correct

⚠ Items requiring tracking

Side (Front/Back) must come from schedule → REFIT already requires this in Upload_Ind

Knockdown round: REFIT should treat it as a standard week with valid scoring

No architectural changes needed.

H. Cancelling Golf

Weather cancellation decisions are outside REFIT.

REFIT only needs to ingest the results captains enter, which may include:

Matches not played

Partial matches

Zero scoring rows

The ExclScore architecture already supports this.

I. Handicaps

This is the most important alignment section.

✔ REFIT Already Aligns with:

36-par basis

96% factor

Max handicap = 20

Use of last 10 rounds

Prior season use when <10 rounds

🔧 Needed Additions in REFIT
1. Tee-based handicap recalculation

Rules require:

Forward tee option for men ≥ 60

Forward tee option for handicap ≥ 15

Mandatory tee change when handicap < 10 and age < 60

Different handicaps when switching tees

→ REFIT currently does not store tee selection nor track tee changes.

Required additions:

Add fields to Upload_Ind:

Tee (Normal/Forward)

TeeChangeFlag (TRUE/FALSE)

Add season-start player profile sheet in Settings.

2. Handicap rounding

Rules require:

Handicap rounding to 2 decimals

Net stroke allowance rounding threshold: ≥ 0.50 rounds up

REFIT must implement these formulas in Handicap Engine.

3. New player handicap rules (first 5 weeks)

REFIT’s Handicap Engine must encode the full ladder:

First round: 96% × (gross − 36) − 2

Second round: 96% × (min of first two rounds − 36) − 1

Third through fifth rounds use minimum of N rounds

Sixth onward follow established logic

REFIT must implement this logic in /src/handicap_engine.

J. Scoring

This is the section requiring the most alignment.

1. Match Play: Hole Points

Rules:

Win hole = 2 points

Halve hole = 1 point

Lose hole = 0 points

Max strokes = par + 5, with forced-loss rules

REFIT requirements:

Must implement hole outcome logic in Match Report template

Must incorporate max-stroke auto-loss logic

Points_XX columns must reflect rules exactly

⚠ Not yet implemented.

2. Low Net Points

Rules:

2 points for low net per individual match

Ties split (1/1)

REFIT must compute NetPoints based on league rule.

Current architecture supports this.

3. Team Scoring

Rules:

4 points for low team net

Total team points = sum of the four individual totals + team net points

REFIT's Team_Results_Staging currently supports:

Tm Net

Tm Net Points

Tm Tot Points

✔ Alignment confirmed.

4. Blind Draw Scoring

Rules specify:

0-handicap

Score = 40 with bogeys on hardest 4 holes

Special rule for "BD vs whole team" matches → BD shoots 38 with bogeys on 2 hardest holes

REFIT:

Currently uses BD rows in Upload_Ind with synthetic scoring

Must encode BD patterns directly in Match Report template

Must account for both BD variants (single vs whole-team fill)

⚠ BD hole pattern generation should be moved into /settings/BlindDrawConfig.md.

5. Late Golfer Rules

Rules:

If established handicap:

0 points for unplayed holes

Low net based on holes played

If no established handicap:

Forfeit the match → BD logic applies

REFIT:

Supports this via ExclScore, but exact logic must be written into Match Report template calculations.

6. Inclement Weather Rules

Rules specify:

With established handicaps:

Net points based on completed holes

Unplayed holes split

Without established handicap:

All points split 10/10

Team net split if no completed matches

REFIT:

ExclScore supports the concept

Need to add specific codes:

WEATHER_ESTABLISHED

WEATHER_NOHDCP

WEATHER_TEAM_SPLIT

Points logic must be encoded in Match Report formulas.

K. Miscellaneous Rules

Most of these relate to course play, OB, drops, tees, winter rules, etc.

REFIT does not evaluate rule compliance on the course; it only ingests final scores.

Only one item affects REFIT:

Tee Selection Rules

Handled in Handicap section.

REFIT must add:

Tee field

Tee validation

Tee-based handicap recalculation

L. Playoff Night

REFIT treats playoffs exactly like a normal match at the data level.

Only requirements:

Players must have established handicap → captains ensure this

Scoring identical → no REFIT changes

Tee times irrelevant to REFIT

M. Prize Money

Not relevant to REFIT.

4. Summary of Required Changes to REFIT
A. Must Implement (High Priority)
Area	Action
Hole-by-hole points logic	Add formulas in Match Report template
Max strokes logic	Add auto-loss rule
Inclement weather rules	Add ExclScore codes + points logic
Late golfer logic	Add points suppression logic
BD hole pattern	Add auto-generated BD scoring
Handicap rounding rules	Add to Handicap Engine
Tee selection	Add Tee + TeeChange logic
B. Should Implement Soon
Area	Action
PlayerKey + TeamKey tracking	For cross-season analytics
Settings-driven BD config	Move patterns out of hard-coded spreadsheet
C. Optional Future Enhancements
Area	Action
Enforcement of eligibility	Out of scope for now
Roster management system	Could be future project
5. Conclusion

The REFIT system aligns strongly with league rules at the architectural level.

All required adjustments involve business logic formulas and input metadata, not structural changes.

There are no contradictions between REFIT and 2025 league rules.

After implementing the items marked Must Implement, REFIT will be fully rule-compliant.

Section 1 — Blind Draw, Maximum Scores, and Hole Completion

FINAL (Agreed Alignment)

This section documents how REFIT implements league rules related to maximum hole scores, Blind Draw behavior, forfeits, and hole completion, with explicit alignment to current league practice and automation requirements.

1.1 Maximum Scores, Picking Up, and Hole Completion
Rule Reference

League rules specify a maximum of 5 over par per hole.
Special handling applies when a player picks up after reaching the maximum versus holing out at the maximum.

Current league interpretation:

If both players hole out at the maximum → hole is tied (1 point each)

If one player holes out at the maximum and the other picks up → the player who holed out wins the hole (2 points)

The legacy system cannot distinguish these cases, creating ambiguity.

REFIT Implementation (Final)

REFIT will explicitly distinguish hole completion status.

Match Report Output (Hole-Level)

Add a hole-level Boolean field:

HoleCompleted_01 … HoleCompleted_18   (TRUE / FALSE)


Meaning:

TRUE → Player holed out on that hole

FALSE → Player picked up (did not hole out)

This field applies only to holes where a maximum score is reached; it may be left TRUE by default otherwise.

Scoring Logic

If both players have HoleCompleted = FALSE → hole is tied

If one TRUE and one FALSE → TRUE wins hole

If both TRUE → compare scores normally (tie or win)

This preserves league intent while removing ambiguity.

Impact Summary

Eliminates long-standing scoring ambiguity

Requires no captain judgment

Preserves current results where data is unambiguous

Enables correct automation without retroactive correction

1.2 Blind Draw Definitions and Profiles
Rule Reference

Blind Draw players are defined as:

Forfeit situations: 0-handicap player shooting 40

Scheduled Blind Draw matches: 0-handicap player shooting 38

Bogeys are assigned on the hardest holes; pars elsewhere.

REFIT Implementation (Final)

Blind Draw behavior will be centralized in Master Settings, not in weekly Match Reports.

Settings Profiles

Two explicit Blind Draw profiles will exist:

BlindDraw_Team

BlindDraw_Forfeit

Each profile contains only one array:

Score_01 … Score_18


Notes:

Par and Hcp values are inherited from course Settings

NetScore = Score (0 handicap)

Points are not stored in Settings (they depend on opponent results)

Match Report Behavior

When a Blind Draw player is required, the Match Report:

Pulls the appropriate Score_XX array from Settings

Automatically populates hole scores, pars, and handicaps

Prevents manual editing by captains

Impact Summary

Blind Draw logic is season-controlled, not week-controlled

Prevents scoring drift or captain error

Fully compatible with future rule changes

1.3 Handicap Establishment and Validation
Rule Reference

Each season begins with up to the last 10 scores from the prior season

Handicaps are based on lowest N of last 10, per league table

Players without sufficient history establish handicaps using current-round scores

REFIT Implementation (Final)
Master File (Summary)

Determines whether a player has an established handicap

Provides:

EstablishedHcp (numeric, when established)

Or parameters for in-round calculation (e.g., “low of XX and score”)

Match Report

Uses Summary-provided data:

If EstablishedHcp exists → must be used

If not established → Match Report calculates handicap using the round just played

Validation

If a Match Report returns a handicap that differs from EstablishedHcp by > 0.01, REFIT raises a warning

REFIT does not override reported values automatically

Impact Summary

Preserves current workflow

Prevents silent corruption

Respects rounding rules in league regulations

1.4 Excluded Scores and Handicap Integrity
Rule Reference

Scores from matches where holes are not competitively played must not affect future handicaps.

Examples:

Opponent arrives late

Holes unplayed due to darkness

Any hole where points cannot be won or lost

REFIT Implementation (Final)

ExclScore will be set for both players in any match where:

Any hole is unplayed by either golfer

Hole outcomes are not fully competitive

Master handicap calculations will exclude these rounds automatically.

1.5 Inclement Weather and Partial Matches
Rule Reference

League rules distinguish:

Established vs unestablished handicaps

Partial completion vs full abandonment

REFIT Implementation (Final)

Match Report determines:

Holes completed

Handicap status of each player

ExclScore and MatchCompleted flags encode the outcome

REFIT applies rules exactly as written without inference

1.6 Late Arrival Rules
Rule Reference

Late arrival with established handicap → partial scoring

Late arrival without established handicap → forfeit

REFIT Implementation (Final)

Late arrival scenarios are resolved in the Match Report

REFIT consumes results as reported

Handicap impact controlled solely by ExclScore

1.7 Tee Selection Rules
Rule Reference

Tee selection is fixed for the season

Rare exceptions may occur (e.g., medical hardship)

REFIT Implementation (Final)

Player roster includes:

Tee ∈ {Normal, Forward}

Changes:

Require explicit override

May reset handicap history when applicable

Optional future enhancement:

Player DOB (only with player consent)

1.8 Playoffs
Scope Decision

Playoffs are out of scope for REFIT v1.

REFIT Position

REFIT supports exporting final regular-season Summary data

Existing Playoff workbook may continue to be used

Design does not block future playoff automation

1.9 Eligibility Enforcement

Eligibility rules remain administrative, not system-enforced.

REFIT records results only.

1.10 Matches Not Played
Rule Reference

Teams failing to appear receive zero points.

REFIT Implementation (Final)

Match Report includes:

MatchNotPlayed (TRUE / FALSE)


Covers:

Team vs Blind Draw no-show

Both teams failing to appear

Scoring and exclusion handled via flags, not inference
