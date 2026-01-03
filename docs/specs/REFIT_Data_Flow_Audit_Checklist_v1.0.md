# GL-REFIT v1.0 Audit Checklist  
*(Pre-Engine Readiness)*

This checklist certifies that all upstream data layers are correct, stable,
and contract-complete before Engine work begins.

---

## A. Settings & Configuration (CRITICAL)

### A-1. Settings Architecture Finalization
- [ ] Final decision documented: which values live in `Settings` vs `Static_Season_Config`
- [ ] `Static_Season_Config` contents fully populated (no TBD placeholders)
- [ ] All Summary_New queries source season constants **only** from `Static_Season_Config`
- [ ] No hard-coded season values exist anywhere in Power Query

### A-2. Static_Season_Config Implementation
- [ ] Exists as a **table** with stable schema
- [ ] Exists as a **query** that returns the table
- [ ] Refreshes without error when workbook refreshes
- [ ] SeasonYear, CourseName, Points rules validated against league rules

---

## B. Raw Layer (Upload_*_Raw)

### B-1. General Raw Guarantees
- [ ] Empty-folder safe (returns zero-row canonical schema)
- [ ] No Transform File artifacts
- [ ] SourceFile column populated correctly
- [ ] Canonical column order enforced

### B-2. Legacy Compatibility (TEMP)
- [ ] RenameMap exists ONLY for legacy validation
- [ ] RenameMap clearly marked for removal post-validation
- [ ] Legacy ExclScore (1/0) normalized to logical true/false
- [ ] No business logic introduced in Raw

---

## C. Staging Layer (_Staging)

### C-1. Schema Lock & Contracts
- [ ] RequiredCols list exists and is authoritative
- [ ] Missing columns added as null
- [ ] Extra columns dropped
- [ ] Column order enforced

### C-2. Key Derivations (Mechanical Only)
- [ ] PlayerKey derived in Staging (not Summary)
- [ ] TeamKey derived in Staging
- [ ] MatchKey derivation documented and consistent
- [ ] SeasonYear present and populated correctly

### C-3. Type Safety
- [ ] All numeric aggregates use `type number` (not Int64.Type)
- [ ] Logical fields typed as logical
- [ ] No preview-only values (worksheet matches PQ preview)

---

## D. Hole-Level Layer (Indiv_Results_Holes)

### D-1. Structural Integrity
- [ ] One row per Player × Week × Hole
- [ ] Hole numbers 1–18 generated consistently
- [ ] Nulls preserved for unplayed holes

### D-2. Keys & Joinability
- [ ] PlayerKey present
- [ ] TeamKey present
- [ ] MatchKey present (consistent with Staging definition)

### D-3. Type Correctness
- [ ] Score, NetScore, Points typed as `type number`
- [ ] Bird/Eagle flags typed consistently
- [ ] No mismatch between PQ preview and worksheet output

---

## E. Summary_New Tables

### E-1. General Guarantees
- [ ] No key derivations occur in Summary_New
- [ ] No business logic inference
- [ ] All joins are explicit and documented
- [ ] Empty-season safe (schema holds with no data)

### E-2. Table-Specific Checks
- [ ] Summary_New__Season populates MatchWeek & MatchDate
- [ ] Summary_New__Teams aggregates correctly
- [ ] Summary_New__Players populated only from evidenced play
- [ ] Summary_New__Handicaps schema complete (engine-owned fields stubbed)
- [ ] Summary_New__Matches populated correctly without engines
- [ ] Summary_New__Player_Stats correct with legacy data
- [ ] Summary_New__Weekly_Stats aligns with Player_Stats

---

## F. End-to-End Validation

- [ ] At least one legacy match report loads end-to-end
- [ ] Team totals match legacy results
- [ ] Player stats match legacy results
- [ ] Known birdie/eagle cases validated
- [ ] ExclScore behavior confirmed as passthrough (no suppression yet)

---

## G. Documentation & Version Lock

- [ ] All queries marked v1.0
- [ ] README reflects current architecture
- [ ] Audit checklist committed
- [ ] Open issues logged (non-blocking only)

---

## ✅ Audit Exit Criteria

Engine development may begin **only when all sections A–G are checked**.

Any post-engine change to Raw, Staging, or Holes requires re-running this audit.
