(key as text) as any =>
let
    cfg = qry_Settings_System,
    row = cfg{[SettingKey = key]},
    val = row[SettingValue]
in
    val

/* Version History
    vDraft.1 - 2026-01-03
        - Original version.

*/