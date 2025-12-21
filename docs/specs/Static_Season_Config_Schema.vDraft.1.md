# Static_Season_Config — Schema (vDraft.1)

## Purpose
Defines season-scoped configuration values used by GetSetting() and downstream
engines.

## Grain
One record per (SeasonKey, SettingKey) OR one record per Season (wide format).
> NOTE: This must match the implemented table. No changes unless explicitly agreed.

## Primary Key / Uniqueness
- PK: <TBD based on current implementation>

## Rows (in order)
| # | Row Name      | Type | Required | Notes / Rules                                |
|---|---------------|------|----------|----------------------------------------------|
| 1 | SeasonKey     | text | Y        | Canonical season identifier                  |
| 2 | SettingName   | text | Y        | Canonical key name used by GetSetting        |
| 3 | Value         | text | Y        | Stored as text; typed at read-time if needed |
| 4 | ValueType     | text | N        | optional: "number"/"date"/"text"/"logical"   |
| 5 | EffectiveFrom | date | N        | optional: effective dating                   |
| 6 | EffectiveTo   | date | N        | optional                                     |
| 7 | Source        | text | N        | provenance ("Rules", "League", "Manual")     |
| 8 | Notes         | text | N        | human notes                                  |

## Validation Rules
- SeasonKey must exist in <season dimension/source>
- SettingKey must be in the governed Settings key list (see Settings_System_Schema)
- For duplicate SettingKey within a SeasonKey: <rule>
- ValueType must be one of: <rule>

## Versioning
- vDraft.1: initial contract
