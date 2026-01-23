/*
===============================================================================
 Query:        Indiv_Results_Holes
 Version:      v1.0
 Status:       Production-intent
 Author:       GL-REFIT
 Last Updated: 2025-12-XX

 Purpose:
   Explodes player-round records into a normalized hole-level fact table
   (one row per player per hole), supporting advanced analytics:
     - Hole difficulty modeling
     - Birdie/Eagle frequency
     - Blind Draw logic
     - Future pairing optimization

 Grain:
   Player × Week × Hole

 Source:
   Upload_Indiv_Raw (QUERY, not worksheet)

 Design Rules:
   - No business logic beyond normalization
   - No assumptions about completed holes
   - Missing hole values remain null
===============================================================================
*/

let
    //
    // 1. SOURCE FROM RAW QUERY (NOT WORKSHEET)
    //
    Source = Upload_Indiv_Raw,

    //
    // 2. BASE TYPE COERCION FOR ID FIELDS
    //
    TypedBase =
        Table.TransformColumnTypes(
            Source,
            {
                {"SourceFile", type text},
                {"Week", Int64.Type},
                {"Date", type date},
                {"Side", type text},
                {"Team", type text},
                {"Opponent", type text},
                {"Position", Int64.Type},
                {"Player", type text}
            }
        ),

    //
    // 3. CREATE ONE RECORD PER HOLE (1–18)
    //
    AddedHoleRecords =
        Table.AddColumn(
            TypedBase,
            "HoleRecord",
            each
                let
                    row   = _,
                    holes = {1..18}
                in
                    List.Transform(
                        holes,
                        (h) =>
                            let
                                hTxt = Text.PadStart(Text.From(h), 2, "0")
                            in
                                [
                                    Hole        = h,
                                    Score       = Record.FieldOrDefault(row, "Score_" & hTxt, null),
                                    Par         = Record.FieldOrDefault(row, "Par_" & hTxt, null),
                                    Hcp         = Record.FieldOrDefault(row, "Hcp_" & hTxt, null),
                                    NetScore    = Record.FieldOrDefault(row, "NetScore_" & hTxt, null),
                                    Bird        = Record.FieldOrDefault(row, "Bird_" & hTxt, null),
                                    Eagle       = Record.FieldOrDefault(row, "Eagle_" & hTxt, null),
                                    DoubleEagle = Record.FieldOrDefault(row, "DoubleEagle_" & hTxt, null),
                                    Points      = Record.FieldOrDefault(row, "Points_" & hTxt, null)
                                ]
                    ),
            type list
        ),

    //
    // 4. EXPAND TO ROWS
    //
    ExpandedHoleList =
        Table.ExpandListColumn(AddedHoleRecords, "HoleRecord"),

    ExpandedHoleFields =
        Table.ExpandRecordColumn(
            ExpandedHoleList,
            "HoleRecord",
            {
                "Hole",
                "Score",
                "Par",
                "Hcp",
                "NetScore",
                "Bird",
                "Eagle",
                "DoubleEagle",
                "Points"
            }
        ),

    //
    // 5. SELECT FINAL FACT TABLE COLUMNS
    //
    Final =
        Table.SelectColumns(
            ExpandedHoleFields,
            {
                "SourceFile",
                "Week",
                "Date",
                "Side",
                "Team",
                "Opponent",
                "Position",
                "Player",
                "Hole",
                "Score",
                "Par",
                "Hcp",
                "NetScore",
                "Bird",
                "Eagle",
                "DoubleEagle",
                "Points"
            }
        )

in
    Final
