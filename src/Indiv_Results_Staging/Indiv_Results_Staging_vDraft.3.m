let
    /**********************************************************************
      Indiv_Results_Staging_vDraft.3.m
      Purpose: Canonical player-round staging table (17 columns) sourced
               from Upload_Indiv_Raw. Applies minimal standardization:
               - selects/creates required fields
               - normalizes names (Totals, Points, Week, Date)
               - coerces types (safe)
               - schema-locked output

      Dependencies:
        - Query/Table: Upload_Indiv_Raw (Query)

      Output schema (authoritative):
        SourceFile, SeasonYear, MatchWeek, MatchDate, Side, Team, Opponent,
        Position, Player, Gross, Hdcp, Net, BirdiesTotal, EaglesTotal,
        DoubleEaglesTotal, NetPoints, PointsTotal, ExclScore
    **********************************************************************/

    // ================================================================
    // 1) SOURCE
    // ================================================================
    Source =
        Upload_Indiv_Raw,

    // ================================================================
    // 2) CANONICAL OUTPUT COLUMN LIST (schema lock)
    // ================================================================
    RequiredCols =
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
            "Gross",
            "Hdcp",
            "Net",
            "BirdiesTotal",
            "EaglesTotal",
            "DoubleEaglesTotal",
            "NetPoints",
            "PointsTotal",
            "ExclScore"
        },

    // ================================================================
    // 3) NORMALIZE LEGACY COLUMN NAMES (if present)
    //    (We rename BEFORE adding missing columns so we don't duplicate.)
    // ================================================================
    RenameMap =
        {
            {"Tot_Birdies",      "BirdiesTotal"},
            {"Tot_Eagles",       "EaglesTotal"},
            {"Tot_DoubleEagles", "DoubleEaglesTotal"},
            {"PointsNet",        "NetPoints"},
            {"PointsTot",        "PointsTotal"},
            {"Source.Name",      "SourceFile"},
            {"SourceFile",       "SourceFile"},
            {"Date",             "MatchDate"},
            {"Week",             "MatchWeek"}   // harmless no-op if already correct
        },

    Renamed =
        Table.RenameColumns(Source, RenameMap, MissingField.Ignore),

    //--------------------------------------------------------------------------
    // 4) PULL SeasonYear FROM Static_Season_Config
    //--------------------------------------------------------------------------
    
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

    //--------------------------------------------------------------------------
    // 4.a) ADD SeasonYear COLUMN TO STAGING TABLE
    //--------------------------------------------------------------------------
    
        WithSeasonYear =
            Table.AddColumn(
                Renamed,
                "SeasonYear",
                each SeasonYear,
                Int64.Type
            ),
    

        AddTeamKey =
            Table.AddColumn(
                WithSeasonYear,
                "TeamKey",
                each
                    if [SeasonYear] <> null and [Team] <> null
                    then Text.From([SeasonYear]) & "|" & [Team]
                    else null,
                type text
            ),

    // ================================================================
    // 5) Derive PlayerKey Column
    // ================================================================
           
        AddPlayerKey =
            Table.AddColumn(
                AddTeamKey,
                "PlayerKey",
                each Text.Upper(Text.Trim([Player])),
                type text
            ),
    
    // ================================================================
    // 6) Derive IndivMatchKey Column
    //    (composite key: SeasonYear-MatchWeek-PlayerKey)
    // ================================================================
    
        WithIndivMatchKey =
            Table.AddColumn(
                AddPlayerKey,
                "IndivMatchKey",
                each
                    Text.Combine(
                        {
                            Text.PadStart(Text.From([SeasonYear]), 4, "0"),
                            Text.PadStart(Text.From([MatchWeek]), 2, "0"),
                            Text.Proper(Text.Trim([PlayerKey]))
                        },
                        "-"
                    ),
                type text
            ),

    // ================================================================
    // 7) ADD ANY MISSING REQUIRED COLUMNS AS NULLS (empty-safe + robust)
    // ================================================================
    ExistingCols = Table.ColumnNames(WithIndivMatchKey),

    MissingCols =
        List.Difference(RequiredCols, ExistingCols),

    WithMissingAdded =
        List.Accumulate(
            MissingCols,
            WithIndivMatchKey,
            (state as table, colName as text) =>
                Table.AddColumn(state, colName, each null)
        ),

    // ================================================================
    // 8) SELECT + ORDER FINAL COLUMNS (schema lock)
    // ================================================================
    Selected =
        Table.SelectColumns(WithMissingAdded, RequiredCols, MissingField.UseNull),

    // ================================================================
    // 9) TYPE COERCION (kept conservative; avoids hard refresh failures)
    // ================================================================
    Typed =
        Table.TransformColumnTypes(
            Selected,
            {
                {"SourceFile",        type text},
                {"SeasonYear",        Int64.Type},
                {"MatchWeek",         Int64.Type},
                {"MatchDate",         type date},
                {"IndivMatchKey",     type text},
                {"Side",              type text},
                {"Team",              type text},
                {"TeamKey",           type text},
                {"Opponent",          type text},
                {"Position",          Int64.Type},
                {"Player",            type text},
                {"PlayerKey",         type text},
                {"Gross",             type number},
                {"Hdcp",              type number},
                {"Net",               type number},
                {"BirdiesTotal",      Int64.Type},
                {"EaglesTotal",       Int64.Type},
                {"DoubleEaglesTotal", Int64.Type},
                {"NetPoints",         type number},
                {"PointsTotal",       type number},
                {"ExclScore",         type logical}
            },
            "en-US"
        )

in
    Typed

/*  
    Version History
    
    vDraft.3 2026-01-04
    - Replaced direct call to Static_Season_Config table with call to 
      qry_Static_Season_Config query to pull in SeasonYear.

    vDraft.2 2026-01-01
    - Added column for SeasonYear sourced from Static_Season_Config table, and
      IndivMatchKey, derived from data already in the staging table.  Added
      column for PlayerKey derivation.

    vDraft.1 2025-12-
        - 
    v1.0  2025-12-
    - Original version

*/