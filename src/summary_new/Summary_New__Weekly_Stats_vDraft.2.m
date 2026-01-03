let
/*
===============================================================================
 Query:      Summary_New__Weekly_Stats
 Version:    vDraft.2
 Purpose:    
 Author:     Mike Avery
 Created:    2026-01-02
 Source:     TBD
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Design Principles:
 - Source(s) (TBD)
 - No file system access
 - No business rule inference
 - Schema must be stable even when no data exists
===============================================================================
*/
    //-----------------------------------------------------------------------
    // 1) Source
    //-----------------------------------------------------------------------
    Source =
        Indiv_Results_Staging,

    //-----------------------------------------------------------------------
    // 2) Filter to latest week's match data
    //-----------------------------------------------------------------------
    LatestMatchDate = List.Max(Source[MatchDate]),
    FilteredSource = Table.SelectRows(
        Source,
        each [MatchDate] = LatestMatchDate
    ),
    
    //-----------------------------------------------------------------------
    // 3) Final projection (schema enforcement)
    //-----------------------------------------------------------------------
    Final =
        Table.SelectColumns(
            FilteredSource,
            {
                "SeasonYear",
                "MatchWeek",
                "MatchDate",
                "Player",
                "PlayerKey",
                "Gross",
                "Net",
                "PointsTotal",
                "BirdiesTotal",
                "EaglesTotal",
                "DoubleEaglesTotal",
                "ExclScore"
            }
        )
in
    Final

/* Version History

    vDraft.2 - 2026-01-02
        - Completed wiring per design

    vDraft.1 - 2025-12-
        - Initial version
*/