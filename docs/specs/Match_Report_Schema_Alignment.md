# Match Report Schema Alignment Specification

This document ensures that match report output tables (maintained separately) align with the schemas required by the REFIT Raw modules.

---

# 1. Required Output Tables

Each match report must produce:

### **1. `Upload_Ind` Table (Player-level results)**  
Feeds `Upload_Indiv_Raw`.

### **2. `Upload_Team` Table (Team-level summary)**  
Feeds `Upload_Team_Raw`.

---

# 2. Schema Requirements

### **Upload_Ind Fields**
- SourceFile (added by PQ)
- Identifiers (Week, Date, Team, Opponent, Side, Player)
- Round-level scoring fields (`Gross`, `Hdcp`, `Net`, aggregates)
- Long-form hole arrays (Score_01…Score_18, Par_01…Par_18, etc.)
- ExclScore flag

### **Upload_Team Fields**
- Week, Date
- Team, Opponent
- Totals (Team Net, Team Net Points, Team Tot Points)

---

# 3. Ordering Rules

Column order is irrelevant because Raw PQ modules expand dynamically.

---

# 4. Compatibility Requirements

Match reports must:

- Output exactly the field names specified in `Data_Column_Naming_Standards.md`.
- Include all 18-hole long-form fields.
- Provide nulls for unplayed holes.
- Apply mapping from 9-hole inputs to 18-hole fields BEFORE PQ ingestion.

---

# 5. Future-Proof Expectations

Match report schemas should not change without:
1. Updating this specification,
2. Versioning Raw modules, and
3. Updating documentation in `/docs/specs`.

---

This specification guarantees alignment between the captain-facing Match Report and the PQ ingestion layer.
