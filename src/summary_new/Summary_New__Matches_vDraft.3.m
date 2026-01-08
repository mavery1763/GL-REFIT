/*
===============================================================================
 Query:      Summary_New__Matches
 Version:    vDraft.3
 Purpose:    
 Author:     Mike Avery
 Created:    2026-01-08
 Source:     Indiv_Results_Staging, Indiv_Results_Holes, (future engines)
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Design Principles:
 - Source(s) (TBD)
 - No file system access
 - No business rule inference
 - Schema must be stable even when no data exists
===============================================================================
*/

let
    // ============================================================
    // SECTION 0 — SEASON CONTEXT (Static_Season_Config)
    // ============================================================

    AllSeasonSettings =
        qry_Static_Season_Config,

    ActiveSeasonRows =
        Table.SelectRows(
            AllSeasonSettings,
            each [SettingKey] = "SeasonStatus"
                and [SettingValue] = "Active"
        ),

    ActiveSeasonCount =
        Table.RowCount(ActiveSeasonRows),

    CurrentSeasonKey =
        if ActiveSeasonCount = 1 then
            ActiveSeasonRows{0}[SeasonKey]
        else if ActiveSeasonCount = 0 then
            error "No Active season found in Static_Season_Config
                (SeasonStatus=Active)."
        else
            error "Multiple Active seasons found in Static_Season_Config.
                Expected exactly 1.",

    SeasonRows =
        Table.SelectRows(
            AllSeasonSettings,
            each [SeasonKey] = CurrentSeasonKey
        ),

    GetSeasonScalar =
        (key as text) as any =>
            let
                rows =
                    Table.SelectRows(
                        SeasonRows,
                        each [SettingKey] = key
                    ),
                n = Table.RowCount(rows)
            in
                if n = 1 then
                    rows{0}[SettingValue]
                else if n = 0 then
                    error "Missing required season setting '" & key & "'."
                else
                    error "Non-scalar season setting '" & key & "'.",

    SeasonYear_Value =
        GetSeasonScalar("SeasonYear"),    
    
    //-----------------------------------------------------------------------
    // 1) Source
    //-----------------------------------------------------------------------
    Source =
        Indiv_Results_Staging,

    //-----------------------------------------------------------------------
    // 1.a) Rename Position to PositionPlayed
    //-----------------------------------------------------------------------

    RenamePosition =
        Table.RenameColumns(Source, {{"Position", "PositionPlayed"}},
            MissingField.Ignore),

    //-----------------------------------------------------------------------
    // 2) Read current CourseName from Static_Season_Config
    //-----------------------------------------------------------------------
    
    Course =
        GetSeasonScalar("CourseName"),

    //-----------------------------------------------------------------------
    // 3) Filter to current season
    //-----------------------------------------------------------------------
    
    CurrentSeason =
        Table.SelectRows(
            RenamePosition,
            each [SeasonYear] = SeasonYear_Value
        ),

    //-----------------------------------------------------------------------
    // 4) Add Course column
    //-----------------------------------------------------------------------

    AddCourse =
            Table.AddColumn(
                CurrentSeason,
                "Course",
                each Course,
                type text
            ),

    //-----------------------------------------------------------------------
    // 4.a) Pull related match data from Indiv_Results_Holes and ???
    //-----------------------------------------------------------------------

    AddMatchCompletedInd =
        Table.AddColumn(
            AddCourse, 
            "MatchCompletedInd",
            each true, // ALL records in Indiv_Results_Staging are completed
            type logical),

    // If column exists upstream, just pass it through
    // If not yet populated, stub as null

    AddForfeitFlag =
        if List.Contains(Table.ColumnNames(AddMatchCompletedInd), "ForfeitFlag")
        then AddMatchCompletedInd
        else
            Table.AddColumn(
                AddMatchCompletedInd,
                "ForfeitFlag",
                each null,
                type logical
            ),

    // AddBlindDrawType - stub now, populated by blind draw engine later

    AddBlindDrawType =
        Table.AddColumn(AddForfeitFlag, "BlindDrawType", each null, type
            text),

    //-----------------------------------------------------------------------
    // 5) Add required schema columns (engine-owned later)
    //-----------------------------------------------------------------------
    
    AddReportingCaptainApproved =
        Table.AddColumn(AddBlindDrawType, "ReportingCaptainApproved", each null,
            type logical),

    AddOpposingCaptainApproved =
        Table.AddColumn(AddReportingCaptainApproved, "OpposingCaptainApproved",
            each null, type logical),

    AddIsCorrection =
        Table.AddColumn(AddOpposingCaptainApproved, "IsCorrection", each null,
            type logical),

    AddCorrectionReason =
        Table.AddColumn(AddIsCorrection, "CorrectionReason", each null,
            type text),

    AddCorrectionEnteredBy =
        Table.AddColumn(AddCorrectionReason, "CorrectionEnteredBy", each null,
            type text),

    AddCorrectionDate =
        Table.AddColumn(AddCorrectionEnteredBy, "CorrectionDate", each null,
            type date),

    AddCaptainReapproved =
        Table.AddColumn(AddCorrectionDate, "CaptainReapproved", each null, 
            type logical),

    AddApprovalStatus =
        Table.AddColumn(AddCaptainReapproved, "ApprovalStatus", each null,
            type text),

    //-----------------------------------------------------------------------
    // 6) Final projection (schema enforcement)
    //-----------------------------------------------------------------------
    Final =
        Table.SelectColumns(
            AddApprovalStatus,
            {
                "SeasonYear",
                "MatchWeek",
                "MatchDate",
                "Team",
                "Opponent",
                "Player",
                "PlayerKey",
                "PositionPlayed",
                "Side",
                "Course",
                "MatchCompletedInd",
                "ForfeitFlag",
                "BlindDrawType",
                "ReportingCaptainApproved",
                "OpposingCaptainApproved",
                "IsCorrection",
                "CorrectionReason",
                "CorrectionEnteredBy",
                "CorrectionDate",
                "CaptainReapproved",
                "ApprovalStatus"
            }
        )
in
    Final

/* Version History

    vDraft.3 - 2026-01-08
    - Added code generated by GPT-5.2 to correct errors in vDraft.3, including...
      > Binding the query to a validated, active season.
      > Added retrieval of SeasonYear and CourseName from season context.
    
    vDraft.2 - 2026-01-02
    - Completed draft wiring, pending additional source confirmation and
        engines implementation

    vDraft.1 - 2025-12-
    - Initial stub version
*/