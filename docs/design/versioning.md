Power Query Versioning via Filename-Based Strategy
Purpose

This document defines the filename-based versioning strategy used for Power Query (M code) modules in the GL-REFIT project.

The goal is to ensure:

Clear version identification even when files are detached from the repository

Simple workflows for maintainers with limited Git experience

Strong auditability and rollback capability

Minimal ambiguity about which version is “active”

Core Principle

Each Power Query module is stored as a single .m file whose filename explicitly includes the version number.

Example:

Upload_Indiv_Raw_v1.0.m


This ensures that the version is immediately visible:

In GitHub

In local file systems

When emailed or shared independently

Without opening the file to inspect comments

Directory Layout
src/
└── Upload_Indiv_Raw/
    └── Upload_Indiv_Raw_v1.0.m   ← active version only


Archived versions are stored separately:

archive/
└── src/
    └── Upload_Indiv_Raw/
        ├── Upload_Indiv_Raw_v0.9.m
        └── Upload_Indiv_Raw_v0.8.m

Rules

Only one active version exists in /src/<ModuleName>/

All prior versions must be moved to /archive/src/<ModuleName>/

The active file’s version must match:

The filename

The version header inside the M code

Archived files are never modified once archived

Recommended Version Format

Semantic-style numeric versions:

v<major>.<minor>


Examples:

v1.0 — initial production-ready release

v1.1 — backward-compatible enhancement

v2.0 — breaking logic change

Advantages
Benefit	Explanation
Standalone clarity	Version visible without opening file
Email-safe	Version preserved when file leaves repo
Simple mental model	“The file in /src is the current truth”
Beginner-friendly	No folder navigation required
Git-friendly	Clean diffs and simple history
Tradeoffs
Limitation	Mitigation
Many versions in archive	Acceptable — archive is intentionally verbose
Less compact than folder-based	Clarity favored over compression
Manual move required	Covered by checklist (see Doc 3)