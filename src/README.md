# /src — Power Query Source Code

This directory houses all versioned Power Query (M-code) modules used to ingest,
clean, transform, and analyze match report data.

REFIT uses a three-layer data model:

## 1. Raw Layer (Ingestion)
Reads all weekly captain match reports and standardizes fields.

Modules:
- `Upload_Indiv_Raw`
- `Upload_Team_Raw`

## 2. Staging Layer (Canonical Transformations)
Prepares consistent, normalized player and team datasets.

Modules:
- `Indiv_Results_Staging`
- `Team_Results_Staging`

## 3. Analytics Layer (Hole-Level Normalization & Metrics)
Expansion to hole-level data, plus future analytics engines.

Modules:
- `Indiv_Results_Holes`

## Versioning
Each module folder contains:

- `ModuleName_v1.0.m` — first working version  
- `ModuleName_v1.1.m` — incremental refinement  
- `ModuleName_v1.2.m` — aligned to latest spec  
- etc.

Every file includes:
- Header block  
- Module description  
- Change log  

Do **not** modify M-code directly in GitHub. Instead:
Edit locally → test in Excel → commit updated versions.
