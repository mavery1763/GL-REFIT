/*
======================================================================

Query:        qry_Settings_System

Version:      v1.0
Status:       LOCKED
Last updated: 2026-01-24
Tag:          v1.0-pre-engine-audit

======================================================================

*/let
    Source =
        Excel.CurrentWorkbook(){[Name="Settings_System"]}[Content],

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
                    else if vt = "logical" then Logical.FromText(Text.Upper
                        (Text.From(v)))
                    else if vt = "date" then Date.From(v)
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
                "SettingName",
                "SettingValue",
                "ValueType",
                "Section",
                "Description",
                "AppliesTo",
                "EditableBySecretary",
                "Notes"
            },
            MissingField.Ignore
        )

in
    FinalOrdered

/* Version History

    v1.0 - 2026-01-24
        - LOCKED version after pre-engine audit.
    
    vDraft.2 - 2026-01-04
        - Changed to Table.AddColumn with defensive typing block.
    
    vDraft.1 - 2026-01-03
        - Original version.

*/