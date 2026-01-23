let
    /***********************************************************************
      Upload_Team_Raw — v1.0 (production-intent)
      Purpose:
        - Ingest the Upload_Team table from weekly Match Report workbooks
        - Enforce a stable output schema (ExpectedColumns)
        - Be safe when the target folder is empty (return 0-row table, no errors)
        - No Transform File artifacts; robust to missing/extra columns

      Dependencies:
        - GetSetting() function exists in this workbook
        - Settings named ranges:
            useLocalStagingFolder
            matchReportsFolderPath
            stagingFolderPath

      Output:
        - Table with columns exactly matching ExpectedColumns (order enforced)
        - One row per team per match report (as produced by Upload_Team table)
    ***********************************************************************/

    //=====================================================================
    // 0) SETTINGS
    //=====================================================================
    UseStagingRaw = try GetSetting("useLocalStagingFolder") otherwise false,
    UseStagingBool =
        (Value.Is(UseStagingRaw, type logical) and UseStagingRaw = true)
        or
        (Value.Is(UseStagingRaw, type text) and Text.Upper(UseStagingRaw) = "TRUE"),

    MainFolder    = GetSetting("matchReportsFolderPath"),
    StagingFolder = GetSetting("stagingFolderPath"),
    FolderToUse   = if UseStagingBool then StagingFolder else MainFolder,

    //=====================================================================
    // 1) CANONICAL OUTPUT SCHEMA 
    //=====================================================================
    ExpectedColumns =
    {
        "SourceFile","Year","Week","Date","Side","Team","Opponent","TmNet",
        "TmNetPoints","TmTotPoints","MatchCompleted","ForfeitFlag"        
    },

    // Helper: create an empty table with the canonical schema
    EmptyWithSchema =
        let
            t = #table(ExpectedColumns, {})
        in
            t,

    //=====================================================================
    // 2) LOAD FILES (SAFE)
    //=====================================================================
    FilesRaw      = try Folder.Files(FolderToUse) otherwise #table({}, {}),
    FilesBuffered = Table.Buffer(FilesRaw),

    VisibleFiles =
        if Table.IsEmpty(FilesBuffered)
        then FilesBuffered
        else Table.SelectRows(FilesBuffered, each [Attributes]?[Hidden]? <> true),

    WithSourceName =
        if Table.IsEmpty(VisibleFiles)
        then VisibleFiles
        else Table.RenameColumns(VisibleFiles, {{"Name", "Source.Name"}}),

    //=====================================================================
    // 3) EXTRACT Upload_Team TABLE FROM EACH WORKBOOK (NO TRANSFORM FILE)
    //=====================================================================
    GetUploadTeamTable =
        (content as binary) as table =>
            let
                wb      = Excel.Workbook(content, true),
                // We look for a table named exactly "Upload_Team"
                hits    = Table.SelectRows(wb, each [Kind] = "Table" and [Name] = "Upload_Team"),
                result  = if Table.IsEmpty(hits) then #table({}, {}) else hits{0}[Data]
            in
                result,

    AddedTeamTable =
        if Table.IsEmpty(WithSourceName)
        then WithSourceName
        else Table.AddColumn(WithSourceName, "TeamTable", each GetUploadTeamTable([Content]), type table),

    // Keep only rows where Upload_Team existed and had some columns (even if 0 rows)
    NonNullTeamTables =
        if Table.IsEmpty(AddedTeamTable)
        then AddedTeamTable
        else Table.SelectRows(
            AddedTeamTable,
            each Value.Is([TeamTable], type table) and Table.ColumnCount([TeamTable]) > 0
        ),

    //=====================================================================
    // 4) EMPTY-FOLDER / NO-TABLE SAFETY NET
    //    If no files or none contain Upload_Team => return empty canonical schema
    //=====================================================================
    HasAnyDataSource =
        not Table.IsEmpty(NonNullTeamTables),

    OutputIfNone =
        if not HasAnyDataSource then EmptyWithSchema else null,

    //=====================================================================
    // 5) EXPAND TEAMTABLE (DYNAMIC COLUMNS)
    //=====================================================================
    FirstTeamTable =
        if HasAnyDataSource
        then NonNullTeamTables{0}[TeamTable]
        else #table({}, {}),

    TeamColNames =
        if HasAnyDataSource
        then Table.ColumnNames(FirstTeamTable)
        else {},

    Expanded =
        if not HasAnyDataSource
        then OutputIfNone
        else Table.ExpandTableColumn(NonNullTeamTables, "TeamTable", TeamColNames, TeamColNames),

    //=====================================================================
    // 6) CLEAN / STANDARDIZE (SourceFile)
    //=====================================================================
    // Keep only Source.Name for provenance; strip file metadata columns if present
    StripMeta =
        if not HasAnyDataSource
        then Expanded
        else
            let
                metaToRemove = List.Intersect({
                    {"Extension","Date accessed","Date modified","Date created","Folder Path","Attributes","Content"},
                    Table.ColumnNames(Expanded)
                }),
                cleaned = Table.RemoveColumns(Expanded, metaToRemove)
            in
                cleaned,

    // Rename Source.Name -> SourceFile (REFIT standard)
    WithSourceFile =
        if not HasAnyDataSource
        then StripMeta
        else
            if List.Contains(Table.ColumnNames(StripMeta), "Source.Name")
            then Table.RenameColumns(StripMeta, {{"Source.Name", "SourceFile"}})
            else StripMeta,

    //=====================================================================
    // 7) ENFORCE CANONICAL OUTPUT SCHEMA (ADD MISSING, DROP EXTRA, ORDER)
    //=====================================================================
    ExistingCols = Table.ColumnNames(WithSourceFile),

    AddMissing =
        List.Accumulate(
            ExpectedColumns,
            WithSourceFile,
            (state as table, col as text) =>
                if List.Contains(Table.ColumnNames(state), col)
                then state
                else Table.AddColumn(state, col, each null)
        ),

    DropExtras =
        let
            keep = ExpectedColumns,
            cols = Table.ColumnNames(AddMissing),
            extras = List.Difference(cols, keep),
            trimmed = if List.IsEmpty(extras) then AddMissing else Table.RemoveColumns(AddMissing, extras)
        in
            trimmed,

    Reordered =
        Table.ReorderColumns(DropExtras, ExpectedColumns)

in
    Reordered
