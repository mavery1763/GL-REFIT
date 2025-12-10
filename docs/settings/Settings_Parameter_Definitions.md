# Settings Parameter Definitions

This document describes every named range in the Settings sheet used by the REFIT system.  
Each parameter includes: purpose, data type, expected format, and Power Query usage.

---

# How to Read This Document

Each entry follows this template:

parameterName

Type: text / number / logical / list
Used By: <PQ modules>
Purpose: <what this controls>
Allowed Values: <if applicable>
Notes: <anything important>

Parameters are grouped by Settings block.

---

# 1. League Information

### leagueYear
**Type:** number  
**Used By:** future modules (e.g., season rollover)  
**Purpose:** Identifies the active league year.

---

# 2. Scoring Settings

### scoringMode
**Type:** text  
**Allowed Values:** "net", "gross", "hybrid"  
**Purpose:** Controls scoring calculation mode (future feature).

---

# 3. Handicap Settings

### hdcpLookbackRounds
**Type:** number  
**Purpose:** Number of past rounds used to compute handicaps.  
**Notes:** Not yet implemented, reserved for future module.

### hdcpDropWorst
**Type:** number  
**Purpose:** Number of worst rounds dropped when computing handicap.  
**Notes:** For future HDCP engine.

### hdcpRoundingMethod
**Type:** text  
**Allowed Values:** "standard", "floor", "ceiling"  
**Purpose:** Defines rounding behavior of handicaps.

---

# 4. Course Settings

### parArray
**Type:** list (18 numeric values)  
**Used By:** Raw → Staging → Analytics  
**Purpose:** Defines par for each hole.  
**Notes:** Must contain exactly 18 values.

### hcpArray
**Type:** list (18 numeric values)  
**Purpose:** Hole handicap ranking for each hole.

### yardageArray (future)
**Type:** list  
**Purpose:** Optional yardage metadata.

---

# 5. Blind Draw Settings

### bdEnabled
**Type:** logical  
**Purpose:** Enables or disables Blind Draw calculations.

### bdMaxHoles
**Type:** number  
**Purpose:** Maximum number of holes selectable for BD scoring.

### bdOverParSelectionMode
**Type:** text  
**Allowed:** `"hardest"`  
**Purpose:** When selecting over-par holes, always choose the hardest holes.

### bdUnderParSelectionMode
**Type:** text  
**Allowed:** `"easiest"`  
**Purpose:** Select easiest holes for under-par selection.

### bdTieBreakMode
**Type:** text  
**Purpose:** Future expansion for BD tie-breaking logic.

---

# 6. Schedule Settings

### scheduleWeekCount
**Type:** number  
**Purpose:** Total number of weeks in the season.

### scheduleStartDate
**Type:** date  
**Purpose:** First week’s date (for automated future scheduling features).

---

# 7. Match Report Settings

### matchReportsFolderPath
**Type:** text  
**Used By:** Upload_Indiv_Raw, Upload_Team_Raw  
**Purpose:** Points PQ to the folder containing match report files.

### stagingFolderPath
**Type:** text  
**Purpose:** Optional: overrides matchReportsFolderPath for testing.

### useLocalStagingFolder
**Type:** logical  
**Purpose:** Switch between test/staging/prod folders.

---

# 8. Power Query + File Paths

### outputFolderPath (future)
**Purpose:** Destination for generated reports.

---

# 9. System Flags

### enable18HoleMode
**Type:** logical  
**Purpose:** Controls expansion behavior (always TRUE under current architecture).

### debugMode
**Type:** logical  
**Purpose:** Enables extra diagnostics in test environments.

---

# 10. Summary Table (For Quick Reference)

| Parameter               | Type     | Purpose                                      |
|-------------------------|----------|----------------------------------------------|
| matchReportsFolderPath  | text     | Input directory for match reports            |
| stagingFolderPath       | text     | Optional staging input path                  |
| useLocalStagingFolder   | logical  | Determines which folder PQ uses             |
| parArray                | list     | Par values for 18 holes                      |
| hcpArray                | list     | Handicaps for 18 holes                       |
| bdMaxHoles              | number   | Max BD hole selections                       |
| bdEnabled               | logical  | Enable Blind Draw logic                      |
| leagueYear              | number   | Defines the scoring season                   |
| enable18HoleMode        | logical  | Expand to 18 holes (always TRUE)             |

---

# Notes

- Additional parameters may be added over time.
- This file is the authoritative reference for PQ developers.
- Any parameter change that affects scoring must be recorded in `/docs/Version_History.md`.

