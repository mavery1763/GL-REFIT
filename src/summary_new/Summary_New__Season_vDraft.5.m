/*
===============================================================================
 Query:      Summary_New__Season
 Version:    vDraft.5
 Status:     DRAFT (Schema wired)
 Purpose:    Metadata for TMMNGL and current season of play
 Author:     GL-REFIT
 Created:    2026-01-05
 Source:     Settings, static season config
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Design Principles:
 - Source from Settings table and static season config (TBD)
 - No file system access
 - No business rule inference
 - Schema must be stable even when no data exists
-------------------------------------------------------------------------------
 Notes:
 - Section A in Schema
 - No business logic
 - No inference
 - Single-row table
 - Populated later by engines
===============================================================================
*/

let
    // ============================================================
    // SECTION 0 — SEASON SETTINGS (via qry_Static_Season_Config)
    // ============================================================

    AllSeasonSettings =
        qry_Static_Season_Config,

    ActiveSeasonRows =
        Table.SelectRows(
            AllSeasonSettings,
            each [SettingKey] = "SeasonStatus" and [SettingValue] = "Active"
        ),

    ActiveSeasonCount =
        Table.RowCount(ActiveSeasonRows),

    CurrentSeasonKey =
        if ActiveSeasonCount = 1 then
            ActiveSeasonRows{0}[SeasonKey]
        else if ActiveSeasonCount = 0 then
            error "No Active season found in Static_Season_Config (SeasonStatus=
                Active)."
        else
            error "Multiple Active seasons found in Static_Season_Config. 
                Expected exactly 1.",

    SeasonRows =
        Table.SelectRows(
            AllSeasonSettings,
            each [SeasonKey] = CurrentSeasonKey
        ),

    // Scalar retrieval helper scoped to CURRENT season only
    GetSeasonScalar =
        (key as text) as any =>
            let
                rows =
                    Table.SelectRows(
                        SeasonRows,
                        each [SettingKey] = key
                    ),
                n = Table.RowCount(rows)
            in
                if n = 1 then
                    rows{0}[SettingValue]
                else if n = 0 then
                    error "Missing required season setting '" & key & "' for 
                        SeasonKey=" & Text.From(CurrentSeasonKey) & "."
                else
                    error "Non-scalar season setting '" & key & "' for 
                        SeasonKey=" & Text.From(CurrentSeasonKey) & " (found " & 
                        Text.From(n) & " rows).",

    // ============================================================
    // SECTION 1 — REQUIRED SCALARS FOR SUMMARY
    // ============================================================

    LeagueName =
        GetSeasonScalar("LeagueName"),

    SeasonYear =
        GetSeasonScalar("SeasonYear"),

    Eligibility_MinPctRounds =
        GetSeasonScalar("Eligibility_MinPctRounds"),

    SeasonStatus =
        GetSeasonScalar("SeasonStatus"),

    SeasonRoundsPlanned =
        GetSeasonScalar("SeasonRoundsPlanned"),

    // ============================================================
    // SECTION 2 — LATEST MATCH COMPLETION (from Summary_New__Matches)
    // ============================================================

    Matches =
        Summary_New__Matches,

    CompletedMatches =
        Table.SelectRows(
            Matches,
            each [MatchCompletedTeam] = true
        ),

    LatestWeek =
        if Table.RowCount(CompletedMatches) = 0
        then null
        else List.Max(CompletedMatches[MatchWeek]),

    LatestDate =
        if Table.RowCount(CompletedMatches) = 0
        then null
        else List.Max(CompletedMatches[MatchDate]),

    // ============================================================
    // SECTION 3 — OUTPUT RECORD / TABLE
    // ============================================================

    SeasonRecord =
        [
            LeagueName               = LeagueName,
            SeasonYear               = SeasonYear,
            MatchWeek                = LatestWeek,
            MatchDate                = LatestDate,
            SeasonRoundsPlanned      = SeasonRoundsPlanned,
            Eligibility_MinPctRounds = Eligibility_MinPctRounds,
            SeasonStatus             = SeasonStatus
        ],

    SeasonTable =
        Table.FromRecords({ SeasonRecord }),

    Typed =
        Table.TransformColumnTypes(
            SeasonTable,
            {
                {"LeagueName", type text},
                {"SeasonYear", Int64.Type},
                {"MatchWeek", Int64.Type},
                {"MatchDate", type date},
                {"SeasonRoundsPlanned", Int64.Type},
                {"Eligibility_MinPctRounds", type number},
                {"SeasonStatus", type text}
            }
        )

in
    Typed
/* 
Version History

    vDraft.5 2026-01-07
    - Code generated by GPT-5.2 to correct errors in vDraft.4, including...
      > Elimination of {0} row selection without validating rowcount.
      > Fixed the undefined name StaticSeasonConfigQry (it should be your season
        config table).
      > Ensure scalar retrieval is done within the selected season, not across
        all seasons.
      > Improve error messages to reflect Static_Season_Config (not
        Settings_System).
    
    vDraft.4 2026-01-04
    - Replaced direct call to Static_Season_Config table with call to 
      qry_Static_Season_Config query to pull in SeasonYear.  (CODE IS INCORRECT
      AND WAS NEVER ACTUALLY IMPLEMENTED)

    vDraft.3 2026-01-
    - 

    vDraft.2 2025-12-
    - 

    vDraft.1 2025-12
    - 

    v1.0  2025-12-
    - Original version

*/    