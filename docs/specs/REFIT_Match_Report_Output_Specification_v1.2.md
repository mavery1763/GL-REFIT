**REFIT MATCH REPORT OUTPUT SPECIFICATION**

**Version 1.2 — Clean Integrated Draft**  
**Purpose:** Define the required outputs of the Captain’s Match Report
template for reliable integration with the REFIT Raw → Staging →
Analytics data pipeline.

**1. Overview**

The REFIT Match Report workbook is the weekly source of truth for league
scoring, standings, hole-by-hole analytics, and season-long reporting.
Captains enter match information directly into the template, and the
workbook outputs two structured data tables:

1.  **Upload_Ind** — individual player scoring data

2.  **Upload_Team** — team-level match summary data

These two tables feed directly into the REFIT Master Workbook through
Power Query.  
This specification defines the required structure, naming, and meaning
of all output fields, ensuring long-term stability and error-free
ingestion.

**2. General Output Requirements**

**2.1 Output Tables**

The Match Report must output exactly two tables:

| **Output Table** | **Purpose**                                      |
|------------------|--------------------------------------------------|
| **Upload_Ind**   | Player-level scoring and hole-by-hole details    |
| **Upload_Team**  | Team-level scoring, points, and match conditions |

These tables may be implemented as structured Excel Tables or named
ranges, but their **names must not change**.

**2.2 Data Types**

- Numeric fields → real numbers (not text)

- Dates → Excel serial dates

- Logical flags → TRUE/FALSE

- Text → clean strings with no trailing spaces

**2.3 Missing Values**

- Text fields: blank when inapplicable

- Numeric fields: blank unless a 0 is intended

- Logical fields: FALSE if not applicable

**3. Output Table: Upload_Ind**

**3.1 Record Granularity**

**One row per player (8 players total per match).**  
The Match Report must output exactly:

- **4 rows for the reporting captain’s team**

- **4 rows for the opposing team**

All eight rows must appear even if a player:

- is absent,

- is substituted,

- does not complete the match.

**3.2 Required Columns**

The canonical Upload_Ind schema is defined below.

**A. File Context & Match Metadata**

| **Column** | **Type** | **Description** |
|----|----|----|
| **SourceFile** | Text | Filled automatically by Power Query. Match Report leaves this blank. |
| **Year** | Number | League year. |
| **Week** | Number | League week number. |
| **Date** | Date | Match date. |
| **Side** | Text | “Front” or “Back”. |
| **Course** | Text | Course name (for future multi-course support). |
| **Team** | Text | Player’s team identifier. |
| **Opponent** | Text | Opposing team identifier. |
| **MatchCompleted** | TRUE/FALSE | Whether the match was fully completed. |
| **ForfeitFlag** | TRUE/FALSE | Whether this team forfeited. |

**B. Player Metadata**

| **Column** | **Type** | **Description** |
|----|----|----|
| **Position** | Number | Player lineup slot: **1, 2, 3, or 4**. |
| **Player** | Text | Player name (dropdown-validated). |
| **PlayerKey** | Text | Player’s unique identifier from Settings. |
| **Tee** | Text | Tee assignment used for the round (e.g., “White”, “Gold”). |
| **Hdcp** | Number | Handicap applied for this match. |

**C. Round-Level Totals & Scoring**

| **Column** | **Type** | **Description** |
|----|----|----|
| **Gross** | Number | Total strokes for the 9-hole round. |
| **Net** | Number | Gross minus handicap. |
| **BirdiesTotal** | Number | Count of birdies. |
| **EaglesTotal** | Number | Count of eagles. |
| **DoubleEaglesTotal** | Number | Count of double eagles. |
| **NetPoints** | Number | Net points awarded. |
| **PointsTotal** | Number | Total points for the round. |
| **ExclScore** | Text | Exclusion code (e.g., “NONE”, “DNF”, “WEATHER5”). |

**D. Hole-by-Hole Long-Form Arrays**

All hole-level columns use two-digit suffixes (01–18).  
Although only 9 holes are played:

- For **Front**, holes 1–9 populated, 10–18 blank

- For **Back**, holes 10–18 populated, 1–9 blank

**Hole Strokes**

| **Column**              | **Type**     |
|-------------------------|--------------|
| **Score_01 … Score_18** | Number/Blank |

**Course Metadata**

| **Column**          | **Type** |
|---------------------|----------|
| **Par_01 … Par_18** | Number   |
| **Hcp_01 … Hcp_18** | Number   |

**Derived Hole Indicators**

| **Column**                          | **Type**   |
|-------------------------------------|------------|
| **NetScore_01 … NetScore_18**       | Number     |
| **Bird_01 … Bird_18**               | TRUE/FALSE |
| **Eagle_01 … Eagle_18**             | TRUE/FALSE |
| **DoubleEagle_01 … DoubleEagle_18** | TRUE/FALSE |
| **Points_01 … Points_18**           | Number     |

**4. Output Table: Upload_Team**

**4.1 Record Granularity**

**One row per team per match** (two rows total).

**4.2 Required Columns**

| **Column**         | **Type**   | **Description**                        |
|--------------------|------------|----------------------------------------|
| **SourceFile**     | Text       | Filled by Power Query.                 |
| **Year**           | Number     | League year.                           |
| **Week**           | Number     | Week number.                           |
| **Date**           | Date       | Match date.                            |
| **Team**           | Text       | Team identifier.                       |
| **Opponent**       | Text       | Opposing team.                         |
| **Side**           | Text       | “Front” or “Back”.                     |
| **Tm Net**         | Number     | Total team net score.                  |
| **Tm Net Points**  | Number     | Net points awarded.                    |
| **Tm Tot Points**  | Number     | Total points for the team.             |
| **MatchCompleted** | TRUE/FALSE | Whether the match was fully completed. |
| **ForfeitFlag**    | TRUE/FALSE | Whether this team forfeited.           |

TeamKey is not included; it is derived later in Staging.

**5. Business Logic Requirements**

**5.1 ExclScore**

Must contain one of the valid REFIT exclusion codes defined in
Settings.  
Examples include:

- "NONE"

- "DNF"

- "WEATHER5"

- "ABSENT"

**5.2 Par/Hcp Assignment**

Par_XX and Hcp_XX must be correctly loaded based on the selected Side
(Front or Back).  
No hard-coding is permitted.

**5.3 Player Row Count**

Upload_Ind must always contain:

- **Exactly 8 rows total**

- **4 rows for each team**

- **All rows containing Position values 1–4**

**5.4 Integration Consistency**

All Match Report outputs must align with required input fields in:

- Upload_Indiv_Raw

- Upload_Team_Raw

- Indiv_Results_Staging

- Indiv_Results_Holes

**6. Error Handling & Validation**

The Match Report shall:

- Require Week, Date, Side, Team, and Opponent before generating outputs

- Warn captains if a Position is missing

- Confirm exactly 4 players are assigned to each team

- Prevent entry of non-numeric values in scoring fields

- Ensure net scores, hole-level values, and point totals are internally
  consistent

- Flag inconsistencies between MatchCompleted and hole data

**7. Compatibility With REFIT Pipeline**

**7.1 Raw Layer**

Upload_Ind and Upload_Team must map directly into the Raw layer without
re-typing or reinterpretation.

**7.2 Staging Layer**

Staging transforms rely on:

- Year

- Week

- Date

- Side

- Player

- Team

- Opponent

- Position

- ExclScore

- Long-form hole arrays

**7.3 Analytics Layer**

Indiv_Results_Holes depends on:

- Score_XX

- Par_XX

- Hcp_XX

- NetScore_XX

- Bird/Eagle/DoubleEagle

- Points_XX

**8. Future-Proofing Requirements**

The Match Report output structure must support:

- Multi-course seasons

- Weather-shortened rounds

- Blind Draw variants

- Expanded scoring formats

- Season-long and cross-season analytics

- PDF / web / API outputs in future enhancements

**9. Summary**

This Version 1.2 specification defines the authoritative structure of
the REFIT Match Report’s output tables.  
Adherence to this document ensures:

- Reliable PQ ingestion

- Predictable data transformations

- Accurate analytics

- Long-term maintainability

- Compatibility with future REFIT enhancements

This document governs the interface between captains and the REFIT
system.

- 
- 
- 
- 
- 

<!-- -->

- 
- 
- 
- 

1.  
2.  
3.  
4.  - 
    - 
5.  

<!-- -->

1.  
2.  
3.  

- 
- 

<!-- -->

- 
- 
- 
- 

<!-- -->

- 
- 

|     |     |     |
|-----|-----|-----|
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |

|     |     |     |
|-----|-----|-----|
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |

- 
- 

<!-- -->

- - 
  - 
- - 
  - 

<!-- -->

- 
- 
- 
- 
- 
- 
- 
- 

|     |     |     |
|-----|-----|-----|
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |
|     |     |     |

- 
- 

<!-- -->

- 
- 
- 

<!-- -->

- 
- 
- 

<!-- -->

- - 
  - 
  - 
  - 
- - 
  - 
  - 
  - 
  - 

1.  
2.  
3.  
4.  
5.  
6.  
7.  
8.  
