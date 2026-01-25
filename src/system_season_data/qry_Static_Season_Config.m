/*
===============================================================================
 Query:        qry_Static_Season_Config
 Version:      v1.0
 Status:       LOCKED
 Last updated: 2026-01-24
 Tag:          v1.0-pre-engine-audit
-------------------------------------------------------------------------------
 Purpose:    Primary means of loading Static Season Configuration data into other
             GL-REFIT queries and engines.
 Author:     Mike Avery
 Created:    2026-01-08
 Source:     League secretary and formal League rules document.
 Layer:      
-------------------------------------------------------------------------------
 Design Principles:
 - SeasonKey is the canonical identifier used to scope all season-specific data
   and configuration within REFIT.
 - SeasonYear is a season attribute used for reporting and presentation. While
   SeasonYear may equal SeasonKey in many cases, this is not required and must
   not be relied upon for scoping or joins.
===============================================================================
*/

let
    Source =
        Excel.CurrentWorkbook(){[Name="Static_Season_Config"]}[Content],

    WithTypedValue =
        Table.AddColumn(
            Source,
            "TypedValue",
            each
                let
                    v  = [SettingValue],
                    vt = Text.Lower(Text.Trim(Text.From([ValueType])))
                in
                    try
                        if v = null or Text.Trim(Text.From(v)) = "" then null
                        else if vt = "number" then Number.From(v)
                        else if vt = "logical" then Logical.FromText(Text.Upper(Text.From(v)))
                        else if vt = "date" then Date.From(v)
                        else if vt = "array" then Json.Document(v)
                        else Text.From(v)
                    otherwise null,
            type any
        ),

    RemovedOriginal =
        Table.RemoveColumns(
            WithTypedValue,
            {"SettingValue"}
        ),

    Final =
        Table.RenameColumns(
            RemovedOriginal,
            {{"TypedValue","SettingValue"}}
        ),

    FinalOrdered =
        Table.ReorderColumns(
            Final,
            {
                "SeasonKey",
                "SettingKey",
                "SettingValue",
                "ValueType",
                "EffectiveFrom",
                "EffectiveTo",
                "Source",
                "Notes"
            },
            MissingField.Ignore
        )

in
    FinalOrdered

/* Version History

    v1.0 - 2026-01-24
        - LOCKED version after pre-engine audit.
    
    vDraft.3 - 2026-01-08
        - Added header comment block.    
    
    vDraft.2 - 2026-01-04
        - Changed to Table.AddColumn with defensive typing block.
    
    vDraft.1 - 2026-01-03
        - Original version.

*/