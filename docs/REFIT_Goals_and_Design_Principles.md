# REFIT Goals and Design Principles

The REFIT architecture is intentionally engineered for **stability, clarity, maintainability, and extensibility**.  
This document defines the design principles that guide all development work.

---

## Primary Goals

### 1. Eliminate Fragility
Legacy workbooks are prone to broken formulas, inconsistent edits, and structural drift.  
REFIT ensures:
- No hard-coded paths
- No implicit column indexing
- No formula chains dependent on user edits

### 2. Automate Weekly Scoring
Match reports feed directly into:
- **Raw** tables → ingestion only  
- **Staging** tables → validated, normalized league data  
- **Analytics** tables → one row per hole  

Automation replaces manual adjustments, reducing time and error.

### 3. Centralize All Parameters
All rules live in the **Settings** sheet:
- Pars, handicaps, yardages (future)
- Blind Draw parameters
- Handicap algorithm rules
- File locations
- Switches and flags
- Match report paths

No business logic is ever hard-coded in the queries.

### 4. Support Future Flexibility
The system anticipates:
- Multi-course support
- Alternate scoring rules
- Blind Draw algorithm variations
- Additional analytics (hole difficulty, improvement scores)
- Multi-season data modeling

### 5. Make Maintenance Simple
With proper documentation and standardized modules:
- A new secretary can operate the system confidently.
- Seasonal updates require minimal work.
- Version control preserves the project history.

---

## Design Principles

### **1. Raw → Staging → Analytics Model**
Each layer has a strict role:
- **Raw:** ingestion, no logic  
- **Staging:** canonical league records  
- **Analytics:** hole-level granularity  

### **2. No Side Effects**
Queries only produce structured tables.

### **3. Settings-Driven Logic**
Every rule must be dynamically controlled through the Settings sheet.

### **4. Transparent Schemas**
Each table defines:
- Required columns  
- Expected data types  
- Naming conventions  

### **5. Future-Proofing**
Avoid design decisions that restrict expansion.

---

REFIT’s principles ensure a robust, readable system that the league can depend on for many years.
