/*
===============================================================================
 Query:      Summary_New__Player_Stats
 Version:    vDraft.4
 Purpose:    
 Author:     Mike Avery
 Created:    2026-01-08
 Source:     TBD
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Design Principles:
 - Source(s) (TBD)
 - No file system access
 - No business rule inference
 - Schema must be stable even when no data exists
-------------------------------------------------------------------------------
 Notes:
 - Section F in schema
 - No business logic
 - No inference
 - Single-row table
 - Populated later by engines
===============================================================================
*/

let
    // ============================================================
    // SECTION 0 — SEASON CONTEXT (Static_Season_Config)
    // ============================================================

    AllSeasonSettings =
        qry_Static_Season_Config,

    ActiveSeasonRows =
        Table.SelectRows(
            AllSeasonSettings,
            each [SettingKey] = "SeasonStatus"
                and [SettingValue] = "Active"
        ),

    ActiveSeasonCount =
        Table.RowCount(ActiveSeasonRows),

    CurrentSeasonKey =
        if ActiveSeasonCount = 1 then
            ActiveSeasonRows{0}[SeasonKey]
        else if ActiveSeasonCount = 0 then
            error "No Active season found in Static_Season_Config
                (SeasonStatus=Active)."
        else
            error "Multiple Active seasons found in Static_Season_Config.
                Expected exactly 1.",

        SeasonRows =
        Table.SelectRows(
            AllSeasonSettings,
            each [SeasonKey] = CurrentSeasonKey
        ),

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
                    error "Missing required season setting '" & key & "'."
                else
                    error "Non-scalar season setting '" & key & "'.",

    SeasonYear_Value =
        GetSeasonScalar("SeasonYear"),

    //-----------------------------------------------------------------------
    // 1) Source
    //-----------------------------------------------------------------------
    Source =
        Indiv_Results_Staging,

        //-----------------------------------------------------------------------
    // 3) Filter to current season
    //-----------------------------------------------------------------------
    CurrentSeason =
        Table.SelectRows(
            Source,
            each [SeasonYear] = SeasonYear_Value
        ),

    //-----------------------------------------------------------------------
    // 4) Aggregate to season-to-date player stats
    //
    // NOTE ON ExclScore HANDLING
    //
    // ExclScore does NOT suppress competitive outcomes such as Points or
    // achievement metrics (e.g., Birdies, Eagles).
    //
    // Points are earned according to league rules and remain authoritative
    // even if a round is flagged ExclScore (e.g., to prevent sandbagging
    // once match outcomes are decided).
    //
    // ExclScore is intended primarily for handicap governance (e.g.,
    // exclusion from handicap input rounds) and is enforced by downstream
    // scoring / handicap engines, not by Summary_New snapshot queries.
    //
    // Accordingly, Summary_New__Player_Stats aggregates Points and
    // achievement metrics unconditionally. Any selective exclusion of
    // gross/net scores or handicap inputs occurs later in the processing
    // pipeline.
    //-----------------------------------------------------------------------

    AggPlayerStats =
    Table.Group(
        CurrentSeason,
        {"SeasonYear", "Player", "PlayerKey"},
        {
            {"RoundsPlayed", each Table.RowCount(_), Int64.Type},

            {"TotalPoints", each List.Sum([PointsTotal]), type number},
            {"AvgPoints",   each List.Average([PointsTotal]), type number},

            {"AvgGross", each List.Average([Gross]), type number},
            {"AvgNet",   each List.Average([Net]),   type number},
            {"LowGross", each List.Min([Gross]),     type number},
            {"LowNet",   each List.Min([Net]),       type number},

            {"TotBirdies",       each List.Sum([BirdiesTotal]),       Int64.Type},
            {"TotEagles",        each List.Sum([EaglesTotal]),        Int64.Type},
            {"TotDoubleEagles",  each List.Sum([DoubleEaglesTotal]),  Int64.Type},

            {"AsOfMatchWeek", each List.Max([MatchWeek]), Int64.Type},
            {"AsOfMatchDate", each List.Max([MatchDate]), type date}
        }
    ),

    //-----------------------------------------------------------------------
    // 5) Final projection (schema enforcement)
    //-----------------------------------------------------------------------
    Final =
        Table.SelectColumns(
            AggPlayerStats,
            {
                "SeasonYear",
                "Player",
                "PlayerKey",
                "AsOfMatchWeek",
                "AsOfMatchDate",
                "RoundsPlayed",
                "TotalPoints",
                "AvgPoints",
                "AvgGross",
                "AvgNet",
                "LowGross",
                "LowNet",
                "TotBirdies",
                "TotEagles",
                "TotDoubleEagles"
            }
        )
in
    Final

/* Version History

    vDraft.4 - 2026-01-08
    - Code generated by GPT-5.2 to correct errors in vDraft.3, including...
      > Binding the query to a validated, active season.
      > Added retrieval of SeasonYear from season context.
    

    vDraft.3 - 2025-12-31
    - Removed ExclScore code block and added note to clarify handling of
        score exclusions.

    vDraft.2 - 2025-12-
    - Updated comments and documentation

    vDraft.1 - 2025-12-
    - Revised per design review feedback

    v1.0 - 2025-12-
    - Initial version
*/