/*
===============================================================================
 Query:      Summary_New__Players
 Version:    vDraft.3
 Purpose:    
 Author:     Mike Avery
 Created:    2025-12-22
 Source:     Indiv_Results_Staging
 Layer:      Summary_New
-------------------------------------------------------------------------------
 Design Principles:
 - Source(s) Indiv_Results_Staging, Summary_New__Season
 - No file system access
 - No business rule inference
 - Schema must be stable even when no data exists
===============================================================================
*/

let
    Source = Indiv_Results_Staging,

        SelectCols =
            Table.SelectColumns(
                Source,
                {
                    "Player",
                    "Team",
                    "MatchWeek",
                    "MatchDate"
                }
            ),

        SortLatest =
            Table.Sort(
                SelectCols,
                {
                    {"Player", Order.Ascending},
                    {"MatchWeek", Order.Descending},
                    {"MatchDate", Order.Descending}
                }
            ),

        OneRowPerPlayer =
            Table.Distinct(
                SortLatest,
                {"Player"}
            ),
        
        AddPlayerKey =
            Table.AddColumn(
                OneRowPerPlayer,
                "PlayerKey",
                each Text.Upper(Text.Trim([Player])),
                type text
            ),

        AddFields =
            Table.TransformColumns(
                Table.AddColumn(AddPlayerKey, "ActiveStatus", each "Active", type text),
                {}
            ),

        AddIsCaptain =
            Table.AddColumn(AddFields, "IsCaptain", each null, type logical),

        AddTee =
            Table.AddColumn(AddIsCaptain, "Tee", each null, type text),

        AddRosterDates =
            Table.AddColumn(AddTee, "RosterStartDate", each null, type date),

        AddRosterEnd =
            Table.AddColumn(AddRosterDates, "RosterEndDate", each null, type date),

        AddContact =
            Table.AddColumn(AddRosterEnd, "PlayerPhone", each null, type text),

        AddEmail =
            Table.AddColumn(AddContact, "PlayerEmail", each null, type text),
        
        SeasonConfig =
            Excel.CurrentWorkbook(){[Name = "Static_Season_Config"]}[Content],

        
        SeasonYear =
            Number.From(
                SeasonConfig{[SettingKey = "SeasonYear"]}[SettingValue]
            ),

        AddSeasonYear =
            Table.AddColumn(
                AddEmail,
                "SeasonYear",
                each SeasonYear,
                type number
            ),

        Final =
            Table.SelectColumns(
                AddSeasonYear,
                {
                    "SeasonYear",
                    "Player",
                    "PlayerKey",
                    "Team",
                    "ActiveStatus",
                    "IsCaptain",
                    "Tee",
                    "RosterStartDate",
                    "RosterEndDate",
                    "PlayerPhone",
                    "PlayerEmail"
                }
            )

in
    Final

