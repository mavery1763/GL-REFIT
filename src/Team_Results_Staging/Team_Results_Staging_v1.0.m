/*
===============================================================================
 Query:      Team_Results_Staging
 Version:    v1.0 (Production-intent)
 Purpose:    Canonical staging table for team-level match results.
 Author:     REFIT Project
 Created:    2025-12
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
    // 3. ADD DERIVED KEYS (structural only)
    //--------------------------------------------------------------------------

    // TeamKey = Year|Team
    AddedTeamKey =
        Table.AddColumn(
            Typed,
            "TeamKey",
            each
                if [Year] <> null and [Team] <> null
                then Text.From([Year]) & "|" & [Team]
                else null,
            type text
        ),

    // MatchKey = Year|Week|Team
    AddedMatchKey =
        Table.AddColumn(
            AddedTeamKey,
            "MatchKey",
            each
                if [Year] <> null and [Week] <> null and [Team] <> null
                then Text.From([Year]) & "|" & Text.From([Week]) & "|" & [Team]
                else null,
            type text
        ),

    //--------------------------------------------------------------------------
    // 4. SELECT CANONICAL STAGING COLUMNS
    //--------------------------------------------------------------------------
    SelectedColumns =
        Table.SelectColumns(
            AddedMatchKey,
            {
                "SourceFile",
                "Year",
                "Week",
                "Date",
                "Team",
                "Opponent",
                "TeamKey",
                "MatchKey",
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
