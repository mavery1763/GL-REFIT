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

