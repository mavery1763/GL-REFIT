/*
===============================================================================
 Query:        Indiv_Results_Holes
 Version:      v1.0
 Status:       LOCKED
 Last updated: 2026-01-24
 Tag:          v1.0-pre-engine-audit
-------------------------------------------------------------------------------
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
            {"Week",             "MatchWeek"}   // harmless no-op if already
        },                                      // correct

    Renamed =
        Table.RenameColumns(Source, RenameMap, MissingField.Ignore),

    //
    // 3. ADD COLUMNS FOR SEASONYEAR, PLAYERKEY, TEAMKEY, MATCHKEY AND DERIVE
    //
    
    SeasonConfigQry =
        qry_Static_Season_Config,

    GetSeasonSetting =
        (key as text) as any =>
            let
                rows =
                    Table.SelectRows(
                        SeasonConfigQry,
                        each [SettingKey] = key
                    )
            in
                if Table.RowCount(rows) = 1
                then rows{0}[SettingValue]
                else error
                    "Expected exactly one '" & key & "' row in
                        Static_Season_Config",

    SeasonYear =
        Number.From(
            GetSeasonSetting("SeasonYear")
        ),

    AddSeasonYear =
        Table.AddColumn(
            Renamed,
            "SeasonYear",
            each SeasonYear,
            Int64.Type
        ),

    AddPlayerKey = // PlayerKey = UPPER(TRIM(Player))
        Table.AddColumn(
            AddSeasonYear,
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
            "IndivMatchKey",
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

/* 
Version History

V1.0  2026-01-24
- Finalized after engine audit.

vDraft.2 2026-01-04
- Replaced direct call to Static_Season_Config table with call to 
    qry_Static_Season_Config query to pull in SeasonYear.

vDraft.1 2026-01-01
- Removed base type coercion for ID fields at the beginning and added type
    coercion in TypedFinal.  Added columns for, and derived, SeasonYear, 
    PlayerKey, TeamKey and MatchKey.

*/