# Settings_System_Schema_vDraft.1.md

Scope: System-level configuration for REFIT  
Audience: Future league secretaries, developers, and maintainers  
Excludes: League rules, course rules, blind draw definitions, season structure  
Status: Draft — subject to refinement before first production season

## 1. Purpose & Design Intent

The Settings_System defines how the REFIT application operates, not how the league plays golf.

This distinction is intentional:

- **Settings_System** answers:  *“How does REFIT find files, refresh data, enforce behavior, and control automation?”*

- League rules & **Static_Season_Config** answers:  *“How does the league operate this season?”*

Key design principles:
* Settings are system-facing, not rules-facing
* Settings are stable across seasons
* Settings should change rarely
* Settings should be safe to edit by a future secretary
* Settings must be queryable in a uniform way by Power Query

## 2. Structural Decision (Locked)

### 2.1 Settings WILL be an Excel Table

- Single Excel table: Settings_System
- Located on worksheet: Settings
- Replaces the current “mixed” approach of:
    - Named ranges
    - PQ_Folders-only table
    - Ad-hoc parameters
  
- This simplifies:
    - Discoverability
    - Documentation
    - Version control
    - Validation
    - Query logic

### 2.2 GetSetting() Function (Retained)

- GetSetting() remains the only supported way for Power Query to retrieve settings

- Internally, it will now:
    - Query Settings_System
    - Filter by [SettingName]
    - Return [SettingValue]

- **No query should ever read the Settings table directly.**  This preserves:

    - Encapsulation
    - Backward compatibility
    - Future flexibility (e.g., overrides, defaults, validation)

## 3. Settings_System Table Schema (Draft)
### 3.1 Required Columns (Authoritative)
Column Name  |	Type  |	Description  
-------------------| ---------|-------------------------
SettingName|Text|Unique identifier used by GetSetting()  
SettingValue  | Text  |	Raw value (parsed by consuming logic)  
ValueType   |	Text  |	logical/number/text/path/enum  
Section  |	Text  |	Logical grouping for UI clarity
Description |	Text |	Human-readable explanation
AppliesTo |	Text |	REFIT/PowerQuery/Both
EditableBySecretary |Logical |	TRUE if safe for secretary edits
Notes |Text |Optional clarifications  

## 4. Settings Sections (Draft)

### 4.1 File & Folder Management
SettingName	| ValueType	| Description
---|---|---
matchReportsFolderPath |path |Folder containing incoming Match Reports
stagingFolderPath |path |Optional local staging folder
useLocalStagingFolder |	logical |Toggle staging vs production
archiveFolderPath |	path |	Where | processed reports may be archived

Rationale:
These control how REFIT runs, not league rules.

### 4.2 Refresh & Automation Behavior
SettingName | ValueType | Description
---|---|---
allowEmptyMatchFolder | logical | Allow refresh when no reports exist
refreshMode | enum | Manual / SemiAuto / Auto
enforceSchemaStrictness | logical | Fail refresh on schema mismatch
warnOnMissingWeeks | logical | Warn if expected weeks missing

### 4.3 Validation & Safety Controls
SettingName | ValueType | Description
---|---|---
blockOverwriteOnMismatch | logical | Prevent silent data overwrite
requireCaptainApprovalFlag | logical | Whether approval flags are expected
allowRetroactiveCorrection | logical | Permit historical corrections
correctionRequiresNote | logical | Enforce audit notes

### 4.4 System Metadata
SettingName | ValueType | Description
---|---|---
refitVersion | text | REFIT system version
refitBuildDate | date | Build timestamp
systemOwner | text | Primary maintainer
lastSchemaLock | date | Last schema freeze

## 5. Explicitly NOT in Settings_System

The following are out of scope by design and will live elsewhere:

    ❌ League rules
    ❌ Course definitions (Par / Hcp arrays)
    ❌ Blind Draw player models
    ❌ Season structure (rounds, playoffs, rainouts)
    ❌ Eligibility thresholds tied to league rules

These belong in:

    ➡️ Static_Season_Config (next artifact)
    ➡️ or League Rules–derived tables

## 6. Migration Notes (Future Work)

Not executed yet — documented only:

- Existing named ranges will be migrated into rows
- PQ_Folders will be absorbed into Settings_System
- GetSetting() will be updated to target the new table
- Old access patterns will be deprecated, not broken

## 7. Versioning Strategy

This document: Settings_System_Schema_vDraft.1.md

Draft versions increment during design

Promoted to v1.0 only when:  
- All engines compile
- First full REFIT refresh succeeds
- Summary_New is wired end-to-end

## 8. Next Steps (Confirmed)

1. Review & adjust this schema (you + me)
2. Freeze Settings_System_Schema_vDraft.2
3. Create Static_Season_Config_Schema_vDraft.1
4. Refactor GetSetting() to read from Settings_System
5. Migrate existing parameters