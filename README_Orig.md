# GL-REFIT — Golf League Scoring Modernization Project

GL-REFIT is a modernized, fully-structured scoring and analytics system for the
Timken/Metallus Monday Night Golf League. It replaces the legacy workbook with a
Power Query–driven architecture, formal data modeling, automated ingestion, and
clear separation between captain-facing templates and league-secretary tooling.

This repository contains:

- System documentation (`/docs`)
- Versioned Power Query M-code modules (`/src`)
- Match report templates and workbook assets (`/templates`)
- Archived or legacy materials (`/archive`)
- Packaged release bundles (`/releases`)

The project is designed for long-term maintainability, extensibility, and
handoff to future league secretaries and technical stewards.

---

## Project Overview

### Purpose
To provide a standardized, automated, and reliable scoring system that:

- Eliminates manual calculation and transcription errors  
- Supports stable weekly ingestion of captain match reports  
- Implements a clean Raw → Staging → Analytics data model  
- Centralizes all rules, metadata, scoring algorithms, and parameters  
- Enables advanced analytics (hole difficulty, blind-draw optimization, trends)  
- Provides durability across seasons and club leadership changes  

---

## System Architecture Summary

### 🔷 Raw Layer
Pure ingestion of weekly match reports.  
No business logic is applied here — only harmonization and soft validation.

Modules:
- `Upload_Indiv_Raw`  
- `Upload_Team_Raw`

### 🔷 Staging Layer
Transforms raw data into canonical structures used by downstream logic.

Modules:
- `Indiv_Results_Staging`  
- `Team_Results_Staging`

### 🔷 Analytics Layer
Fully normalized hole-level and player-level outputs for modeling and reporting.

Modules:
- `Indiv_Results_Holes`  
- (future) Season analytics, standings engine, handicap engine

---

## Versioning & Documentation

All Power Query modules are versioned using semantic versioning:

- `v1.x` — incremental improvements  
- `v2.x` — structural changes or breaking transformations  
- `v3.x` and beyond — major refactors or features  

Each `.m` file includes:
- Header block  
- Module description  
- Change log  

Documentation lives in `/docs`, including the authoritative **Match Report Output Specification v1.2**.

---

## Getting Started (For Technical Maintainers)

1. Review the `/docs` directory for system specifications  
2. Review M-code under `/src`  
3. Use `/releases` to deploy versioned packages to league secretaries  
4. Match report templates are located in `/templates`

Non-technical secretaries will only interact with:
- The REFIT Master Workbook
- The Match Report Template  
- Weekly captain submissions

GitHub usage is *not required* for league operation.
