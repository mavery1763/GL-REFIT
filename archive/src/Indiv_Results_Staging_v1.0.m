let
    /**********************************************************************
      Indiv_Results_Staging_v1.0
      Purpose: Canonical player-round staging table (17 columns) sourced
               from Upload_Indiv_Raw. Applies minimal standardization:
               - selects/creates required fields
               - normalizes names (Totals + Points)
               - coerces types (safe)
               - schema-locked output

      Dependencies:
        - Query/Table: Upload_Indiv_Raw (Excel table loaded by PQ)

      Output schema (authoritative):
        SourceFile, Week, Date, Side, Team, Opponent, Position, Player,
        Gross, Hdcp, Net, BirdiesTotal, EaglesTotal, DoubleEaglesTotal,
        NetPoints, PointsTotal, ExclScore
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
            "Week",
            "Date",
            "Side",
            "Team",
            "Opponent",
            "Position",
            "Player",
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
            {"SourceFile",       "SourceFile"}   // harmless no-op if already correct
        },

    Renamed =
        Table.RenameColumns(Source, RenameMap, MissingField.Ignore),

    // ================================================================
    // 4) ADD ANY MISSING REQUIRED COLUMNS AS NULLS (empty-safe + robust)
    // ================================================================
    ExistingCols = Table.ColumnNames(Renamed),

    MissingCols =
        List.Difference(RequiredCols, ExistingCols),

    WithMissingAdded =
        List.Accumulate(
            MissingCols,
            Renamed,
            (state as table, colName as text) =>
                Table.AddColumn(state, colName, each null)
        ),

    // ================================================================
    // 5) SELECT + ORDER FINAL COLUMNS (schema lock)
    // ================================================================
    Selected =
        Table.SelectColumns(WithMissingAdded, RequiredCols, MissingField.UseNull),

    // ================================================================
    // 6) TYPE COERCION (kept conservative; avoids hard refresh failures)
    // ================================================================
    Typed =
        Table.TransformColumnTypes(
            Selected,
            {
                {"SourceFile",        type text},
                {"Week",              Int64.Type},
                {"Date",              type date},
                {"Side",              type text},
                {"Team",              type text},
                {"Opponent",          type text},
                {"Position",          Int64.Type},
                {"Player",            type text},
                {"Gross",             type number},
                {"Hdcp",              type number},
                {"Net",               type number},
                {"BirdiesTotal",      Int64.Type},
                {"EaglesTotal",       Int64.Type},
                {"DoubleEaglesTotal", Int64.Type},
                {"NetPoints",         type number},
                {"PointsTotal",       type number},
                {"ExclScore",         type text}
            },
            "en-US"
        )

in
    Typed
