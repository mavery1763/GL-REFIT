# Data Column Naming Standards

This document defines the official naming conventions for all columns used throughout the REFIT system.  
These rules ensure consistency across Power Query modules, match reports, analytics layers, and any future extensions.

---

# 1. General Naming Rules

### **1.1 Use PascalCase**
Examples:
- `SourceFile`
- `PlayerKey`
- `ExclScore`

### **1.2 Columns must be semantically meaningful**
Names should describe exactly what the field represents.

### **1.3 No spaces, no special characters**
Avoid ambiguity and ensure compatibility across tools:
- ❌ `Total Birdies`
- ✔ `BirdiesTotal`

### **1.4 Round-level vs. hole-level fields must be clearly distinct**
Round-level examples:
- `Gross`
- `Net`
- `BirdiesTotal`

Hole-level examples:
- `Hole`
- `Par`
- `Hcp`
- `Score`

### **1.5 Use consistent prefixes/suffixes for related fields**

| Type                      | Pattern                       | Examples                         |
|--------------------------|-------------------------------|----------------------------------|
| Long-form hole arrays    | Prefix + `_XX`                | `Score_01`, `Par_12`, `Hcp_07`   |
| Totals/aggregates        | `<Metric>Total`               | `BirdiesTotal`                   |
| Points variants          | `NetPoints`, `PointsTotal`    |                                  |
| Identifiers / Keys       | `<Name>Key`                   | `MatchKey`, `TeamKey`            |

---

# 2. Required Standard Columns (all layers)

### **Identifiers**
- `SourceFile`
- `Week`
- `Date`
- `Team`
- `Opponent`
- `Side`
- `Player` (individual modules)
- `Position` (team ordering)

### **Scoring**
- `Gross`
- `Hdcp`
- `Net`
- `ExclScore`

### **Aggregates**
- `BirdiesTotal`
- `EaglesTotal`
- `DoubleEaglesTotal`
- `NetPoints`
- `PointsTotal`

---

# 3. Rules for Long-Form Hole Arrays

### **3.1 Format**
Where `XX` = padded hole number (01–18)

### **3.2 Allowed Metrics**
- `Score_XX`
- `Par_XX`
- `Hcp_XX`
- `NetScore_XX`
- `Bird_XX`
- `Eagle_XX`
- `DoubleEagle_XX`
- `Points_XX`

### **3.3 Padding is mandatory**
Use two digits for hole numbers.

---

# 4. Staging-Level Naming Rules

The staging layer standardizes all derived scoring fields:

- `BirdiesTotal`
- `EaglesTotal`
- `DoubleEaglesTotal`
- `NetPoints`
- `PointsTotal`

All fields adopt **PascalCase** and **no underscores**.

---

# 5. Analytics-Level Naming Rules

The hole-expansion layer uses a fixed schema:

| Column        | Meaning                          |
|---------------|----------------------------------|
| `Hole`        | Hole number (1–18)               |
| `Par`         | Par for the hole                 |
| `Hcp`         | Handicap rating for the hole     |
| `Score`       | Gross strokes                    |
| `NetScore`    | Net score (Score - Hdcp contrib) |
| `Bird`        | Boolean birdie flag              |
| `Eagle`       | Boolean eagle flag               |
| `DoubleEagle` | Boolean double-eagle flag        |
| `Points`      | Points for the hole              |

---

# 6. Match Report Alignment

Match Report output tables MUST:

- use these exact field names  
- output Score_XX, Par_XX, Hcp_XX using the padded scheme  
- ensure column order is irrelevant  
- supply all required columns even if blank  

---

This standard is authoritative for all REFIT development and should be updated only through versioned changes.
