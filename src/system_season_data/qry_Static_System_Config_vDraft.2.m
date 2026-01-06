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

    vDraft.2 - 2026-01-04
        - Changed to Table.AddColumn with defensive typing block.
    
    vDraft.1 - 2026-01-03
        - Original version.

*/