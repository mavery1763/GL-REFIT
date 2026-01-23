/*
===============================================================================
 Query:      Summary_New__Handicaps
 Version:    vDraft.3
 Purpose:    
 Author:     Mike Avery
 Created:    2025-12-27
 Source:     Handicap_Engine (future), Player_Master (future),
             Static_Season_Config, Summary_New__Player_Stats
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Design Principles:
 - Source(s) (TBD)
 - No file system access
 - No business rule inference
 - Schema must be stable even when no data exists
-------------------------------------------------------------------------------
 Notes:
 - Section D in schema
 - No business logic
 - No inference
 - Populated later by engines
===============================================================================
*/

let
    //-----------------------------------------------------------------------
    // 1) Placeholder source (no Player_Master yet)
    //-----------------------------------------------------------------------
    Source =
        #table(
            type table[
                SeasonYear = number,
                Player = text,
                PlayerKey = text,
                IsActive = logical
            ],
            {}
        ),

    //-----------------------------------------------------------------------
    // 4) Add required schema columns (engine-owned later)
    //-----------------------------------------------------------------------
    AddEstablishedHcp =
        Table.AddColumn(AddSeasonYear, "EstablishedHcp", each null, type logical),

    AddHandicap =
        Table.AddColumn(AddEstablishedHcp, "Handicap", each null, type number),

    AddHandicapCalcBasis =
        Table.AddColumn(AddHandicap, "HandicapCalcBasis", each null, type text),

    AddHandicapRounds =
        Table.AddColumn(AddHandicapCalcBasis, "HandicapRounds", each null, type number),

    AddSeasonRoundsPlayed =
        Table.AddColumn(AddHandicapRounds, "SeasonRoundsPlayed", each null, type number),

    //-----------------------------------------------------------------------
    // 5) Final schema projection
    //-----------------------------------------------------------------------
    Final =
        Table.SelectColumns(
            AddSeasonRoundsPlayed,
            {
                "SeasonYearApplied",
                "Player",
                "PlayerKey",
                "EstablishedHcp",
                "Handicap",
                "HandicapCalcBasis",
                "HandicapRounds",
                "SeasonRoundsPlayed"
            }
        )
in
    Final
