# Settings Governance

The REFIT scoring system is entirely *settings-driven*.  
All business rules, file paths, scoring parameters, and course metadata are stored in the **Settings sheet** and accessed via the global Power Query function `GetSetting()`.

This document establishes the policies and rules governing how Settings are maintained, updated, and extended.

---

# 1. Purpose of Settings Governance

Settings provide:

- **Centralized control** of league rules  
- **Elimination of hard-coded values** in M-code  
- **Season-to-season adaptability**  
- **Clear documentation for future secretaries**  
- **Safe configuration changes** without editing queries  

Proper governance ensures system stability.

---

# 2. Structural Overview of the Settings Sheet

Settings are grouped into logically organized blocks:

1. **League Information**  
2. **Scoring Settings**  
3. **Handicap Settings**  
4. **Course Settings**  
5. **Blind Draw Settings**  
6. **Schedule Settings**  
7. **Match Report Settings**  
8. **Power Query + File Paths**  
9. **System Flags**

Each block contains parameter fields tied to **named ranges**.

Each named range has:

- A clear purpose  
- A fixed name (used by PQ)  
- A well-defined scope  
- A documented expected data type  

All named ranges are listed in `Settings_Parameter_Definitions.md`.

---

# 3. Rules for Modifying Settings

## 3.1 Only modify values, not names
Named ranges referenced by Power Query **must never be renamed**, including:
- `matchReportsFolderPath`
- `parArray`
- `hcpArray`
- `bdMaxHoles`
- `useLocalStagingFolder`
- (and all others in the parameter definitions)

Changing a range name will break queries.

---

## 3.2 Never change the dimensionality of array-like settings
Examples:

- Pars → always 18 values  
- Handicaps → always 18 values  
- Net Score or Points arrays → defined ranges must stay consistent  

If the structure must change, this requires:

1. A versioned Settings update  
2. Updating documentation  
3. Updating dependent PQ modules  

---

## 3.3 Boolean flags must always use TRUE/FALSE
Power Query is forgiving, but the REFIT governance standard requires:

TRUE
FALSE

Avoid:

Yes / No
1 / 0
Y / N

---

## 3.4 Match Report folder paths must remain valid
If the folder path is wrong or empty:
- Raw queries return empty tables  
- Staging and Analytics return empty tables  
- No scoring occurs  

This is expected behavior, but should be communicated in documentation.

---

## 3.5 Changing settings with in-season scoring implications
Any change affecting:

- Par values  
- Hcp values  
- Blind Draw settings  
- Handicap algorithm parameters  
- Scoring allocations  

must be recorded in:

/docs/Version_History.md

Especially if applied mid-season.

---

# 4. How PQ Uses Settings

Power Query retrieves settings ONLY through:

GetSetting("parameterName")

No module should ever reference:
- Hard-coded values  
- Hard-coded arrays  
- Static assumptions about course properties  

Any new functionality requiring configuration must add a named range and update documentation.

---

# 5. Adding New Parameters

To add a parameter:

1. Create a new field in the Settings sheet under the correct block.  
2. Create a **named range** exactly matching the intended parameter name.  
3. Add the entry to:
   - `Settings_Parameter_Definitions.md`
   - Optionally, the Settings Documentation sheet  
4. Update PQ modules to use the new parameter.

This ensures the system remains self-documenting.

---

# 6. Versioning Settings

When a season transitions:

1. Duplicate the workbook for the new year.  
2. Reset seasonal parameters (e.g., week numbers, schedule fields).  
3. Audit settings blocks for accuracy.  
4. Update `/docs/Version_History.md` to record:
   - Year rollover  
   - Any new parameters  
   - Any parameter removals  
   - Any significant value changes  

---

# 7. Governance Responsibilities

### Secretary Responsibilities:
- Maintain season-specific values  
- Validate file paths  
- Adjust match schedule fields  
- Confirm course metadata  

### Developer / Maintainer Responsibilities:
- Add new parameters as needed  
- Ensure parameter names remain stable  
- Update documentation when logic changes  

---

# 8. Ensuring Future Maintainability

Settings governance exists so future secretaries can:

- Make safe changes  
- See exactly what each parameter does  
- Understand how PQ consumes it  
- Keep the system functioning without technical expertise  

This document must remain up to date as the system evolves.
