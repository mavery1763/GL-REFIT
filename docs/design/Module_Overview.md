# Module Overview

REFIT’s Power Query system is organized into modular units, each responsible for a specific stage of the scoring workflow. This document summarizes the role and output of each module.

---

# Raw Layer Modules

## **Upload_Indiv_Raw**
- Loads individual results from each match report.
- Dynamically expands all fields in the `Upload_Ind` table.
- Produces one row per player per round.
- Output includes all long-form columns (Score_01…Score_18, Par_01…Par_18, etc.).

## **Upload_Team_Raw**
- Loads team totals from each match report.
- Extracts `Upload_Team` tables.
- Produces team-level summary rows for each match.
- Includes fields such as Team Net, Team Net Points, Team Tot Points.

---

# Staging Layer Modules

## **Indiv_Results_Staging**
- Standardizes column names and types.
- Applies scoring logic relevant at the round level.
- Produces canonical 17-column staging records.
- Adds round-level scoring aggregates (birdies, eagles, net points, etc.).

## **Team_Results_Staging**
- Normalizes team results.
- Adds `TeamKey` and `MatchKey` fields.
- Ensures consistent schemas for standings calculations.

---

# Analytics Layer Modules

## **Indiv_Results_Holes**
- Expands each player-round into 18 hole-level rows.
- Includes hole number, par, handicap, score, net score, scoring indicators.
- Required for analytics such as:
  - Hole difficulty
  - Birdie/Par/Bogey frequencies
  - Blind Draw optimization
  - Player performance trends

---

# Naming and Structure Expectations

- Each module lives in `/src/<module_name>/`.
- Each folder contains:
  - A `README.md` explaining the module
  - Versioned `.m` files:
    ```
    Upload_Indiv_Raw_v1.0.m
    Upload_Indiv_Raw_v1.1.m
    Upload_Indiv_Raw_v1.2.m
    ```
  - A history / notes file (optional)

---

These modules form the operational heart of the REFIT scoring system.
