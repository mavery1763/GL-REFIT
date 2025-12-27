let
    /*
    ===============================================================================
    Query:      Summary_New__Teams
    Version:    vDraft.3
    Purpose:    
    Author:     Mike Avery
    Created:    2025-12-26
    Source:     Team_Results_Staging, Static_Season_Config, Team_Master
    Layer:      Summary_New
    -------------------------------------------------------------------------------
    Design Principles:
    - Source(s) Team_Results_Staging, Static_Season_Config, Team_Master
    - No file system access
    - No business rule inference
    - Schema must be stable even when no data exists
    - Team points per match currently hardcoded; need to add to Static_Season_Config
    - Team_Master currently does not exist
    - CurrentlyInPlayoffs does not include rule-specified tie breakers yet
    ===============================================================================

    ***************************************************************************
        Pull in the required data using the Team_Results_Staging query
    ***************************************************************************
    */ 
    Source = Team_Results_Staging,

        SelectCols =
            Table.SelectColumns(
                Source,
                {
                    "Team",
                    "TeamKey",
                    "Year",
                    "TmNet",
                    "TmTotPoints"
                }
            ),
    /*
    ***************************************************************************
        Filter to include only the records matching the current SeasonYear
    ***************************************************************************
    */
        SeasonConfig =
            Excel.CurrentWorkbook(){[Name = "Static_Season_Config"]}[Content],

        
        SeasonYear =
            Number.From(
                SeasonConfig{[SettingKey = "SeasonYear"]}[SettingValue]
            ),

        CurrentTeamsData = 
            Table.SelectRows(SelectCols,
                each [Year] = SeasonYear),
    /*
    ***************************************************************************
        Add columns and calculate win, tie or loss for each team match
    ***************************************************************************
    */
        AddWin =
            Table.AddColumn(
                CurrentTeamsData,
                "Win",
                each if [TmTotPoints] > 42 then 1 else 0,
                type number
            ),

        AddTie =
            Table.AddColumn(
                AddWin,
                "Tie",
                each if [TmTotPoints] = 42 then 1 else 0,
                type number
            ),

        AddLoss =
            Table.AddColumn(
                AddTie,
                "Loss",
                each if [TmTotPoints] < 42 then 1 else 0,
                type number
            ),
    /*
    ***************************************************************************
        Aggregate results by team
    ***************************************************************************
    */
        AggTeamData = 
            Table.Group(
                AddLoss,
                {   "Team",
                    "TeamKey"},
                {
                    {"TeamPoints", each List.Sum([TmTotPoints]),
                        type number},
                    {"LowTeamNet", each List.Min([TmNet]), type number},
                    {"HighTeamPoints", each List.Max([TmTotPoints]),
                        type number},
                    {"TeamWins", each List.Sum([Win]), type number},
                    {"TeamLosses", each List.Sum([Loss]), type number},
                    {"TeamTies", each List.Sum([Tie]), type number}
                }
            ),
    /*
    ***************************************************************************
        Sort aggregated team data by TeamPoints
    ***************************************************************************
    */
        SortLatest =
            Table.Sort(
                AggTeamData,
                    {{"TeamPoints", Order.Descending}}
                ),
    /*
    ***************************************************************************
        Add column CurrentlyInPlayoffs based on teams' TeamPoints ranking
    ***************************************************************************
    */
        Top4 =
            Table.FirstN(SortLatest, 4),

        Top4WithFlag =
            Table.AddColumn(Top4, "CurrentlyInPlayoffs", each true, type logical),

        RestWithFlag =
            Table.AddColumn(
                Table.Skip(SortLatest, 4),
                "CurrentlyInPlayoffs",
                each false,
                type logical
            ),

        WithPlayoffFlag =
            Table.Combine({Top4WithFlag, RestWithFlag}),
    /*
    ***************************************************************************
        Add column Captain from Team_Master (future)
    ***************************************************************************
    */
        AddCaptain =
            Table.AddColumn(WithPlayoffFlag, "Captain", each null, type text),
                // pending creation of Team_Master
    /*
    ***************************************************************************
        Rename the Year column to SeasonYear
    ***************************************************************************
    */
    //    AddSeasonYear =
            Table.AddColumn(
                AddCaptain,
                "SeasonYear",
                each SeasonYear,
                type number
             ),
    /*
    ***************************************************************************
        Output the final Summary_New__Teams table
    ***************************************************************************
    */
    Final =
        Table.SelectColumns(
            AddSeasonYear,
            {
                "SeasonYear",
                "Team",
                "TeamKey",
                "Captain",
                "TeamPoints",
                "TeamWins",
                "TeamLosses",
                "TeamTies",
                "LowTeamNet",
                "HighTeamPoints",
                "CurrentlyInPlayoffs"
            }
        )
in
Final