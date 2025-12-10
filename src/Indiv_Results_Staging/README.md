# Indiv_Results_Staging — Canonical Player Staging Table

Transforms Raw individual results into the canonical staging format.

### Responsibilities
- Standardize data types, naming, and ordering  
- Rename totals to canonical names (`BirdiesTotal`, etc.)  
- Preserve key identifiers (`SourceFile`, `Week`, `Team`, `Player`)  
- Apply the `ExclScore` override for match scoring rules  
- Produce one row per player per round  

### Downstream Usage
- Player standings logic  
- Handicap calculation engine  
- Analytics layer inputs  
