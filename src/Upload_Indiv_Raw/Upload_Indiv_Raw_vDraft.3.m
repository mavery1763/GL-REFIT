/*
Query: Upload_Indiv_Raw
Version: vDraft.3
Status: Active
Last Updated: 2026-01-05

Description:
Canonical Raw ingestion query for individual match results.
Conforms to League_Rules_Alignment_2025_v1.1 and REFIT data model.

Notes:
- Empty-folder safe
- Schema-stable
- No Transform File dependency
- Includes temp Rename section to align legacy column names with REFIT model
*/

let
    // ============================================================
    // SECTION 0 — SYSTEM SETTINGS (via qry_Settings_System)
    // ============================================================

        SystemSettings =
            qry_Settings_System,

        GetSystemSetting = 
            (key as text) as any =>
                let
                    rows =
                        Table.SelectRows(
                            SystemSettings,
                            each [SettingName] = key
                        )
                in
                    if Table.RowCount(rows) = 1
                    then rows{0}[SettingValue]
                    else error "Expected exactly one '" & key & "'' row in
                        Settings_System",
        
        UseLocalStagingRaw =
            GetSystemSetting("useLocalStagingFolder"),
               
        MatchReportsFolder =
            Text.From(GetSystemSetting("matchReportsFolderPath")),

        StagingFolder =
            Text.From(GetSystemSetting("stagingFolderPath")),

        FolderToUse =
            if UseLocalStagingRaw
            then StagingFolder
            else MatchReportsFolder,

        ValidatedFolder =
            if FolderToUse = null or FolderToUse = ""
            then error "FolderToUse is null. Check qry_Settings_System."
            else FolderToUse,

    // ============================================================
    // SECTION 1 — EXPECTED SCHEMA (authoritative column names)
    // Breakpoint: paste your canonical header list here.
    //
    // Notes:
    // - Keep "SourceFile" in the list (REFIT standard).
    // - Order here becomes the enforced output order.
    // ============================================================
    ExpectedColumns = {
        "SourceFile","Week","Date","Side","Team","Opponent","Position","Player",
        "Gross","Hdcp","Net","PointsNet","PointsTot","Tot_Birdies","Tot_Eagles",
        "Tot_DoubleEagles","ExclScore","Score_01","Score_02","Score_03",
        "Score_04","Score_05","Score_06","Score_07","Score_08","Score_09",
        "Score_10","Score_11","Score_12","Score_13","Score_14","Score_15",
        "Score_16","Score_17","Score_18","Par_01","Par_02","Par_03","Par_04",
        "Par_05","Par_06","Par_07","Par_08","Par_09","Par_10","Par_11","Par_12",
        "Par_13","Par_14","Par_15","Par_16","Par_17","Par_18","Hcp_01","Hcp_02",
        "Hcp_03","Hcp_04","Hcp_05","Hcp_06","Hcp_07","Hcp_08","Hcp_09","Hcp_10",
        "Hcp_11","Hcp_12","Hcp_13","Hcp_14","Hcp_15","Hcp_16","Hcp_17","Hcp_18",
        "Bird_01","Bird_02","Bird_03","Bird_04","Bird_05","Bird_06","Bird_07",
        "Bird_08","Bird_09","Bird_10","Bird_11","Bird_12","Bird_13","Bird_14",
        "Bird_15","Bird_16","Bird_17","Bird_18","Eagle_01","Eagle_02","Eagle_03",
        "Eagle_04","Eagle_05","Eagle_06","Eagle_07","Eagle_08","Eagle_09",
        "Eagle_10","Eagle_11","Eagle_12","Eagle_13","Eagle_14","Eagle_15",
        "Eagle_16","Eagle_17","Eagle_18","DoubleEagle_01","DoubleEagle_02",
        "DoubleEagle_03","DoubleEagle_04","DoubleEagle_05","DoubleEagle_06",
        "DoubleEagle_07","DoubleEagle_08","DoubleEagle_09","DoubleEagle_10",
        "DoubleEagle_11","DoubleEagle_12","DoubleEagle_13","DoubleEagle_14",
        "DoubleEagle_15","DoubleEagle_16","DoubleEagle_17","DoubleEagle_18",
        "NetScore_01","NetScore_02","NetScore_03","NetScore_04","NetScore_05",
        "NetScore_06","NetScore_07","NetScore_08","NetScore_09","NetScore_10",
        "NetScore_11","NetScore_12","NetScore_13","NetScore_14","NetScore_15",
        "NetScore_16","NetScore_17","NetScore_18","Points_01","Points_02",
        "Points_03","Points_04","Points_05","Points_06","Points_07","Points_08",
        "Points_09","Points_10","Points_11","Points_12","Points_13","Points_14",
        "Points_15","Points_16","Points_17","Points_18"
    },

    // Helper: empty table with the right schema when no files exist
    EmptyOutput = #table(ExpectedColumns, {}),

    // =======================================================================
    // SECTION 1A — NORMALIZE LEGACY COLUMN NAMES
    // 
    // NOTE:
    // This RenameMap works with the Rename op below, and exists ONLY to
    // support legacy 2025 validation.  IT MUST BE REMOVED once REFIT match 
    // report templates are in use.

    RenameMap =
        {
            {"Excl Score",   "ExclScore"},
            {"Score1",       "Score_01"},
            {"Score2",       "Score_02"},
            {"Score3",       "Score_03"},
            {"Score4",       "Score_04"},
            {"Score5",       "Score_05"},
            {"Score6",       "Score_06"},
            {"Score7",       "Score_07"},
            {"Score8",       "Score_08"},
            {"Score9",       "Score_09"},
            {"Bird1",        "Bird_01"},
            {"Bird2",        "Bird_02"},
            {"Bird3",        "Bird_03"},
            {"Bird4",        "Bird_04"},
            {"Bird5",        "Bird_05"},
            {"Bird6",        "Bird_06"},
            {"Bird7",        "Bird_07"},
            {"Bird8",        "Bird_08"},
            {"Bird9",        "Bird_09"},
            {"Eagle1",       "Eagle_01"},
            {"Eagle2",       "Eagle_02"},
            {"Eagle3",       "Eagle_03"},
            {"Eagle4",       "Eagle_04"},
            {"Eagle5",       "Eagle_05"},
            {"Eagle6",       "Eagle_06"},
            {"Eagle7",       "Eagle_07"},
            {"Eagle8",       "Eagle_08"},
            {"Eagle9",       "Eagle_09"},
            {"Points1",      "Points_01"},
            {"Points2",      "Points_02"},
            {"Points3",      "Points_03"},
            {"Points4",      "Points_04"},
            {"Points5",      "Points_05"},
            {"Points6",      "Points_06"},
            {"Points7",      "Points_07"},
            {"Points8",      "Points_08"},
            {"Points9",      "Points_09"},
            {"Source.Name",  "SourceFile"},
            {"SourceFile",   "SourceFile"}  // harmless no-op if already correct
        },

    // ============================================================
    // SECTION 2 — LOAD FILES (defensive; supports empty folder)
    // Breakpoint: verify VisibleFiles row count.
    // ============================================================
    Source =
        Table.Buffer(Folder.Files(ValidatedFolder)),

    VisibleFiles = Table.SelectRows(Source, each [Attributes]?[Hidden]? <> true),

    // If folder is empty, return a clean blank table (no scary errors)

    EmptyResult =
        if Table.RowCount(VisibleFiles) = 0
        then EmptyOutput
        else null,

    // ============================================================
    // SECTION 3 — EXTRACT Upload_Ind TABLE FROM EACH WORKBOOK
    // Breakpoint: validate it correctly finds Upload_Ind in a known file.
    //
    // This avoids Transform File artifacts.
    // ============================================================
    GetUploadIndFromFile = (fileContent as binary, sourceName as text) as 
        table =>
        let
            wb = try Excel.Workbook(fileContent, true) otherwise null,

            // Prefer: Excel table named "Upload_Ind"
            tbl =
                if wb = null then #table({}, {})
                else
                    let
                        matchRows = Table.SelectRows(wb, each ([Kind] = "Table" 
                            and [Item] = "Upload_Ind")),
                        t =
                            if Table.RowCount(matchRows) > 0
                            then matchRows{0}[Data]
                            else #table({}, {})
                    in
                        t,

            // Add SourceFile (REFIT standard)
            withSource =
                if Table.ColumnCount(tbl) = 0
                then tbl
                else Table.AddColumn(tbl, "SourceFile", each sourceName, 
                    type text),

            // Ensure SourceFile is first (nice-to-have)
            reordered =
                if Table.ColumnCount(withSource) = 0 or not 
                    List.Contains(Table.ColumnNames(withSource), "SourceFile")
                then withSource
                else Table.ReorderColumns(withSource, {"SourceFile"} & 
                    List.RemoveItems(Table.ColumnNames(withSource), 
                    {"SourceFile"}))
        in
            reordered,

    // Add extracted table per file
    AddedIndTables =
        Table.AddColumn(
            VisibleFiles,
            "Upload_Ind_Table",
            each GetUploadIndFromFile([Content], [Name]),
            type table
        ),

    // Keep only files where we actually found a table
    WithNonEmpty =
        Table.SelectRows(
            AddedIndTables,
            each Table.RowCount([Upload_Ind_Table]) > 0
        ),

    // Combine all weekly tables
    Combined =
        if Table.RowCount(WithNonEmpty) = 0
        then EmptyOutput
        else Table.Combine(WithNonEmpty[Upload_Ind_Table]),

    // -----------------------------------------------------------------------
    // LEGACY COMPATIBILITY — HEADER NORMALIZATION (TEMP)
    // 
    // This Rename operation works with the RenameMap above, and exists ONLY to
    // support legacy 2025 validation.  IT MUST BE REMOVED once REFIT match 
    // report templates are in use.
    // -----------------------------------------------------------------------
    
    RenamedLegacyHeaders =
        Table.RenameColumns(
            Combined,
            RenameMap,
            MissingField.Ignore
        ),

    // -----------------------------------------------------------------------
    // LEGACY COMPATIBILITY — ExclScore normalization (TEMP)
    // Legacy match reports encode ExclScore as 1/0.
    // REFIT canonical contract requires logical true/false.
    // THIS NORMALIZATION MUST BE REMOVED once REFIT match templates are live.
    // -----------------------------------------------------------------------

    NormalizedExclScore =
    Table.TransformColumns(
        RenamedLegacyHeaders,
        {
            {
                "ExclScore",
                each
                    if _ = 1 or _ = "1" then true
                    else if _ = 0 or _ = "0" then false
                    else if _ = true or _ = false then _
                    else null,
                type logical
            }
        },
        null,
        MissingField.Ignore
    ),


    // ============================================================
// SECTION 4 — ENFORCE SCHEMA (add missing cols, drop extras, reorder)
// ============================================================

ExistingCols = Table.ColumnNames(NormalizedExclScore),
MissingCols  = List.Difference(ExpectedColumns, ExistingCols),
ExtraCols    = List.Difference(ExistingCols, ExpectedColumns),

AddedMissing =
    List.Accumulate(
        MissingCols,
        NormalizedExclScore,
        (state as table, colName as text) =>
            Table.AddColumn(state, colName, each null)
    ),

RemovedExtra =
    if List.Count(ExtraCols) > 0
    then Table.RemoveColumns(AddedMissing, ExtraCols)
    else AddedMissing,

ReorderedFinal =
    Table.ReorderColumns(RemovedExtra, ExpectedColumns),

    // ============================================================
    // SECTION 5 — RETURN (handles empty-folder case cleanly)
    // ============================================================
    Final =
        if EmptyResult <> null
        then EmptyResult
        else ReorderedFinal
in    
    Final

/* Version History

    vDraft.3 - 2026-01-05
        - Replaced the GetSetting hepler function with qry_Systems_Settings
          to retrieve path and folder data from System_Settings.
    
    vDraft.2 - 2026-01-02
        - Added temp Rename Map to align legacy table headers with the REFIT data
          model.  Needed for REFIT validation only.

    vDraft.1 - 2025-12-22
        - added guard to work with empty folders
*/