**REFIT MATCH REPORT OUTPUT SPECIFICATION**

**Version 1.1 — Clean Integrated Draft**  
**Purpose:** Define the exact data outputs produced by the Captain’s
Match Report document, ensuring consistency, automation reliability, and
compatibility with the REFIT Raw → Staging → Analytics data model.

**1. Overview**

The REFIT Match Report file is the *authoritative weekly data source*
for the Golf League’s scoring, statistics, standings, and historical
reporting. Each Match Report document is completed by a team captain
immediately following league play and contains:

- Player-level scoring data

- Team-level summary data

- Hole-by-hole strokes

- Course metadata

- Match outcome details

- Flags indicating special conditions (weather, partial rounds,
  forfeits)

The Match Report must output **two structured tables**:

1.  **Upload_Ind** → feeds Upload_Indiv_Raw

2.  **Upload_Team** → feeds Upload_Team_Raw

Both tables must populate directly into the REFIT Master Workbook
through Power Query without requiring manual cleanup.

This specification describes the structure, meaning, and formatting
expectations for every output field.

**2. General Output Requirements**

**2.1 Output Format**

The Match Report shall output exactly two tables:

| **Output Table** | **Purpose** |
|----|----|
| **Upload_Ind** | Individual-level scoring data (one row per player per match) |
| **Upload_Team** | Team-level summary and results (one row per team per match) |

Tables may be implemented as structured Excel Tables or named ranges, as
long as REFIT can identify them uniquely by name.

**2.2 Table Naming (Required)**

- Individual table: **Upload_Ind**

- Team table: **Upload_Team**

These names must not change.

**2.3 Data Types**

Where applicable:

- Numeric values must be true numerics (not text).

- Date must be an Excel date serial value.

- Logical flags are delivered as **TRUE/FALSE** (Excel booleans).

- Text fields should not include trailing spaces or special characters.

**2.4 Missing or Inapplicable Data**

If a field is not applicable (e.g., player absent), it should be:

- Left blank for text values

- Left blank or returned as 0 for numeric values, depending on context

- Returned as FALSE for logical flags

**3. Output Table: Upload_Ind**

**3.1 Record Granularity**

**One row per player who appears in the match.**  
This includes:

- Both members of a playing pair

- Substitutes

- Players who start but do not complete the match

- Opponent team players (if recorded)

**3.2 Required Columns**

Below is the definitive schema for Upload_Ind, in canonical order.
(Column order in the Match Report does not matter, but naming must match
exactly.)

**A. File Context and Match Metadata**

| **Column** | **Type** | **Description** |
|----|----|----|
| **SourceFile** | Text | Auto-filled by Power Query; Match Report output leaves this blank. |
| **Year** | Number | League year (e.g., 2025). |
| **Week** | Number | Week number (1–? depending on season). |
| **Date** | Date | Date of league play. |
| **Side** | Text | "Front" or "Back", depending on course rotation. |
| **Course** | Text | (Optional for now) Name of course/side if multi-course is implemented. |
| **Team** | Text | The captain’s team identifier (e.g., “A”, “B”, “C”, “D”). |
| **Opponent** | Text | The opposing team identifier. |
| **MatchCompleted** | TRUE/FALSE | Whether the match was fully completed. |
| **ForfeitFlag** | TRUE/FALSE | TRUE if forfeit occurred (full or partial). |

**B. Player** **Metadata** **@1.1COMMENT1:** **By prior agreement,
PlayerKey, IsCaptain and Tee were supposed to be included. It seems that
those data are player metadata@**

| **Column** | **Type** | **Description** |
|----|----|----|
| **Position** | Number | 1 or 2 (first or second player in lineup order). **@1.1COMMENT2:** **Four players per team, so Description should state 1, 2, 3 or 4.@** |
| **Player** | Text | Player name (as standardized in Settings). |
| **Hdcp** | Number | Player handicap entering the match. |
| **Gross** | Number | Total gross strokes for the 9-hole round. |
| **Net** | Number | Gross minus handicap. |

**C. Totals and Scoring Outcomes**

| **Column** | **Type** | **Description** |
|----|----|----|
| **BirdiesTotal** | Number | Total number of birdies. |
| **EaglesTotal** | Number | Total number of eagles. |
| **DoubleEaglesTotal** | Number | Total number of double eagles. |
| **NetPoints** | Number | Net points for the round. |
| **PointsTotal** | Number | Total points for the round (gross + net + extras). |
| **ExclScore** | Text | Field used by REFIT to interpret DNF, partial rounds, weather, etc. Must output EXACT codes defined in Settings. |

**D. Hole-by-Hole Details (Long-Form)**

Each hole column uses two-digit suffixes 01 through 18.

Even though matches are 9 holes, the long-form structure ensures REFIT
compatibility.

**Hole Strokes**

| **Column** | **Type** | **Description** |
|----|----|----|
| **Score_01 … Score_18** | Number/Blank | Strokes on each hole (only 9 will be populated). |

**Course-Par and Handicap Index (Populated automatically)**

| **Column** | **Type** | **Description** |
|----|----|----|
| **Par_01 … Par_18** | Number | Par for each hole (auto-populated based on Side). |
| **Hcp_01 … Hcp_18** | Number | Hole handicap ranking (1 hardest). |

**Computed Indicators**

| **Column** | **Type** | **Description** |
|----|----|----|
| **NetScore_01 … NetScore_18** | Number | Strokes − hole handicap allowance if applicable. |
| **Bird_01 … Bird_18** | TRUE/FALSE | TRUE if birdie. |
| **Eagle_01 … Eagle_18** | TRUE/FALSE | TRUE if eagle. |
| **DoubleEagle_01 … DoubleEagle_18** | TRUE/FALSE | TRUE if double eagle. |
| **Points_01 … Points_18** | Number | Points awarded on each hole. |

Only holes 1–9 of the active side need to be filled; the rest remain
blank.

**4. Output Table: Upload_Team**

**4.1 Record Granularity**

**One row per team per match.**  
The two teams in the match each generate one row.

**4.2 Required** **Columns** **@1.1COMMENT3:** **By prior agreement, I
thought there would be a TeamKey field?@**

| **Column**         | **Type**   | **Description**                     |
|--------------------|------------|-------------------------------------|
| **SourceFile**     | Text       | Filled by Power Query.              |
| **Year**           | Number     | League year.                        |
| **Week**           | Number     | Week number.                        |
| **Date**           | Date       | Match date.                         |
| **Team**           | Text       | The team this row corresponds to.   |
| **Opponent**       | Text       | Opponent team identifier.           |
| **Tm Net**         | Number     | Team net total (sum of Net scores). |
| **Tm Net Points**  | Number     | Points earned based on net results. |
| **Tm Tot Points**  | Number     | Total points including extras.      |
| **MatchCompleted** | TRUE/FALSE | Same flag as in Upload_Ind.         |
| **ForfeitFlag**    | TRUE/FALSE | Forfeit indicator for the team.     |

(Additional fields may be added later for expanded formats or season
analytics.)

**5. Business Logic Requirements**

**5.1 ExclScore Rules**

This field determines special handling in REFIT Staging:

Possible examples (final list defined in Settings):

- "NONE" → full round completed

- "WEATHER5" → weather shortened to 5 holes

- "DNF" → player did not finish

- "ABSENT" → player absent (should still appear in Upload_Ind for record
  consistency)

Match Report must ensure *exact spelling* of codes.

**5.2 Handicap and Par/Hcp Determination**

- Handicap values are carried into Upload_Ind from captain input.

- Par_XX and Hcp_XX columns must be generated using the selected Side
  (Front or Back).

- No hard-coded course values may appear in the Match Report; these are
  sourced from Settings tables embedded in the document.

**5.3 Consistency Rules**

- Every team appearing in Upload_Team must match team IDs in Upload_Ind.

- Every player in Upload_Ind must have a Position (1 or
  2)**.@1.1COMMENT4:** **Should be 1, 2, 3 or 4.@**

- All rows must include Year, Week, Date, Side, Team, Opponent.

- A match cannot have MatchCompleted = TRUE and ForfeitFlag = TRUE
  simultaneously unless REFIT defines a special case.

**6. Error Handling & Validation Requirements**

The Match Report shall:

- Prevent saving if Week, Date, Side, Team, or Opponent is missing.

- Flag holes with blank values only if MatchCompleted = TRUE.

- Ensure no text appears in numeric fields.

- Normalize player names against a master list (drop-down selector).

- Validate that both teams have exactly 2 player rows in Upload_Ind.
  **@1.1COMMENT5:** **Upload_Ind must contain a total of 8 rows: 4 for
  reporting captain’s team and 4 for the opposing team.@**

**7. Compatibility Requirements with REFIT Pipeline**

**7.1 Upload_Ind → Upload_Indiv_Raw**

Every column listed above must map 1:1 into the Raw table schema.

**7.2 Upload_Team → Upload_Team_Raw**

Exactly one row per team per match must be generated.

**7.3 Staging and Analytics Dependence**

- Staging requires:

  - SourceFile

  - Week

  - Date

  - Side

  - Team

  - Opponent

  - Position

  - Player

  - ExclScore

- Analytics (Indiv_Results_Holes) requires:

  - Long-form hole columns

  - Consistent par/hcp metadata

  - NetScore_XX and Points_XX

**8. Future-Proofing**

The Match Report design must allow:

- Multi-course play

- Variable number of holes (e.g., 5-hole weather cases)

- Blind Draw scoring variants

- Match formats that may change season-to-season

- Automated captain error checking

- Compatibility with future REFIT exports (PDFs, JSON, etc.)

**9. Summary**

This v1.1 specification defines the required Match Report outputs to
ensure:

- Seamless ingestion into REFIT

- Correct staging transformations

- Accurate hole-level analytics

- Future flexibility and maintainability

- Zero manual intervention by a secretary

This document represents the **authoritative definition** of the REFIT
weekly data interface.

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
