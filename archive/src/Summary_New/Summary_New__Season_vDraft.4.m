/*
===============================================================================
 Query:      Summary_New__Season
 Version:    vDraft.4
 Status:     DRAFT (Schema wired)
 Purpose:    Metadata for TMMNGL and current season of play
 Author:     Mike Avery
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

    SeasonSettings =
        qry_Static_Season_Config,

    GetSeasonSetting = 
            (key as text) as any =>
                let
                    rows =
                        Table.SelectRows(
                            SeasonSettings,
                            each [SettingKey] = key
                        )
                in
                    if Table.RowCount(rows) = 1
                    then rows{0}[SettingValue]
                    else error "Expected exactly one '" & key & "'' row in
                        Settings_System",


    SeasonStatusRow =
        Table.SelectRows(
            SeasonSettings,
            each [SettingKey] = "SeasonStatus" and [SettingValue] = "Active"
        ),

    CurrentSeasonKey =
        SeasonStatusRow{0}[SeasonKey],

    SeasonRows =
        Table.SelectRows(
            StaticSeasonConfigQry,
            each [SeasonKey] = CurrentSeasonKey
        ),

    LeagueName =
        SeasonRows{[SettingKey="LeagueName"]}[SettingValue],
    
    SeasonYear =
        SeasonRows{[SettingKey="SeasonYear"]}[SettingValue],

    Eligibility_MinPctRounds =
        SeasonRows{[SettingKey="Eligibility_MinPct_Rounds"]}[SettingValue],

    SeasonStatus =
        SeasonRows{[SettingKey="SeasonStatus"]}[SettingValue],

    Matches = Summary_New__Matches,
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

    SeasonRoundsPlanned =
        SeasonRows{[SettingKey="SeasonRoundsPlanned"]}[SettingValue],
    
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