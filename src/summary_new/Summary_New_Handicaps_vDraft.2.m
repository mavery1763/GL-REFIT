/*
===============================================================================
 Query:      Summary_New__
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
 Query:      Summary_New__Handicaps
 Version:    vDraft.2
 Status:     DRAFT (Schema stub)
 Purpose:    
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Notes:
 - Section D in schema
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
                SeasonYear           = number,
                Player               = text,
                PlayerKey            = text,
                EstablishedHcp       = logical,
                Handicap             = number,
                HandicapCalcBasis    = text,
                HandicapRounds       = number,
                SeasonRoundsPlayed   = number
            ],
            {}
        )
in
    Schema
