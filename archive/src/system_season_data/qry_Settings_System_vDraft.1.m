let
    Source =
        Excel.CurrentWorkbook(){[Name="Settings_System"]}[Content],

    Typed =
        Table.TransformColumns(
            Source,
            {
                {
                    "SettingValue",
                    (v, r) =>
                        if r[ValueType] = "number" then Number.From(v)
                        else if r[ValueType] = "logical" then Logical.From(v)
                        else if r[ValueType] = "date" then Date.From(v)
                        else Text.From(v),
                    type any
                }
            }
        )
in
    Typed

/* Version History

    vDraft.1 - 2026-01-03
        - Original version.

*/