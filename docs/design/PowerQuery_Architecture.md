# Power Query Architecture

REFIT uses a modular, settings-driven Power Query architecture designed for clarity and maintainability. Each module has a singular responsibility and produces tables with well-defined schemas.

---

# 1. Architectural Principles

### **1. No hard-coded paths**
All file/folder locations are read through the `GetSetting()` function.

### **2. Settings-driven logic**
Every rule controlling scoring, handicaps, or workflow is configured in the Settings sheet.

### **3. Strict module boundaries**
Each module performs one job:
- Raw modules ingest files.
- Staging modules standardize league data.
- Analytics modules explode rounds into hole-level rows.

### **4. Defensive coding**
Raw modules are resilient to:
- Empty folders  
- Missing fields  
- Extra fields  
- Columns appearing in any order  

### **5. Type safety**
Modules apply explicit types to critical columns.

### **6. Schema stability**
Downstream modules rely on stable, documented schemas — never on column order or implicit indexing.

---

# 2. Functional Components

### **Global Function: `GetSetting()`**
Used to retrieve:
- Folder paths
- Pars, handicaps
- Blind Draw configuration
- Flags and switches

This guarantees consistent use of parameters across every module.

---

# 3. Module Responsibilities

## Raw Modules
- Load files from folder.
- Identify tables by name (`Upload_Ind`, `Upload_Team`).
- Expand all columns dynamically.
- Add `SourceFile`.

## Staging Modules
- Standardize naming.
- Enforce types.
- Reduce tables to canonical sets of columns.
- Calculate derived scoring fields.
- Add `MatchKey`, `PlayerKey` (future).

## Analytics Modules
- Expand long-form hole arrays.
- Calculate hole-level scoring properties.
- Provide analytics-ready tables.

---

# 4. End-to-End Flow

1. **Match Report files** exported weekly by captains.
2. **Raw modules ingest** those tables.
3. **Staging modules clean and standardize** the results.
4. **Analytics modules expand** to hole-level detail.
5. **Final tables** feed standings, reports, and statistical tools.

---

The Power Query architecture is the operational engine of REFIT, enabling stable, automated scoring with transparent logic.
