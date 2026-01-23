/*
===============================================================================
 Query:      Team_Results_Staging
 Version:    vDraft.1
 Purpose:    Canonical staging table for team-level match results.
 Author:     REFIT Project
 Created:    2025-12-30
 Source:     Upload_Team_Raw (query, not worksheet table)
 Layer:      STAGING
-------------------------------------------------------------------------------
 Design Principles:
 - Source ONLY from Upload_Team_Raw query
 - No file system access
 - No business rule inference
 - No aggregation beyond structural normalization
 - Schema must be stable even when no data exists
===============================================================================
*/

let
    //--------------------------------------------------------------------------
    // 1. SOURCE
    //--------------------------------------------------------------------------
    Source =
        Upload_Team_Raw,

    //--------------------------------------------------------------------------
    // 2. COERCE DATA TYPES (defensive, explicit)
    //--------------------------------------------------------------------------
    Typed =
        Table.TransformColumnTypes(
            Source,
            {
                {"SourceFile", type text},
                {"Year",       Int64.Type},
                {"Week",       Int64.Type},
                {"Date",       type date},
                {"Team",       type text},
                {"Opponent",   type text},
                {"TmNet",     type number},
                {"TmNetPoints", type number},
                {"TmTotPoints", type number}
            },
            "en-US"
        ),
    
    //--------------------------------------------------------------------------
    // 3. ADD SeasonYear FROM Static_Season_Config
    //--------------------------------------------------------------------------
        
        SeasonConfig =
            Excel.CurrentWorkbook(){[Name = "Static_Season_Config"]}[Content],

        
        SeasonYear =
            Number.From(
                SeasonConfig{[SettingKey = "SeasonYear"]}[SettingValue]
            ),

    //--------------------------------------------------------------------------
    // 3b. ADD SeasonYear COLUMN TO STAGING TABLE
    //--------------------------------------------------------------------------
    
        AddSeasonYear =
            Table.AddColumn(
                Typed,
                "SeasonYear",
                each SeasonYear,
                Int64.Type
            ),

    //--------------------------------------------------------------------------
    // 4. ADD DERIVED KEYS (structural only)
    //--------------------------------------------------------------------------

    // MatchWeek = Week
        AddedMatchWeek =
            Table.RenameColumns(
                AddSeasonYear,
                {{"Week", "MatchWeek"}}
            ),

    // MatchDate = Date
        AddedMatchDate =
            Table.RenameColumns(
                AddedMatchWeek,
                {{"Date", "MatchDate"}}
            ),

    // TeamKey = SeasonYear|Team
        AddedTeamKey =
            Table.AddColumn(
                AddedMatchDate,
                "TeamKey",
                each
                    if [SeasonYear] <> null and [Team] <> null
                    then Text.From([SeasonYear]) & "|" & [Team]
                    else null,
                type text
            ),

    // MatchKey = SeasonYear|MatchWeek|TeamKey
    AddedTeamMatchKey =
        Table.AddColumn(
            AddedTeamKey,
            "TeamMatchKey",
            each
                if [SeasonYear] <> null and [MatchWeek] <> null and
                    [TeamKey] <> null
                then Text.From([SeasonYear]) & "|" & Text.From([MatchWeek]) &
                    "|" & [TeamKey]
                else null,
            type text
        ),

    //--------------------------------------------------------------------------
    // 4. SELECT CANONICAL STAGING COLUMNS
    //--------------------------------------------------------------------------
    SelectedColumns =
        Table.SelectColumns(
            AddedTeamMatchKey,
            {
                "SourceFile",
                "SeasonYear",
                "Year",
                "MatchWeek",
                "MatchDate",
                "Team",
                "Opponent",
                "TeamKey",
                "TeamMatchKey",
                "TmNet",
                "TmNetPoints",
                "TmTotPoints",
                "MatchCompletedTeam",
                "ForfeitFlag"
            },
            MissingField.UseNull
        )

in
    SelectedColumns

/* Version History
    v1.0 Original version

    vDraft.1 2025-12-30
    - Added code block to populate SeasonYear from Static_Season_Config table
=============================================================================== 

*/