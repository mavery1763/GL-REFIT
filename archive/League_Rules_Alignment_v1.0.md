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

------------

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

------------

Section 2 – Handicaps & Handicap Establishment

Final (Agreed Alignment)

2.1 Handicap Strokes Applied at the Hole Level
League Rule Reference

League rules specify that:

Handicap strokes in a match are determined by:

Calculating the difference between the two players’ handicaps, rounded to the nearest whole number

Assigning that many strokes to the higher-handicap player only

Applying strokes on holes in order from hardest to easiest

The lower-handicap player receives zero strokes

REFIT Alignment

REFIT must replicate the league rule behavior exactly, not approximate it.

Accordingly:

Hole-level handicap strokes are determined by:

Computing the handicap difference between opponents, rounded per league rules

Assigning strokes only to the higher-handicap player

Applying strokes in hole handicap order (hardest → easiest)

REFIT will not independently apply each player’s full handicap at the hole level

Rationale

Applying full handicaps independently to each player can produce off-by-one stroke errors relative to league rules

REFIT’s goal is rules fidelity, not computational convenience

Any internal representation (arrays, flags, computed columns) must yield identical hole outcomes to the league method

Resolution:
REFIT hole scoring logic shall be explicitly difference-based, matching league rules, and not derived from independent per-player handicap allocation.

2.2 Handicap Rounding

Agreed

Handicaps are calculated and stored to two decimal places

Rounding to a whole number occurs only when determining:

Net scores

Handicap stroke allocation for a match

REFIT shall use the same rounding thresholds defined in league rules

2.3 Established vs. Unestablished Handicap Status
Definition (Agreed)

A player is considered unestablished if:

A valid handicap cannot be calculated prior to the start of the match

This status is determined by the Master (Summary), not the Match Report

REFIT Responsibilities

The Master:

Determines whether a player is established or unestablished

Provides either:

The established handicap value, or

The parameters required to compute the handicap after the round

The Match Report:

Calculates the handicap used for that match only when the player is unestablished

Uses:

Prior qualifying score(s) supplied by Master

The gross score entered for the current match

Outputs the calculated handicap used for scoring

Validation Rule

If a player is marked established:

REFIT validates that the handicap reported by Match Report matches Summary

A mismatch triggers a warning or error, not an override

If a player is unestablished:

REFIT trusts the handicap value produced by Match Report

2.4 Match-Used Handicap Calculation

Agreed

For unestablished players:

Match Report computes the handicap used for that match

The captain does not manually calculate or enter the handicap

REFIT ensures the calculation logic is deterministic and rule-compliant

2.5 Handicap Carryforward Between Seasons

Agreed

Each season begins with up to the 10 most recent qualifying scores from the prior season

These scores:

Count toward establishing a handicap early in the season

Are tracked distinctly from “season rounds played”

REFIT Master:

Maintains both:

Handicap rounds available

Current-season rounds played

2.6 Handicap Recalculation Timing

Agreed

REFIT Master:

Recalculates handicaps after results are finalized for a week

Applies the updated handicap to the next scheduled match

Match Reports:

Never retroactively alter handicaps

Only report the handicap used for the match being recorded

2.7 Handicap Error Handling

Agreed

REFIT shall not auto-correct handicap discrepancies

Any mismatch:

Generates a warning or error

Requires correction at the Match Report level, not directly in Master data

This preserves the league’s existing correction workflow

2.8 Post-Facto Corrections

Agreed

Any correction to scoring or handicaps:

Is made in the original Match Report

Not directly in the Master workbook

REFIT will:

Re-ingest corrected Match Reports

Recompute downstream results accordingly

This behavior mirrors the current league process and preserves auditability.

Section 2 Summary

REFIT’s handicap system:

Matches league rules exactly

Distinguishes clearly between:

Established vs. unestablished players

Match-used handicap vs. future handicap calculation

Enforces validation without silent correction

Preserves historical workflow and correction practices

--------------

Section 3 – Scoring, Points Allocation & Exclusions
Final (Agreed Alignment)

This section defines how individual hole scoring, points allocation, forfeits, and exclusions are represented and handled within REFIT, ensuring strict alignment with league rules and previously agreed design decisions.

3.1 Hole Completion vs. Pick-Up (Authoritative)

Final Decision (Corrected):
REFIT will use HoleCompleted_XX (TRUE/FALSE) as the authoritative hole-level indicator.

HoleCompleted_XX = TRUE
→ Player holed out and completed the hole.

HoleCompleted_XX = FALSE
→ Player did not hole out (picked up, conceded, or otherwise did not complete the hole).

This field applies to all players, including Blind Draw players.

Rationale:

This directly supports the league rule distinction between:

Both players reaching max strokes and holing out (hole halved), versus

One player holing out and the other picking up (hole won).

HoleCompleted_XX is semantically correct, symmetric, and future-proof.

This aligns with Section 1 (1.1) and supersedes any use of PickedUp_XX.

Status: ✅ Agreed and locked

3.2 Maximum Strokes per Hole

Maximum strokes per hole = Par + 5, per league rules.

When a player reaches the maximum:

If they hole out, HoleCompleted_XX = TRUE

If they pick up, HoleCompleted_XX = FALSE

Scoring logic will evaluate both stroke count and hole completion.

Status: ✅ Agreed

3.3 Hole-Level Points Allocation

Per league rules:

Hole win → 2 points

Hole halved → 1 point each

Hole lost → 0 points

REFIT determines hole outcome using:

Gross strokes

Net strokes

HoleCompleted_XX

Handicap strokes applied to the hole

Status: ✅ Agreed

3.4 Individual Match Points (Low Net)

Each match awards 2 additional points for low net.

Determined based only on played holes.

If a match is shortened:

Low net points are awarded based on completed holes.

If tied, low net points are split.

Status: ✅ Agreed

3.5 Team Net Points

Team net = sum of eligible individual net scores.

4 points awarded for lower team net.

If team nets are tied, points are split.

Eligibility of an individual score is controlled by ExclScore, not inferred logic.

Status: ✅ Agreed

3.6 Partial Matches & Weather-Shortened Play

When matches are shortened due to weather or darkness:

Hole points already played are awarded normally.

Unplayed holes’ points are split.

Team net points:

Based on completed matches if any exist.

Split if no matches were completed.

Scores from such matches are excluded from future handicap calculations using ExclScore.

Status: ✅ Agreed

3.7 Forfeits & Blind Draw Handling (Clarified)
Individual Forfeit

A no-show golfer forfeits the match.

Opponent plays against a Blind Draw – Forfeit player:

Score = 40

Handicap = 0

Opponent earns points normally.

Forfeiting golfer earns 0 points.

Entire Team No-Show (Rare Case – Clarified)

Team that shows up plays the round.

They score as if playing against four Blind Draw – Forfeit players.

Showing team earns all points legitimately won.

No-show team receives 0 total points, regardless of Blind Draw scoring.

This condition is captured via:

ForfeitFlag = TRUE

Team-level context (not inferred from individual rows)

Status: ✅ Agreed and clarified

3.8 ExclScore Usage (Authoritative)

ExclScore is the sole mechanism used to determine whether an individual score:

Contributes to future handicap calculations

Contributes to team net

Examples include:

Weather-shortened matches

Matches with unplayed holes

Forfeits

Late arrivals affecting hole eligibility

No exclusions are inferred implicitly.

Status: ✅ Agreed

3.9 Post-Facto Corrections

If an error is discovered after submission:

Corrections are made in the Match Report, not directly in the Master.

REFIT then re-ingests corrected data through the standard pipeline.

This mirrors historical league practice and preserves auditability.

Status: ✅ Agreed

-------------

Section 4 — Team Scoring, Team Net & Forfeits
Final (Agreed Alignment)
4.1 Definition of MatchCompleted (Team vs Individual)

Clarification (Authoritative):

MatchCompleted is an individual-match flag, not a team-level flag.

Each of the four individual matches within a team match has its own MatchCompleted value.

A team match may therefore contain a mix of:

completed individual matches

uncompleted individual matches (weather, late arrival, early termination, etc.)

There is no separate TeamMatchCompleted flag in REFIT.

4.2 Calculation of Team Net Score

Agreed Rule:

Team Net is calculated as the sum of Net scores from completed individual matches only.

Individual matches where MatchCompleted = FALSE are excluded from Team Net calculation.

Examples:

4 completed individual matches → Team Net = sum of all 4

3 completed individual matches → Team Net = sum of those 3

0 completed individual matches → Team Net is not calculable

4.3 Representation of Team Net When Not Fully Available

Agreed Decisions:

If no individual matches are completed:

TeamNet shall be NULL, not zero.

If one or more individual matches are completed:

TeamNet reflects the sum of those completed matches only.

Rationale:

Zero is a valid golf score and would corrupt comparisons.

NULL explicitly signals “not applicable / not computable.”

4.4 Team Net Points (4 Points for Low Net)

Agreed Rules:

Team Net Points are awarded only when Team Net is computable for both teams.

If both teams have a valid Team Net:

Lower Team Net earns 4 points

Tie splits points (2 / 2)

If one team has a computable Team Net and the other does not:

Team with computable Team Net earns all 4 points

If neither team has a computable Team Net:

Team Net points are split (2 / 2)

4.5 Team Forfeits
4.5.1 Individual-Level Forfeits

Handled entirely at the individual match level using:

ForfeitFlag = TRUE

Blind Draw logic per Section 1

Team Net calculation follows normal rules based on completed matches.

4.5.2 Full-Team Forfeit (Rare Case)

Agreed Handling:

If an entire team does not show up:

The opposing team plays the round

The opposing team scores as if playing against 4 Blind Draw – Forfeit players

Blind Draw – Forfeit definition:

Gross = 40

Handicap = 0

The no-show team:

Receives 0 total points

Has TeamNet = NULL

Has ForfeitFlag = TRUE on all four individual matches

Important:

No additional TeamForfeitType field is required.

Full-team forfeits are derived as:

count(ForfeitFlag = TRUE) = 4

4.6 Use of Team Net in Leaderboards & Analytics

Agreed Constraint:

Team Net values derived from fewer than 4 completed matches:

ARE valid for awarding Team Net Points

ARE NOT valid for:

Weekly low team net leaderboards

Season-to-date team net rankings

Any analytics that assume full team participation

These exclusions are enforced downstream using:

MatchCompleted

Count of completed individual matches

ExclScore logic

4.7 Data Model Implications

Upload_Team.TeamNet may be:

A numeric value

NULL

NULL Team Net values must be preserved through:

Raw

Staging

Analytics

No zero-substitution is allowed at any stage.

4.8 Alignment with Prior Sections

This section is fully aligned with:

Section 1: Blind Draw profiles, forfeits, and ExclScore semantics

Section 2: Handicap integrity and exclusion rules

Section 3: Points allocation and exclusion logic

There are no unresolved dependencies.

----------

Section 5 – Blind Draw Player Modeling & Settings Integration — Final (Agreed Alignment)

This section defines how Blind Draw matches are modeled, displayed, calculated, and ingested in REFIT, ensuring:

Full compliance with league rules

Continuity with captain expectations and workflows

Clean separation between presentation, settings, and calculation logic

Zero ambiguity during debugging or future maintenance

This section supersedes all prior drafts for Section 5.

5.1 Blind Draw Scenarios (Authoritative Definitions)

REFIT recognizes two distinct Blind Draw scenarios, which are not interchangeable and must be modeled explicitly:

A. BlindDrawTeam (Scheduled Blind Draw Match)

Occurs when:

The league has an odd number of teams

One team is scheduled to play a Blind Draw team instead of a live opponent

Characteristics:

Not a forfeit

Treated as a legitimate scheduled match

Blind Draw players simulate a team of four players

Points are earned normally by the live team

Blind Draw team does not accumulate standings points

B. BlindDrawForfeit (Forfeit Replacement)

Occurs when:

A player (or entire opposing team) does not show up for a scheduled match

Characteristics:

Represents a forfeit condition

Blind Draw players act as the opponent for scoring purposes

Non-forfeiting team may earn points

Forfeiting side earns zero points

These two scenarios are explicitly identified and never inferred.

5.2 Blind Draw Player Representation
REFIT Decision

REFIT will not create actual player rows for Blind Draw players in Upload_Ind.

Instead:

Blind Draw logic is applied within scoring calculations

Blind Draw behavior is deterministic and reproducible

No Blind Draw players appear in player history, handicap tracking, or analytics

Rationale

Blind Draw players are not real golfers

Their “performance” is rule-defined, not earned

Historical tracking of Blind Draw players provides no analytical value

Forfeit impact analysis is better derived at the team/match level, not via synthetic players

This replaces the legacy approach of rostered “Blind Draw [TeamName]” players.

5.3 Blind Draw Type Identification

REFIT uses explicit identifiers, not derived inference.

Authoritative Identifiers

BlindDrawForfeit

BlindDrawTeam

These identifiers:

Are used internally by REFIT logic

Determine which Blind Draw profile applies

Control scoring behavior and exclusions

No additional BlindDrawType flag is required.

5.4 Blind Draw Profiles in Settings (Locked Design)

Blind Draw behavior is defined entirely in Settings, not hard-coded.

Settings Profiles (Final Names)

BlindDrawForfeit

BlindDrawTeam

Profile Contents

Each profile contains only one array:

Score_01 … Score_18

Explicit Exclusions

The following do NOT belong in Blind Draw profiles:

Par_XX → inherited from course

Hcp_XX → inherited from course

NetScore_XX → computed (Blind Draw handicap = 0)

Points_XX → computed dynamically per opponent

Rationale

Blind Draw par and handicap holes are identical to live players

Blind Draw net score equals gross score

Points depend on opponent’s score and must be calculated at runtime

Keeping profiles minimal prevents silent misalignment and debugging errors

5.5 Blind Draw Hole Score Visibility (Captain Experience)

Blind Draw hole scores must be visible in the Match Report.

Behavior

Blind Draw hole scores populate automatically

Captains do not enter Blind Draw scores

Blind Draw rows appear visually identical to live opponents

Why This Is Required

Captains must verify scoring against scorecards

Blind Draw matches must feel operationally identical to live matches

Debugging discrepancies requires full hole-by-hole visibility

This matches current league behavior and expectations

5.6 Match Report Responsibilities (Blind Draw)

The Match Report:

Displays Blind Draw hole scores

Displays computed gross, net, and points

Allows captains to validate results visually

Does not contain Blind Draw logic formulas beyond lookup/display

All Blind Draw logic is:

Defined in Settings

Executed by REFIT calculations

Never manually overridden by captains

5.7 Scoring Consistency Across Match Types

From the captain’s perspective:

Live vs Live matches

Live vs BlindDrawTeam matches

Live vs BlindDrawForfeit matches

…must all:

Look the same

Behave the same

Be reviewed the same way

REFIT guarantees:

No special workflows

No conditional captain behavior

No hidden score handling

5.8 Exclusions & Analytics Impact

Blind Draw matches:

Do not contribute to player handicap history

Do not create player-level statistical records

Do contribute to team points and standings where applicable

Forfeit effects can be analyzed via:

Match flags

Team-level summaries

Derived metrics (e.g., “points gained via forfeits”)

No Blind Draw player stats are retained.

5.9 Final Summary (Section 5)

✔ Two explicit Blind Draw scenarios
✔ Explicit identifiers (BlindDrawForfeit, BlindDrawTeam)
✔ Blind Draw scoring driven by Settings
✔ Hole-by-hole visibility preserved for captains
✔ No synthetic player records
✔ No ambiguity, inference, or silent logic

This section is final, aligned, and implementation-ready.

-----------

