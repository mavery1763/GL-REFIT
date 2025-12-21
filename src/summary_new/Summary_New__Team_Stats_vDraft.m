/*
===============================================================================
 Query:      Summary_New__Team_Stats
 Version:    v1.0 (Production-intent)
 Purpose:    
 Author:     Mike Avery
 Created:    2025-12-18
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
// Draft code (below) used until engines are in place
/*
===============================================================================
 Query:      Summary_New__Team_stats
 Status:     DRAFT (Schema stub) ELIMINATED in vDraft.1 of schema
 Purpose:    
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Notes:
 - No business logic
 - No inference
 - Single-row table
 - Populated later by engines
 - Removal reason: Redundant with Summary_New__Teams and Summary_New__Matches
 - Replacement: Use Summary_New__Teams for season totals
 - Status: Deprecated (do not implement)

===============================================================================
*/
/*
let
    Schema =
        #table(
            type table[
                SeasonYear               = number,
                Team                     = text,
                MatchesPlayed            = number,
                TeamPointsTotal          = number,
                AvgTeamNet               = number,
                LowTeamNet               = number,
                HighTeamPoints           = number,
                BirdiesTotal             = number,
                EaglesTotal              = number,
                DoubleEaglesTotal        = number
            ],
            {}
        )
in
    Schema
