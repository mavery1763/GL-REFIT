
## Configuration Ownership Rules (v1.0)

If a value can change season-to-season, it belongs in *Static_Season_Config*

If it defines how the GL-REFIT system operates across seasons, it belongs in 
*Settings_System*

## Read-Only Contract

Both `Settings_System` and `Static_Season_Config` are **read-only inputs**
to the REFIT dataflow.

- They MUST NOT be mutated by Power Query logic
- They MUST NOT be derived from match data
- They MAY be edited manually by the League Secretary
- They MAY be versioned season-to-season

Any logic that *interprets* these values belongs downstream
(e.g., Engines, Summary tables), not here.

## Canonical Access Pattern

REFIT queries MUST access configuration data ONLY via the following queries:

- `qry_Settings_System`
- `qry_Static_Season_Config`

Direct calls such as:
- `Excel.CurrentWorkbook(){[Name="Static_Season_Config"]}`
- Inline `GetSetting()` logic

are **not permitted** outside these queries.

This ensures:
- consistent refresh behavior
- centralized validation
- auditable configuration usage

## SeasonYear as Primary Scope Key

`SeasonYear` is the primary scoping key for all season-specific data.

Rules:
- Every season-scoped table MUST include `SeasonYear`
- Joins across season-scoped tables MUST include `SeasonYear`
- No query may infer SeasonYear from dates or filenames

## Array-Valued Settings

Some configuration values are intentionally stored as arrays
(e.g., hole-level par, handicap, blind draw scoring).

These arrays:
- are ordered
- are side-specific where applicable
- MUST NOT be exploded at the configuration layer
- MAY be interpreted downstream by Engines or Hole-level logic

## Change Tracking

Changes to configuration values SHOULD be tracked via:
- EffectiveFrom / EffectiveTo (season data)
- Git history (structural changes)
- Optional Notes column (reason for change)

REFIT does not infer historical intent from configuration tables.

## Access to Table Data

Only *SettingKey*, *SettingValue*, and *ValueType* are part of the REFIT
contract.  All other columns are informational and MUST NOT be referenced by
queries.

## Change Log
- 2026-01-04 - added section
