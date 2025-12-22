# Static_Season_Config — Schema (vDraft.1)

## Purpose
Defines season-scoped configuration values used by GetSetting() and downstream
engines.

## Grain
One record per SeasonKey + SettingKey + contextual scope, where scope may be
expressed through Effective dates, Notes, or governed interpretation rules

Secretaries should think of each row as “one fact that is true for the season,"
not as a database table.

## Primary Key / Uniqueness
- PK: <TBD based on current implementation>

## Columns (in order)
| # | Column Name   | Type | Required | Notes / Rules                                        |
|---|---------------|------|----------|------------------------------------------------------|
| 1 | SeasonKey     | text | Y        | Canonical season identifier                          |
| 2 | SettingKey    | text | Y        | Canonical key name used by GetSetting                |
| 3 | SettingValue  | text | Y        | Stored as text; typed at read-time if needed         |
| 4 | ValueType     | text | N        | optional: "number"/"date"/"text"/"logical"/"array"   |
| 5 | EffectiveFrom | date | N        | optional: effective dating                           |
| 6 | EffectiveTo   | date | N        | optional                                             |
| 7 | Source        | text | N        | provenance ("Rules", "League", "Manual")             |
| 8 | Notes         | text | N        | human notes                                          |

## Validation Rules
- SeasonKey must exist in <season dimension/source>
- SettingKey must be in the governed Settings key list (see Settings_System_Schema)
- Duplicate SettingKey values within a SeasonKey are permitted when:
    the setting is defined as multi-valued in Settings_System, or
    the values represent enumerations, scoped variants (e.g., Side), or structured
    facts (e.g., CoursePar by side).
- ValueType must be one of: text|number|date|logical|array
- ValueType array must be a sequence of numbers separated by commas (no spaces)
- Course- and side-specific arrays are expected to migrate to a generalized
  Course* setting pattern if multi-course seasons are introduced

## Versioning
- vDraft.1: initial contract (LOCKED as of 12/21/2025)
