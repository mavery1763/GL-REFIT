/*
===============================================================================
 Query:      Summary_New__Season
 Version:    v1.0 (Production-intent)
 Purpose:    Metadata for TMMNGL and current season of play
 Author:     Mike Avery
 Created:    2025-12-18
 Source:     Settings, static season config
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Design Principles:
 - Source from Settings table and static season config (TBD)
 - No file system access
 - No business rule inference
 - Schema must be stable even when no data exists
===============================================================================
*/
// Draft code (below) used until engines are in place
/*
===============================================================================
 Query:      Summary_New__Season
 Version:    vDraft.3
 Status:     DRAFT (Schema wired)
 Purpose:    Canonical season-level metadata for REFIT
 Layer:      Summary_New
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

    Source =
    Excel.CurrentWorkbook(){[Name="Static_Season_Config"]}[Content],

    SeasonStatusRow =
        Table.SelectRows(
            Source,
            each [SettingKey] = "SeasonStatus" and [SettingValue] = "Active"
        ),

    CurrentSeasonKey =
        SeasonStatusRow{0}[SeasonKey],

    SeasonRows =
        Table.SelectRows(
            Source,
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
