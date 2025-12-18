/*
===============================================================================
 Query:      Summary_New__Season
 Version:    v1.0 (Production-intent)
 Purpose:    Metadata for TMMNGL and current season of play
 Author:     Mike Avery
 Created:    2025-12-18
 Source:     Settings, static season config
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Design Principles:
 - Source from Settings table and static season config (TBD)
 - No file system access
 - No business rule inference
 - Schema must be stable even when no data exists
===============================================================================
*/
// Draft code (below) used until engines are in place
/*
===============================================================================
 Query:      Summary_New__Season
 Status:     DRAFT (Schema stub)
 Purpose:    Canonical season-level metadata for REFIT
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Notes:
 - No business logic
 - No inference
 - Single-row table
 - Populated later by engines
===============================================================================
*/

let
    Schema =
        #table(
            type table[
                LeagueName               = text,
                SeasonYear               = number,
                MatchWeek                = number,
                MatchDate                = date,
                SeasonRoundsPlanned      = number,
                Eligibility_MinPctRounds = number,
                SeasonStatus             = text
            ],
            {}
        )
in
    Schema
