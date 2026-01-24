# Static_Season_Config — Schema
  
**Version:** vDraft.3
**Status:** LOCKED
**Last updated:** 2026-01-23
**Tag:** TBD

## Purpose
Defines season-scoped configuration values used by qry_Static_Season_Config and
downstream engines.

## Grain
One record per SeasonKey + SettingKey + contextual scope, where scope may be
expressed through Effective dates, Notes, or governed interpretation rules

Secretaries should think of each row as “one fact that is true for the season,"
not as a database table.

## Primary Key / Uniqueness
- *SeasonKey* is the canonical identifier used to scope all season-specific data
  and configuration within REFIT.  (*SeasonYear* is a season attribute used for
  reporting and presentation. While SeasonYear may equal SeasonKey in many
  cases, this is not required and must not be relied upon for scoping or joins.)

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
- At any point in time, exactly one season must be marked as SeasonStatus =
  Active
  in Static_Season_Config.  *REFIT will throw an error* if zero or multiple
  Active seasons are detected. This is a deliberate design choice to ensure
  deterministic Summary outputs.
- SettingKey must be in the governed Settings key list (see
  Settings_System_Schema)
- Duplicate SettingKey values within a SeasonKey are permitted when:
    the setting is defined as multi-valued in Settings_System, or
    the values represent enumerations, scoped variants (e.g., Side), or
    structured     facts (e.g., CoursePar by side).
- ValueType must be one of: text|number|date|logical|array
- ValueType array must be a sequence of numbers separated by commas (no spaces)
- Course- and side-specific arrays are expected to migrate to a generalized
  Course* setting pattern if multi-course seasons are introduced

## SeasonKey vs SeasonYear (v1.0 semantics)

- SeasonKey is the canonical scope identifier used throughout GL-REFIT to filter/
  join season-scoped configuration and season-scoped data.
- SeasonYear is a season attribute used for reporting/presentation. It is stored
  as a season-scoped scalar setting in Static_Season_Config (i.e., 
  SettingKey="SeasonYear").
- While SeasonKey and SeasonYear may often be equal, this is not required and
  must not be relied upon for scoping or joins. All season scoping must use
  SeasonKey.
- REFIT enforces determinism by requiring exactly one season be marked
  SeasonStatus="Active" at a time.

## Versioning
- vDraft.3 2026-01-23
    Added section clarifying SeasonKey vs SeasonYear

- vDraft.2 2026-01-08
    Updated documentation to align with query operation and overall system 
    operation at the current time
 
- vDraft.1: initial contract (LOCKED as of 12/21/2025)
