# Settings Documentation

This folder contains all documentation related to the **Settings sheet**, which is the central configuration control panel for the REFIT scoring system.  
Every Power Query module depends on these settings to determine how the system behaves during file ingestion, scoring, staging, analytics, Blind Draw logic, and seasonal configuration.

The Settings sheet is intentionally designed so that **future league secretaries can operate the REFIT system without editing Power Query code**.  
All rules, parameters, and file paths must be controlled here.

---

# Contents of This Folder

### **1. Settings_Governance.md**
Defines:
- How settings are structured into logical blocks  
- Rules for modifying parameters  
- Requirements for named ranges  
- Change-management and versioning expectations  
- Responsibilities of league secretaries vs. system maintainers  

This document ensures settings remain stable, accurate, and safe to update.

---

### **2. Settings_Parameter_Definitions.md**
Provides a complete reference for every named range used in REFIT, including:
- Parameter purpose  
- Expected data type  
- Allowed values  
- How Power Query consumes the value  
- Impact of changes on scoring or workflows  

This is the *authoritative source* for understanding what each setting means and how it should be used.

---

# Why Settings Documentation Matters

The REFIT system is **fully settings-driven**, meaning:

- File paths come from Settings  
- Course pars and handicaps come from Settings  
- Blind Draw behavior comes from Settings  
- Handicap algorithm parameters come from Settings  
- Season configuration comes from Settings  
- Flags and switches that control system behavior all live here  

By centralizing configuration, REFIT avoids:
- Hard-coded values  
- Hidden logic  
- Query rewrites  
- Fragile dependencies  

This documentation ensures future maintainers understand *how and why* settings control the entire system.

---

# How This Folder Fits Into the Overall Documentation Structure

