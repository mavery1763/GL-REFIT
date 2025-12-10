# Long-Form Hole Mapping Specification

This specification defines how REFIT represents per-hole scoring, par, handicap, and derived metrics.  
All Power Query modules depend on this convention for correct expansion and analytics.

---

# 1. Purpose of the Long-Form Hole Model

REFIT uses **long-form columns** to:

- Store all hole-level data in Raw tables without requiring row expansion.
- Normalize front/back differences across courses.
- Provide a consistent foundation for Staging and Analytics modules.
- Enable Blind Draw, scoring rules, and statistical analyses.

---

# 2. Structural Requirements

### **2.1 All long-form fields must follow this pattern:**

<Metric>_XX

Where:

- `<Metric>` is a descriptive prefix  
- `XX` is a two-digit number from `01` to `18`

### **2.2 18 Holes Are Always Present**

Even if the league plays 9-hole matches:

- All 18 holes exist in the schema
- Unplayed holes remain null or zeroed as appropriate
- Expansion logic does not depend on the course being front/back

---

# 3. Metrics and Column Definitions

### **Required Metrics:**

#### **Score**

Score_01 ... Score_18

Raw strokes taken on each hole.

#### **Par**

Par_01 ... Par_18

Configured via Settings; match report should embed these values.

#### **Handicap**

Hcp_01 ... Hcp_18

Course handicap ranking for each hole (1 hardest → 18 easiest).

#### **Derived Metrics**

##### Net Score

NetScore01 ... NetScore18

Calculated in match report or in staging.

##### Birdie/Eagle/DoubleEagle Indicators

Bird_01 ... Bird18
Eagle_01 ... Eagle_18
DoubleEagle_01 ... DoubleEagle_18

TRUE/FALSE to indicate whether a score on any hole was below par.

##### Points

Points_01 ... Points_18

Points awarded per hole.

---

# 4. Mapping Rules (Front/Back)

### **4.1 Match Report May Accept 9-Hole Entry**
Captains may enter front/back data:

Score_F1 ... Score_F9
Score_B1 ... Score_B9

The **match report output tables must map these** to full 18-hole long-form arrays.

### **4.2 PQ Never Performs Front/Back Mapping**
Mapping MUST happen **before** ingestion into Raw.

The Raw queries rely on the tables already containing:

Score_01 ... Score_18
Par_01 ... Par_18
Hcp_01 ... Hcp_18

---

# 5. Validation Rules

- All 18 par and hcp values must exist and match the Settings sheet.
- Score columns may be blank if holes are unplayed.
- Derived columns may be blank in Raw; Staging/Analytics will fill gaps.

---

# 6. Impact on Analytics Module

The Analytics module expands each row into 18 hole rows by:

1. Iterating h = 1 to 18  
2. Extracting `<Metric>_h`  
3. Building a hole record  
4. Returning a final 17-column table

This expansion requires:

- Stable column names  
- Stable metric prefixes  
- Reliable two-digit suffixes  

---

The long-form system ensures the entire REFIT platform has a consistent and future-proof representation of per-hole scoring.
