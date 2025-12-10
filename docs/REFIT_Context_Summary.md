REFIT Project — Context Summary
Project Purpose

REFIT modernizes the Timken/Metallus Monday Night Golf League scoring system by:

Automating ingestion of weekly match reports

Using a formal Raw → Staging → Analytics data model

Eliminating legacy Excel formulas and manual corrections

Enforcing rule transparency and reproducibility

Enabling deeper golf analytics and trend reporting

Making league operation sustainable for future secretaries

Data Model Overview
1. Raw Layer (Ingestion)

Straight-through parsing of captain-submitted match reports.
No business logic.
Responsible for schema harmonization and soft validation.

Modules:

Upload_Indiv_Raw

Upload_Team_Raw

2. Staging Layer (Canonical Transformations)

Applies naming conventions, type coercion, key creation, and prepares per-match and per-player structures.

Modules:

Indiv_Results_Staging

Team_Results_Staging

3. Analytics Layer (Normalized Outputs)

Generates one row per hole per player and feeds into standings & analytics.

Modules:

Indiv_Results_Holes

(future) Standings, handicap engines, BD optimization

(future) Multi-season analytics

Power Query Module Responsibilities
Module	Purpose
Upload_Indiv_Raw	Ingest individual player data, harmonize schema, soft validation
Upload_Team_Raw	Ingest team-level results and match metadata
Indiv_Results_Staging	Canonical player table, type enforcement, ExclScore logic
Team_Results_Staging	Canonical team staging table with MatchKey/TeamKey
Indiv_Results_Holes	Hole-level normalized expansion for analytics
Versioning & Documentation in the Repo

All modules are versioned (v1.0, v1.1, v1.2, …).

Each version lives as a separate .m file under its module folder.

Specs, architecture, change logs live under /docs.

Release bundles go in /releases.

GitHub is used ONLY for technical stewardship — not for league operation.
