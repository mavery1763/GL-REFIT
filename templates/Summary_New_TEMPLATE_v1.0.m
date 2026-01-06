/*
===============================================================================
 Query:      Summary_New__<Name>
 Version:    v1.0
 Purpose:    <One-line description of what this summary represents>
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Design Rules:
 - Read-only
 - No file system access
 - Empty-input safe
 - No direct Excel.CurrentWorkbook() access
 - Configuration accessed ONLY via qry_Settings_System and
   qry_Static_Season_Config
===============================================================================
*/

let
    // ================================================================
    // 0) SOURCE TABLES (already empty-safe upstream)
    // ================================================================
    Source =
        <Primary_Staging_or_Analytics_Query>,

    // ================================================================
    // 1) SYSTEM / SEASON CONFIG ACCESS (ROW-COUNT SAFE)
    // ================================================================

    SystemSettings =
        qry_Settings_System,

    SeasonConfig =
        qry_Static_Season_Config,

    // ---- SeasonYear (scalar, required) ----
    SeasonYear =
        let
            rows =
                Table.SelectRows(
                    SeasonConfig,
                    each [SettingKey] = "SeasonYear"
                )
        in
            if Table.RowCount(rows) = 1
            then rows{0}[SettingValue]
            else error "Expected exactly one SeasonYear row in Static_Season_Config",

    // ================================================================
    // 2) EARLY EMPTY SHORT-CIRCUIT
    // ================================================================
    EmptyResult =
        if Table.IsEmpty(Source)
        then #table(<ExpectedColumns>, {})
        else null,

    // ================================================================
    // 3) CORE TRANSFORM LOGIC
    //    (joins, groupings, calculations)
    // ================================================================

    Working =
        if EmptyResult <> null
        then EmptyResult
        else
            <Main transformation logic here>,

    // ================================================================
    // 4) FINAL PROJECTION (schema lock)
    // ================================================================
    Final =
        Table.SelectColumns(
            Working,
            <ExpectedColumns>,
            MissingField.UseNull
        )

in
    Final
/* Version History
    
    v1.0 - 2026-01-06
        - Original versioned template creation.
*/