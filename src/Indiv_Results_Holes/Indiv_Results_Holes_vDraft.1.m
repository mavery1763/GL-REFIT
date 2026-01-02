/*
===============================================================================
 Query:        Indiv_Results_Holes
 Version:      vDraft.1
 Status:       
 Author:       GL-REFIT
 Last Updated: 2026-01-01

 Purpose:
   Explodes player-round records into a normalized hole-level fact table
   (one row per player per hole), supporting advanced analytics:
     - Hole difficulty modeling
     - Birdie/Eagle frequency
     - Blind Draw logic
     - Future pairing optimization

 Grain:
   Player × Week × Hole

 Source:
   Upload_Indiv_Raw (QUERY, not worksheet)

 Design Rules:
   - No business logic beyond normalization
   - No assumptions about completed holes
   - Missing hole values remain null
===============================================================================
*/

let
    //
    // 1. SOURCE FROM RAW QUERY (NOT WORKSHEET)
    //
    Source = Upload_Indiv_Raw,

    //
    // 2. NORMALIZE LEGACY COLUMN NAMES (if present)
    //    (We rename BEFORE adding missing columns so we don't duplicate.)
    // 
    RenameMap =
        {
            {"Source.Name",      "SourceFile"},
            {"SourceFile",       "SourceFile"},
            {"Date",             "MatchDate"},
            {"Week",             "MatchWeek"}   // harmless no-op if already correct
        },

    Renamed =
        Table.RenameColumns(Source, RenameMap, MissingField.Ignore),

    //
    // 3. ADD COLUMNS FOR SEASONYEAR, PLAYERKEY, TEAMKEY, MATCHKEY AND DERIVE
    //
    
    SeasonConfig =
        Excel.CurrentWorkbook(){[Name = "Static_Season_Config"]}[Content],

    SeasonYear =
        Number.From(
            SeasonConfig{[SettingKey = "SeasonYear"]}[SettingValue]
        ),

    AddSeasonYear =
        Table.AddColumn(
            Source,
            "SeasonYear",
            each SeasonYear,
            Int64.Type
        ),

    AddPlayerKey = // PlayerKey = UPPER(TRIM(Player))
        Table.AddColumn(
            SeasonYear,
            "PlayerKey",
            each Text.Upper(Text.Trim([Player])),
            type text
        ),
    
    AddTeamKey = // TeamKey = SeasonYear|Team
        Table.AddColumn(
            AddPlayerKey,
            "TeamKey",
            each
                if [SeasonYear] <> null and [Team] <> null
                then Text.From([SeasonYear]) & "|" & [Team]
                else null,
            type text
        ),

    AddIndivMatchKey = // MatchKey = SeasonYear|MatchWeek|PlayerKey
        Table.AddColumn(
            AddTeamKey,
            "MatchKey",
            each
                if [SeasonYear] <> null and [MatchWeek] <> null and
                    [PlayerKey] <> null
                then Text.From([SeasonYear]) & "|" & Text.From([MatchWeek]) &
                    "|" & [PlayerKey]
                else null,
            type text
        ),
    //
    // 4. CREATE ONE RECORD PER HOLE (1–18)
    //
    AddedHoleRecords =
        Table.AddColumn(
            AddIndivMatchKey,
            "HoleRecord",
            each
                let
                    row   = _,
                    holes = {1..18}
                in
                    List.Transform(
                        holes,
                        (h) =>
                            let
                                hTxt = Text.PadStart(Text.From(h), 2, "0")
                            in
                                [
                                    Hole        = h,
                                    Score       = Record.FieldOrDefault(row,
                                        "Score_" & hTxt, null),
                                    Par         = Record.FieldOrDefault(row,
                                        "Par_" & hTxt, null),
                                    Hcp         = Record.FieldOrDefault(row,
                                        "Hcp_" & hTxt, null),
                                    NetScore    = Record.FieldOrDefault(row,
                                        "NetScore_" & hTxt, null),
                                    Bird        = Record.FieldOrDefault(row,
                                        "Bird_" & hTxt, null),
                                    Eagle       = Record.FieldOrDefault(row,
                                        "Eagle_" & hTxt, null),
                                    DoubleEagle = Record.FieldOrDefault(row,
                                        "DoubleEagle_" & hTxt, null),
                                    Points      = Record.FieldOrDefault(row,
                                        "Points_" & hTxt, null)
                                ]
                    ),
            type list
        ),

    //
    // 5. EXPAND TO ROWS
    //
    ExpandedHoleList =
        Table.ExpandListColumn(AddedHoleRecords, "HoleRecord"),

    ExpandedHoleFields =
        Table.ExpandRecordColumn(
            ExpandedHoleList,
            "HoleRecord",
            {
                "Hole",
                "Score",
                "Par",
                "Hcp",
                "NetScore",
                "Bird",
                "Eagle",
                "DoubleEagle",
                "Points"
            }
        ),

    //
    // 6. SELECT FINAL FACT TABLE COLUMNS, WITH TYPE COERCION
    //
    Final =
        Table.SelectColumns(
            ExpandedHoleFields,
            {
                "SourceFile",
                "SeasonYear",
                "MatchWeek",
                "MatchDate",
                "IndivMatchKey",
                "Side",
                "Team",
                "TeamKey",
                "Opponent",
                "Position",
                "Player",
                "PlayerKey",
                "Hole",
                "Score",
                "Par",
                "Hcp",
                "NetScore",
                "Bird",
                "Eagle",
                "DoubleEagle",
                "Points"
            }
        ),

    TypedFinal =
        Table.TransformColumnTypes(
            Final,
            {
                {"SeasonYear", Int64.Type},
                {"IndivMatchKey", type text},
                {"PlayerKey", type text},
                {"TeamKey", type text},
                {"Hole", Int64.Type},
                {"Score", Int64.Type},
                {"Par", Int64.Type},
                {"Hcp", Int64.Type},
                {"NetScore", Int64.Type},
                {"Bird", type logical},
                {"Eagle", type logical},
                {"DoubleEagle", type logical},
                {"Points", type number}
            },
            "en-US"
        )

in
    TypedFinal

/* Version History

v1.0 - 2025-12- - Initial version

vDraft.1 - 2026-01-01 - Removed base type coercion for ID fields at the beginning
and added type coercion in TypedFinal.  Added columns for, and derived,
SeasonYear, PlayerKey, TeamKey and MatchKey.
*/