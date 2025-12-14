# Upload_Indiv_Raw — Raw Individual Player Ingestion

This module imports all player-level match results from captain match reports,
applies schema harmonization, and outputs a standardized Raw table.

### Responsibilities
- Load all files from the designated Match Reports folder  
- Dynamically expand `Upload_Ind` tables  
- Apply soft validation (`IssueCodes`, `ValidationStatus`)  
- Guarantee schema completeness (required + optional fields)  
- Expand scores, par, handicap, net-score, and point values across all 18 holes  
- Output the canonical Row-Per-Player-Per-Round dataset  

### Downstream Usage
- Consumed by `Indiv_Results_Staging`
- Feeds into `Indiv_Results_Holes`
- Drives standings, BD logic, and analytics

### Versioning
Each revision is stored as a separate `.m` file:
- `Upload_Indiv_Raw_v1.0.m`
- `Upload_Indiv_Raw_v1.1.m`
- `Upload_Indiv_Raw_v1.2.m` (current)

### Version History
- v1.0 — 2025-12-13
- First production-intent version
- Implemented canonical `ExpectedColumns` list
- Added defensive column validation
- Added header comment with version info, etc.
- Confirmed compatibility with current REFIT workbook