Power Query Versioning Checklist (Operational)

Location recommendation:
GL-REFIT/src/README_versioning_checklist.md

Power Query Module Update Checklist

Use this checklist every time a Power Query module is modified.

1. Before Editing

☐ Identify the current active file in /src/<ModuleName>/

☐ Note its version number

☐ Confirm this is the version currently used in the workbook

2. Create New Version

☐ Copy the active .m file

☐ Increment the version number in the filename
Example:

Upload_Indiv_Raw_v1.0.m → Upload_Indiv_Raw_v1.1.m


☐ Update the version comment inside the M code header

3. Implement Changes

☐ Apply code changes

☐ Validate syntax

☐ Test query in Excel / Power Query

☐ Confirm expected outputs

4. Archive Old Version

☐ Move prior active version to:

archive/src/<ModuleName>/


☐ Do not modify archived files

5. Repository Hygiene

☐ Ensure only one .m file exists in /src/<ModuleName>/

☐ Confirm README.md still describes current behavior

☐ Update README.md if logic or outputs changed

6. Git Commit

☐ Stage changes

☐ Use clear commit message, e.g.:

update: Upload_Indiv_Raw to v1.1 (column normalization fix)

7. Workbook Sync

☐ Paste new M code into Excel query

☐ Confirm workbook version references correct module version

☐ Save workbook

Final Sanity Check

If someone new cloned this repo today:

☐ Would they immediately know which version is current?

☐ Could they safely roll back?

☐ Could they identify what changed and why?

If yes — versioning is correct.