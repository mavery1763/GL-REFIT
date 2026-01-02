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
                    "SeasonYear",
                    "Player",
                    "PlayerKey",
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

        AddFields =
            Table.TransformColumns(
                Table.AddColumn(OneRowPerPlayer, "ActiveStatus", each "Active",
                    type text),
                {}
            ),

        AddIsCaptain =
            Table.AddColumn(AddFields, "IsCaptain", each null, type logical),

        AddTee =
            Table.AddColumn(AddIsCaptain, "Tee", each null, type text),

        AddRosterDates =
            Table.AddColumn(AddTee, "RosterStartDate", each null, type date),

        AddRosterEnd =
            Table.AddColumn(AddRosterDates, "RosterEndDate", each null,
                type date),

        AddContact =
            Table.AddColumn(AddRosterEnd, "PlayerPhone", each null, type text),

        AddEmail =
            Table.AddColumn(AddContact, "PlayerEmail", each null, type text),

        Final =
            Table.SelectColumns(
                AddEmail,
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

/* Version History

    vDraft.3 - 2025-12-31 
    - Removed ExclScore code block and added note to clarify handling of score
      exclusions.
    - Removed code to derive and add key fields (SeasonYear, PlayerKey, TeamKey)
      as these are now included in the source table.

    vDraft.2 - 2025-12-

    vDraft.1 - 2025-12-

    v1.0 - 2025-12- - Initial version

*/