**REFIT Match Report** **Output Specification v1.0 @COMMENT1: Should
there also be a Match Report Input Specification? E.g. data being pulled
into the file, like team rosters, current handicaps, and what the
secretary/captains have to enter, etc.@**

**Document purpose.**  
Define exactly what the *Match Report workbook* must output into its
internal tables so the REFIT Master workbook can ingest weekly results
via Power Query with no manual adjustments.

The Match Report file is responsible for:

- Capturing captain input (scores, lineups, flags)

- Performing local calculations needed for that file (per-round points,
  team totals, etc.)

- Exposing **two standardized output tables**:

1.  Upload_Ind – individual player-round level

2.  Upload_Team – team-match level

@COMMENT2: Add’l responsibilities of the workbook might include: 1)
gathering data from master file that is needed for match reporting, like
handicaps from Summary, 2) communicating league status data to captains,
such as info from Summary sheet, Weekly Leaderboard, Season Leaderboard,
etc@

These tables are the **only objects** the REFIT Master reads from each
Match Report.

**1. General Conventions**

**1.1 Grain (level of** **detail)**

- **Upload_Ind**

  - 1 row per **player-round** in a match report.

  - Includes:

    - All 4 lineup players on “Your Team”

    - All 4 opposing players (“Your Opponent”)

    - Any subs actually used (either side)

    - Any Blind Draw rows that participate in scoring (full BD match or
      BD used to fill a forfeit slot)

> e3f10d4f-9409-43ac-b478-31e453c…

- **Upload_Team**

  - 1 row per **team per match** in that file.

  - For a standard match report: 2 rows (Team vs. Opponent).

  - For a “team vs Blind Draw” report: still 2 rows:

    - Real team

    - Blind Draw “team” representing league-defined BD behavior.

@COMMENT3: Should there be Settings and Settings Documentation sheets
for the Match Report workbook, or can those be kept in the master file
and the Match Report workbook can link to them?@

**1.2 Naming & Types**

- Column **names are authoritative** and must match exactly what is
  specified here.

- Column **order** is flexible, but stable order is recommended.

- Data types are specified as *int / number / text / date*; Excel may
  store some as General, but Power Query will coerce them. **@COMMENT4:
  Is there need for Boolean/logical data type for flags?@**

**1.3 Match Metadata**

Each row in either table must include enough information to uniquely
identify:

- Season (Year)

- Week number (Week)

- Play date (Date)

- Course/side played (Side – e.g., *Raintree Front*, *Raintree Back*)

- Team and Opponent names (as used in league standings)

**1.4 Blind Draw & Forfeits**

- Blind Draw players are represented as ordinary rows in Upload_Ind,
  with:

  - Player values like *Blind Draw \#1* etc.

  - Team equal to the “Blind Draw” team name configured in Settings.

- Forfeit handling (when BD fills in for missing player):

  - BD rows appear in Upload_Ind exactly where that BD score
    participates.

  - Flags and/or ExclScore communicate which scores are excluded or
    synthetic.

**2. Upload_Ind Output Table Specification**

**2.1 Table Overview**

- Excel table name: **Upload_Ind**

- Purpose: full record of every player-round with both aggregate and
  hole-level fields.

- Grain: one row per player-round per match.

**2.2 Required Column Groups**

Rather than list all ~215 columns one by one, this spec defines **column
groups** that must exist with consistent naming patterns.

**A. Source & Match Metadata**

<table>
<colgroup>
<col style="width: 15%" />
<col style="width: 6%" />
<col style="width: 78%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;"><strong>Column name</strong></th>
<th style="text-align: center;"><strong>Type</strong></th>
<th style="text-align: center;"><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td>SourceFile</td>
<td>Text</td>
<td>File name of the match report workbook (no path).</td>
</tr>
<tr>
<td>Year</td>
<td>Int</td>
<td>Season year shown at top of match report (e.g., 2025).</td>
</tr>
<tr>
<td>Week</td>
<td>Int</td>
<td>League week number from the sheet (e.g., cell C5).</td>
</tr>
<tr>
<td>Date</td>
<td>Date</td>
<td>Match play date from the sheet (e.g., cell I5).</td>
</tr>
<tr>
<td>Side</td>
<td>Text</td>
<td><p>Side played (e.g., “Raintree Front”, “Raintree Back”) keyed off
the captain’s drop-down in cell S5.</p>
<p>e3f10d4f-9409-43ac-b478-31e453c…</p></td>
</tr>
</tbody>
</table>

These are the **minimum**; additional metadata (CourseID, etc.) may be
added later if needed.

**B. Team / Player Identity**

<table>
<colgroup>
<col style="width: 15%" />
<col style="width: 14%" />
<col style="width: 70%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;"><strong>Column name</strong></th>
<th style="text-align: center;"><strong>Type</strong></th>
<th style="text-align: center;"><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td>Team</td>
<td>Text</td>
<td>Name of the “Your Team” or “Opposing Team” for this player’s
row.</td>
</tr>
<tr>
<td>Opponent</td>
<td>Text</td>
<td>Name of the opposing team in the match.</td>
</tr>
<tr>
<td>Position</td>
<td>Int</td>
<td>Playing position (1–4) for that week; blank or 0 for non-playing
roster members should not appear in this output.</td>
</tr>
<tr>
<td>Player</td>
<td>Text</td>
<td><p>Player name exactly as used for league reporting (Lastname,
Firstname &lt;tee&gt; convention for new names wherever possible).</p>
<p>e3f10d4f-9409-43ac-b478-31e453c…</p></td>
</tr>
<tr>
<td>IsSub</td>
<td>text / logical</td>
<td>Indicates whether this player was a sub that week (“Y”/“N” or
TRUE/FALSE).</td>
</tr>
<tr>
<td>IsBlindDraw</td>
<td>text / logical</td>
<td>Indicates Blind Draw rows (“Y”/“N” or TRUE/FALSE).
<strong>@COMMENT5: Is text or logical better for “flag” data, or doesn’t
it make a difference?@</strong></td>
</tr>
</tbody>
</table>

Optional (but recommended future fields):

- PlayerKey – stable league identifier for linking across seasons.

- TeamKey – may mirror Team_Results_Staging logic (Year\|Team).

@COMMENT6: I agree that these should be added, especially if their
presence would make finding a record easier during troubleshooting.

Also, a couple of additional fields to consider would be team captain
designation (“C” in player’s name in legacy match report) and what Tee a
player is playing from (also part of the player name in legacy match
report. Both of these are discrete, and I think would be better not tied
to the player’s name. E.g., we’ve had captains move away mid-season, and
a new player becomes captain.@

**C. Aggregate Scoring Fields**

These must match what **Indiv_Results_Staging** expects. **@COMMENT7:
I’m confused about data flow. I thought the tables in the match report
file had to align with the Upload_Indiv_Raw and Upload_Team_Raw tables.
In turn, the Indiv_Results_Staging and Team_Results_Staging would align
with the schema in the respective \_Raw files? Upload_Ind --\>
Upload_Indiv_Raw --\> Indiv_Results_Staging --\> etc.@**

<table>
<colgroup>
<col style="width: 21%" />
<col style="width: 8%" />
<col style="width: 70%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;"><strong>Column name</strong></th>
<th style="text-align: center;"><strong>Type</strong></th>
<th style="text-align: center;"><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td>Gross</td>
<td>number</td>
<td>Gross score for the side played this week.</td>
</tr>
<tr>
<td>Hdcp</td>
<td>number</td>
<td><p>Handicap used for this match (including on-the-fly calc for new
players).</p>
<p>e3f10d4f-9409-43ac-b478-31e453c…</p></td>
</tr>
<tr>
<td>Net</td>
<td>number</td>
<td>Net score for the match (Gross − Hdcp, or equivalent rules).</td>
</tr>
<tr>
<td>Tot_Birdies</td>
<td>int</td>
<td>Count of birdies in the round (over the 9 played holes).</td>
</tr>
<tr>
<td>Tot_Eagles</td>
<td>int</td>
<td>Count of eagles.</td>
</tr>
<tr>
<td>Tot_DoubleEagles</td>
<td>int</td>
<td>Count of double eagles.</td>
</tr>
<tr>
<td>PointsNet</td>
<td>number</td>
<td>Individual Net points from Points Calcs worksheet.</td>
</tr>
<tr>
<td>PointsTot</td>
<td>number</td>
<td>Total individual points (all components) from Points Calcs
worksheet.</td>
</tr>
<tr>
<td>ExclScore</td>
<td>text</td>
<td>Exclusion reason/category, if this individual’s scores should be
excluded from certain downstream calculations (e.g., team net).</td>
</tr>
</tbody>
</table>

Notes:

- These names must remain exactly as shown so that
  **Indiv_Results_Staging** can:

  - Change types.

  - Rename them to BirdiesTotal, EaglesTotal, DoubleEaglesTotal,
    NetPoints, PointsTotal.

- ExclScore is first introduced here; staging and analytics treat it as
  canonical.

**D. Per-Hole Long-Form Arrays (18-Hole Layout)**

Even though captains only enter 9 holes per match, the output tables
must present standardized 18-hole arrays:

- Par_01 … Par_18

- Hcp_01 … Hcp_18

- Score_01 … Score_18

- NetScore_01 … NetScore_18

- Bird_01 … Bird_18

- Eagle_01 … Eagle_18

- DoubleEagle_01 … DoubleEagle_18

- Points_01 … Points_18

@COMMENT8: I guess I’m still not understanding why it’s essential that
the long-form needs to exist in the match report file. It seems that the
scoring data can be expanded to the long-form as it is passed from the
match report to the Upload_Indiv_Raw table.@

Rules:

1.  **Side mapping**

    - If the match is played on the *Front* side:

      - Holes actually played correspond to 1–9.

      - Score_01–Score_09 (and corresponding Par/Hcp/etc.) are
        populated.

      - Score_10–Score_18 (and corresponding fields) should be
        null/blank.

    - If the match is played on the *Back* side:

      - Holes actually played might be 10–18 logically, but still must
        be mapped into the **01–09** positions if the agreed REFIT
        convention is “side-relative numbering,” or directly into 10–18
        if using absolute numbering.

      - This choice must align with the Snapshot’s “long-form 18-hole
        mapping” decision already implemented in the master – we will
        keep using the same convention already baked into the PQ logic.

> @COMMENT9: I think the second bullet here implies that absolute
> numbering will be used. Why not opposite of holes 1-9 actually played
> (Score_01-09 are null/blank, while Score_10-18 are populated. Same
> with Par, Hcp, etc.@

2.  **Par & Hcp values**

    - All par and handicap values come from Settings-driven arrays,
      **not** from the captain manually. **@COMMENT10: Should Blind Draw
      Team and Blind Draw Forfeit hole score values also come from
      Settings-driven arrays?@**

3.  **NetScore_x**

    - Should be per-hole net score used for point calculation.

4.  **Bird/Eagle/DoubleEagle flags**

    - Typically 1/0 or TRUE/FALSE for each hole where the result meets
      that category.

5.  **Points_x**

    - Per-hole points resulting from the league point rules (calculated
      locally in the match report and written into the array).

These long-form fields are the basis for building
**Indiv_Results_Holes** (18 rows per player-round). **@COMMENT11: I
thought the query for populating the Indiv_Results_Holes table was
sourcing from Upload_Indiv_Raw, not directly from the match report?@**

**E. Flags and Auxiliary Fields**

Additional fields that may appear:

- CompletedMatch – text flag from captain dropdown indicating if the
  match was fully completed (all holes played out). This is used
  upstream in Points Calcs and to determine who contributes to Team Net.

> e3f10d4f-9409-43ac-b478-31e453c…

- HdcpSource – optional, indicates whether handicap came from master
  Summary or in-file calculation area.

- LeagueNotes – optional, free text notes (rarely used).

The REFIT Master will initially only depend on the fields used by
staging queries; extra fields are allowed as long as they don’t change
names of the required ones.

**3. Upload_Team Output Table Specification**

**3.1 Table Overview**

- Excel table name: **Upload_Team**

- Purpose: capture team-level results and points for each match.

- Grain: one row per team per match report file.

**3.2 Required Columns**

These must align with **Team_Results_Staging** expectations.
**@COMMENT12: I’m confused about data flow. I thought the tables in the
match report file had to align with the Upload_Indiv_Raw and
Upload_Team_Raw tables. In turn, the Indiv_Results_Staging and
Team_Results_Staging would align with the schema in the respective \_Raw
files? Upload_Ind --\> Upload_Indiv_Raw --\> Indiv_Results_Staging --\>
etc. (Ref. COMMENT7)@**

<table style="width:97%;">
<colgroup>
<col style="width: 17%" />
<col style="width: 8%" />
<col style="width: 71%" />
</colgroup>
<thead>
<tr>
<th style="text-align: center;"><strong>Column name</strong></th>
<th style="text-align: center;"><strong>Type</strong></th>
<th style="text-align: center;"><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td>SourceFile</td>
<td>text</td>
<td>Name of match report file.</td>
</tr>
<tr>
<td>Year</td>
<td>int</td>
<td>Season year.</td>
</tr>
<tr>
<td>Week</td>
<td>int</td>
<td>League week number.</td>
</tr>
<tr>
<td>Date</td>
<td>date</td>
<td>Play date (same as in Upload_Ind).</td>
</tr>
<tr>
<td>Team</td>
<td>text</td>
<td>Team name (for Blind Draw, use configured BD team name).</td>
</tr>
<tr>
<td>Opponent</td>
<td>text</td>
<td>Opponent team name.</td>
</tr>
<tr>
<td>Tm Net</td>
<td>number</td>
<td><p>Team net total for the match (sum of included individual net
scores).</p>
<p>e3f10d4f-9409-43ac-b478-31e453c…</p></td>
</tr>
<tr>
<td>Tm Net Points</td>
<td>number</td>
<td>Points awarded for team net result.</td>
</tr>
<tr>
<td>Tm Tot Points</td>
<td>number</td>
<td>Total team points for the week.</td>
</tr>
</tbody>
</table>

Optional but recommended:

- MatchCompleted – flag for weather/abandoned matches.

- ForfeitFlag – indicates matches decided by forfeit.

- Side – duplicate of Side from Upload_Ind for convenience.

@COMMENT13: I agree that these should be included.@

**3.3 Keys and Derived Fields (Master-Side)**

Team_Results_Staging will derive:

- TeamKey = Year\|Team

- MatchKey = Year\|Week\|Team

So those do **not** need to be present in the raw output, but the above
columns must be stable so those keys can be generated.

**4. Table Placement and Naming in the Match Report File**

- Both Upload_Ind and Upload_Team tables can live on:

  - A dedicated “Output” sheet,

  - Or hidden sheets,

  - Or the same sheet, as long as table names are unique.

- Table names must be exactly:

  - Upload_Ind

  - Upload_Team

- No VBA or PQ is required inside the Match Report template; formulas
  and standard Excel tables are sufficient, as long as the output tables
  appear in the file.

> @COMMENT14: I agree that these tables can live on one sheet which is
> hidden (as they are today). Additionally, should these tables be
> protected (so a captain cannot overtype a formula and lose it)?@

**5. Expected Behavior for Special Cases**

**5.1 Empty Week / Template with No Data**

- If no players or team data have been entered yet:

  - Upload_Ind and Upload_Team should still exist as tables with
    **headers only** and **zero data rows**.

  - REFIT Master will ingest them and simply yield no rows for that file
    (no error conditions).

**5.2 Partial Matches / Rainouts**

- Individual rows should still be present for any players who have
  meaningful scores.

- CompletedMatch and/or ExclScore will be used to:

  - Exclude those rows from Team Net or other calculations when
    appropriate.

- Team rows in Upload_Team must still exist, with:

  - Tm Net, Tm Net Points, Tm Tot Points set per league rules for
    shortened matches.

**5.3 Forfeits and Blind Draw**

- Forfeit scenarios where BD fills in:

  - BD entries appear as IsBlindDraw = TRUE rows in Upload_Ind, with
    normal hole arrays and points.

- Matches vs. Blind Draw:

  - Real team: regular rows in Upload_Ind and a single row in
    Upload_Team.

  - Blind Draw side: BD rows in Upload_Ind and a BD “team” row in
    Upload_Team.

**6. Versioning and Change Control**

- This document is **v1.0** of the REFIT Match Report Output
  Specification.

- Any change that:

  - Adds new required columns,

  - Renames or removes existing required columns,

  - Or changes the grain of either table  
    must be reflected in:

  - This spec, and

  - The corresponding staging/analytics Power Query code.

> @COMMENT15: Should there be a comment in PQ code and possibly (?) the
> match report filename that ties to the Spec version number? What is
> the protocol to determine when a change is minor (e.g. v1.0 -\> v1.1)
> versus major (e.g. v1.x -\> v2.0)?@
