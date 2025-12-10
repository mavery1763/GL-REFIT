# REFIT Data Model: Raw → Staging → Analytics

REFIT is built on a **three-layer data model**, common in modern analytics engineering.  
Each layer has a distinct purpose and strict rules governing its content.

---

# 1. Raw Layer (Ingestion Only)

The Raw layer is the **direct feed** from match report output tables.

## Responsibilities
- Load files from the Match Reports folder.
- Extract only the tables named `Upload_Ind` and `Upload_Team`.
- Preserve all columns exactly as produced by the captain’s match report.

## Rules
- **No business logic.**
- **No renaming that changes meaning.**
- **No derived columns except SourceFile.**
- **No transformations beyond type-normalization.**

## Modules
- `Upload_Indiv_Raw`
- `Upload_Team_Raw`

---

# 2. Staging Layer (Canonical League Records)

The Staging layer produces **validated, normalized league-level records**.

## Responsibilities
- Standardize column names and types.
- Compute canonical scoring fields.
- Apply ExclScore rules.
- Shape data so downstream logic does not depend on match report structure.

## Rules
- Only league logic relevant at the round-level belongs here.
- Must NOT expand to hole-level rows. (Analytics does that.)
- Output schemas must match documentation exactly.

## Modules
- `Indiv_Results_Staging`
- `Team_Results_Staging`

---

# 3. Analytics Layer (One Row per Hole)

The Analytics layer transforms each round into **18 hole records**.

## Responsibilities
- Expand Score_01 … Score_18 into row-per-hole records.
- Attach par, handicap, birdie/eagle indicators.
- Compute Net Score and Points per hole.
- Provide the foundation for long-term analytics.

## Rules
- No round-level fields except identifying keys.
- Strict schema: 17 columns (hole, par, hcp, score, etc.)
- No structural reliance on front vs. back; always 18 standardized holes.

## Modules
- `Indiv_Results_Holes`

---

# Summary Diagram

       Raw Layer (file ingestion)
    ┌─────────────────────────────┐
    │ Upload_Indiv_Raw            │
    │ Upload_Team_Raw             │
    └──────────────┬──────────────┘
                   ▼
       Staging Layer (league records)
    ┌─────────────────────────────┐
    │ Indiv_Results_Staging       │
    │ Team_Results_Staging        │
    └──────────────┬──────────────┘
                   ▼
    Analytics Layer (hole-level facts)
    ┌─────────────────────────────┐
    │ Indiv_Results_Holes         │
    └─────────────────────────────┘


---

This data model ensures clarity, maintainability, and long-term analytical value.
