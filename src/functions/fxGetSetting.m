/*
======================================================================

Function:     fxGetSetting

Version:      v1.0
Status:       LOCKED
Last updated: 2026-01-24
Tag:          v1.0-pre-engine-audit

======================================================================
*/

(key as text) as any =>
let
    cfg = qry_Settings_System,
    row = cfg{[SettingKey = key]},
    val = row[SettingValue]
in
    val

/* Version History
    
    v1.0 - 2026-01-24
        - LOCKED version after pre-engine audit.
        
    vDraft.1 - 2026-01-03
        - Original version.

*/