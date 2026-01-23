(settingName as text) as any =>
let
    Source = Settings_System,
    Match =
        Table.SelectRows(
            Source,
            each [SettingName] = settingName
        ),
    Value =
        if Table.RowCount(Match) = 0
        then error "Setting not found: " & settingName
        else Match{0}[SettingValue]
in
    Value