# Upload_Team_Raw — Raw Team Ingestion

Imports match-level team totals from captain match reports.

### Responsibilities
- Extract team net scores, total points, and match metadata  
- Guarantee presence of one row per team per match  
- Include soft validation flags  
- Pass clean, minimal schema to Staging  

### Downstream Usage
- `Team_Results_Staging`
- Standings engine

### Versioning
Each revision is stored as a separate `.m` file:
- `Upload_Team_Raw_v1.0.m`
- `Upload_Team_Raw_v1.1.m`
- `Upload_Team_Raw_v1.2.m` (current)

### Version History
- v1.0 — 2025-12-14
- First production-intent version
- Implemented canonical `ExpectedColumns` list
- Added defensive column validation
- Confirmed compatibility with current REFIT workbook